// Variables: chapterImages, chapterPath here
images = ""
chapterImages.forEach((img, i) => {
    images += `"${img}"`
    if (chapterImages.length != (i + 1)) {
        images += ", "
    }
})
console.log(`[images: [${images}], path: "${chapterPath}"]`)