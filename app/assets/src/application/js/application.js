//
// Entry point for the build script in your package.json
//

// Load Rails stuff
//require("@rails/activestorage").start()

// Load / init turbo
import { Turbo } from "@hotwired/turbo-rails"
window.Turbo = Turbo
Turbo.setProgressBarDelay(200)

// Load / init stimulus controllers from ./stimulus/index.js
import "./stimulus"

// Load bootstrap
import * as bootstrap from "bootstrap"

// Load / init axios
import axios from "axios"
const csrfToken = document.querySelector("meta[name=csrf-token]").content
axios.defaults.headers.common["X-Requested-With"] = "XMLHttpRequest"
axios.defaults.headers.common["X-CSRF-Token"] = csrfToken
document.addEventListener("turbo:render", () => {
  const csrfToken = document.querySelector("meta[name=csrf-token]").content
  axios.defaults.headers.common["X-CSRF-Token"] = csrfToken
})

