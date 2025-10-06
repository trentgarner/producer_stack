pin "application", preload: true
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true
pin_all_from "app/javascript/controllers", under: "controllers"

# Note: Everything above was added by default. Added these two lines:
pin "bootstrap", to: "bootstrap.min.js", preload: true
pin "@popperjs/core", to: "popper.js", preload: true
pin "jquery", to: "https://code.jquery.com/jquery-3.6.0.min.js"
pin "essentia", to: "https://cdn.jsdelivr.net/npm/essentia.js@latest/essentia.min.js"
