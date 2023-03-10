// Entry point for the build script in your package.json
import "@hotwired/turbo-rails"
import "./controllers"

document.addEventListener("turbo:load", function() {
  const userMenuButton = document.getElementById('user-menu-button');
  userMenuButton.addEventListener('click', function(e) {
    const userMenu = document.getElementById('user-menu');
    userMenu.classList.toggle('hidden');
  });
});
