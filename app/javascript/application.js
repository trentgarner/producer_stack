// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails

// Remove the ES6 import statements
import "jquery";
import "bootstrap";
import './wavesurfer-config'; // Include your custom Wavesurfer configuration file
import "essentia";

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

// essentia.js
$(document).on('ajaxSend', function (e, xhr, options) {
  var token = $('meta[name="csrf-token"]').attr('content');
  if (token) {
    xhr.setRequestHeader('X-CSRF-Token', token);
  }
});
