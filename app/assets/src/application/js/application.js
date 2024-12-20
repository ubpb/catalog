//
// Entry point for the build script in your package.json
//

// Load Rails stuff
//require("@rails/activestorage").start()

// Load / init turbo
import { Turbo } from "@hotwired/turbo-rails"
window.Turbo = Turbo
Turbo.config.drive.progressBarDelay = 200

// Hack to scroll to top (default behavior) without animation on turbo:render
window.addEventListener("turbo:render", () => {
  Turbo.navigator.currentVisit.scrolled = true;
  window.scrollTo({top: 0, behavior: "instant"})
});

// Load / init stimulus controllers from ./stimulus/index.js
import "./stimulus"

// Load bootstrap
import "bootstrap"
// Load bootstrap-icons
//import "bootstrap-icons/bootstrap-icons.svg"

// Enable tooltips
// We need a efficient way of enabling/disabling tooltips that work with regular
// page loads, turbo renders and turbo-frame renders.
// import * as Popper from "@popperjs/core"
// document.addEventListener("turbo:frame-load", () => {
//   const tooltipTriggerList = document.querySelectorAll('[data-bs-toggle="tooltip"]')
//   const tooltipList = [...tooltipTriggerList].map(tooltipTriggerEl => new bootstrap.Tooltip(tooltipTriggerEl))
// })

// Load / init axios
import axios from "axios"
const csrfToken = document.querySelector("meta[name=csrf-token]").content
axios.defaults.headers.common["X-Requested-With"] = "XMLHttpRequest"
axios.defaults.headers.common["X-CSRF-Token"] = csrfToken
document.addEventListener("turbo:render", () => {
  const csrfToken = document.querySelector("meta[name=csrf-token]").content
  axios.defaults.headers.common["X-CSRF-Token"] = csrfToken
})

