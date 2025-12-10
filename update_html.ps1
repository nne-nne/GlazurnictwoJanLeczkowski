
# update_html.ps1
$htmlPath = "c:\Users\Adam\Desktop\GlazurnictwoJanLeczkowski\index.html"
$content = Get-Content -Path $htmlPath -Raw -Encoding UTF8

# Regex to find gallery images and add data-full-src
# Pattern matches: src="images/selection/..."
# We need to capture the path to insert _thumb and _large

$pattern = 'src="(images/selection/[^"]+?)\.jpg"'
$replacement = 'src="$1_thumb.jpg" data-full-src="$1_large.jpg"'

$newContent = $content -replace $pattern, $replacement

Set-Content -Path $htmlPath -Value $newContent -Encoding UTF8
Write-Host "Updated HTML content."
