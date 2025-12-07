let slideIndex = 1;
let slideInterval; // Variable to store the interval ID

showSlides(slideIndex);
startSlideShow(); // Start the auto-play

// Next/previous controls
function plusSlides(n) {
    showSlides(slideIndex += n);
    resetSlideShow(); // Reset the timer when user manually changes slide
}

// Main logic
function showSlides(n) {
    let i;
    let slides = document.getElementsByClassName("slide");

    // Reset to first slide if we go past the end
    if (n > slides.length) { slideIndex = 1 }

    // Reset to last slide if we go before the beginning
    if (n < 1) { slideIndex = slides.length }

    // Hide all slides
    for (i = 0; i < slides.length; i++) {
        slides[i].style.display = "none";
    }

    // Show the current slide
    slides[slideIndex - 1].style.display = "block";
}

function startSlideShow() {
    slideInterval = setInterval(() => {
        showSlides(slideIndex += 1);
    }, 5000);
}

function resetSlideShow() {
    clearInterval(slideInterval); // Stop the current timer
    startSlideShow(); // Start a new timer
}

// --- LIGHTBOX LOGIC ---
const modal = document.getElementById("lightboxModal");
const modalImg = document.getElementById("modalImage");
const closeBtn = document.getElementsByClassName("close")[0];

// Get all gallery images
const galleryImages = document.querySelectorAll(".gallery-item img");
let currentLightboxIndex = 0;
const imageUrls = [];

// Populate image URLs array and add click listeners
galleryImages.forEach((img, index) => {
    imageUrls.push(img.src);
    img.addEventListener("click", function () {
        modal.style.display = "block";
        modalImg.src = this.src;
        currentLightboxIndex = index;
    });
});

// Change slide function
function changeLightboxSlide(n) {
    currentLightboxIndex += n;
    if (currentLightboxIndex >= imageUrls.length) {
        currentLightboxIndex = 0;
    } else if (currentLightboxIndex < 0) {
        currentLightboxIndex = imageUrls.length - 1;
    }
    modalImg.src = imageUrls[currentLightboxIndex];
}

// Close when clicking the x
closeBtn.onclick = function () {
    modal.style.display = "none";
}

// Close when clicking outside the image
modal.onclick = function (event) {
    if (event.target === modal) {
        modal.style.display = "none";
    }
}