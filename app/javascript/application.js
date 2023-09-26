// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails

// Remove the ES6 import statements
//= require es-module-shims.min
//= require application-43bf9cb

// import "popper"
// import "bootstrap"

document.addEventListener("turbo:load", function () {
  // This code is copied from Bootstrap's docs. See link below.
  var tooltipTriggerList = [].slice.call(
    document.querySelectorAll('[data-bs-toggle="tooltip"]')
  );
  var tooltipList = tooltipTriggerList.map(function (tooltipTriggerEl) {
    return new bootstrap.Tooltip(tooltipTriggerEl);
  });
});
