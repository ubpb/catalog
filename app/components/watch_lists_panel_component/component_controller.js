import { Controller } from "@hotwired/stimulus"
import axios from "axios"

export default class extends Controller {
  static targets = [ "input" ]
  static values = { createUrl: String }

  connect() {
  }

  createWatchList(event) {
    if (event.key == "Enter") {
      event.preventDefault()

      let listName = this.inputTarget.value

      if (listName) {
        axios.post(this.createUrlValue, {
          watch_list: { name: listName }
        }).then(() => window.location.reload(true))
      }
    }
  }

  addToWatchList(event) {
    event.preventDefault()
    let url = event.currentTarget.getAttribute("href")
    axios.put(url)
      .then(response => response.data)
      .then(html => this.element.outerHTML = html)
  }

  removeFromWatchList(event) {
    event.preventDefault()
    let url = event.currentTarget.getAttribute("href")
    axios.put(url)
      .then(response => response.data)
      .then(html => this.element.outerHTML = html)
  }

}
