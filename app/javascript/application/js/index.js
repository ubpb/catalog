// Load Rails stuff
import "@hotwired/turbo"
require("@rails/ujs").start()
require("@rails/activestorage").start()
require("channels")

// Load / init stimulus.js and controllers in ./controllers
import { Application } from "stimulus"
import { definitionsFromContext } from "stimulus/webpack-helpers"

const context = require.context("./controllers", true, /\.js$/)
const application = Application.start()
application.load(definitionsFromContext(context))

// Load / init axios
import axios from "axios"
const csrfToken = document.querySelector("meta[name=csrf-token]").content

axios.defaults.headers.common["X-Requested-With"] = "XMLHttpRequest"
axios.defaults.headers.common["X-CSRF-Token"] = csrfToken
document.addEventListener("turbolinks:render", () => {
  const csrfToken = document.querySelector("meta[name=csrf-token]").content
  axios.defaults.headers.common["X-CSRF-Token"] = csrfToken
})
