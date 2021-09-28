// Load Rails stuff
require("@rails/ujs").start()
require("@rails/activestorage").start()

// Load / init turbo
import { Turbo } from "@hotwired/turbo-rails"
window.Turbo = Turbo
Turbo.setProgressBarDelay(200)

// Load / init stimulus.js and controllers in ./controllers
import { Application } from "@hotwired/stimulus"
import { definitionsFromContext } from "@hotwired/stimulus-webpack-helpers"

window.Stimulus = Application.start()
const context = require.context("./controllers", true, /\.js$/)
Stimulus.load(definitionsFromContext(context))

// Load / init axios
import axios from "axios"
const csrfToken = document.querySelector("meta[name=csrf-token]").content

axios.defaults.headers.common["X-Requested-With"] = "XMLHttpRequest"
axios.defaults.headers.common["X-CSRF-Token"] = csrfToken
document.addEventListener("turbo:render", () => {
  const csrfToken = document.querySelector("meta[name=csrf-token]").content
  axios.defaults.headers.common["X-CSRF-Token"] = csrfToken
})
