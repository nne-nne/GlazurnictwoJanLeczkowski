
# optimize_images.ps1
# Requires System.Drawing to be available

Add-Type -AssemblyName System.Drawing

$sourceDir = "c:\Users\Adam\Desktop\GlazurnictwoJanLeczkowski\images"
$excludedFolders = @("horizontal") # Keep original carousel images for now if not targeting them, but plan says "images/selection"
$targetFolders = @("selection")

function Optimize-Image {
    param (
        [string]$FilePath,
        [int]$MaxWidth,
        [int]$MaxHeight,
        [string]$Suffix
    )

    $image = [System.Drawing.Bitmap]::FromFile($FilePath)
    
    # Calculate new dimensions
    $ratioX = $MaxWidth / $image.Width
    $ratioY = $MaxHeight / $image.Height
    $ratio = $ratioX
    if ($ratioY -lt $ratioX) {
        $ratio = $ratioY
    }
    
    # Only resize if original is larger
    if ($ratio -ge 1) {
        $image.Dispose()
        return $false
    }
    
    $newWidth = [int]($image.Width * $ratio)
    $newHeight = [int]($image.Height * $ratio)

    $newImage = new-object System.Drawing.Bitmap $newWidth, $newHeight
    $graphics = [System.Drawing.Graphics]::FromImage($newImage)
    $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $graphics.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality

    $graphics.DrawImage($image, 0, 0, $newWidth, $newHeight)
    $image.Dispose()
    
    # Save with quality setting
    $codec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq "image/jpeg" }
    $encoderParams = New-Object System.Drawing.Imaging.EncoderParameters(1)
    $encoderParams.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter([System.Drawing.Imaging.Encoder]::Quality, [long]85)

    $newPath = $FilePath -replace "\.jpg$", "$Suffix.jpg"
    $newImage.Save($newPath, $codec, $encoderParams)
    
    $newImage.Dispose()
    $graphics.Dispose()
    
    Write-Host "Created $newPath"
    return $true
}

Get-ChildItem -Path $sourceDir -Recurse -File -Filter "*.jpg" | ForEach-Object {
    $file = $_
    
    # Skip already optimized images
    if ($file.Name -match "_thumb.jpg$" -or $file.Name -match "_large.jpg$") {
        return
    }
    
    # Check if in target directory (e.g. selection/)
    $isInTarget = $false
    foreach ($folder in $targetFolders) {
        if ($file.FullName -match "\\$folder\\") {
            $isInTarget = $true
            break
        }
    }
    
    if ($isInTarget) {
        Write-Host "Processing $($file.FullName)..."
        
        # Generate Thumbnail (approx 450px height for generated grid)
        # Assuming grid item height is around 350px-450px as per CSS
        # .gallery-item img { height: 350px; } in CSS -> let's go with 500px to be safe
        Optimize-Image -FilePath $file.FullName -MaxWidth 800 -MaxHeight 500 -Suffix "_thumb"
        
        # Generate Large (HD 1920x1080 constraint)
        Optimize-Image -FilePath $file.FullName -MaxWidth 1920 -MaxHeight 1080 -Suffix "_large"
    }
}
