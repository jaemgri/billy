document.addEventListener("turbo:load", () => {
  const flashes = document.querySelectorAll(".flash");

  flashes.forEach((flash) => {
    setTimeout(() => {
      flash.style.transition = "opacity 0.5s ease, transform 0.5s ease";
      flash.style.opacity = "0";
      flash.style.transform = "translate(-50%, -10px)";

      setTimeout(() => {
        flash.remove();
      }, 500);
    }, 5000); // 3 seconds
  });
});
