import { Controller } from "@hotwired/stimulus"
import axios from "axios"

export default class extends Controller {
  static targets = [ "output" ]

  connect() {
    this.loadPartial()
  }

  loadPartial() {
    const url = this.data.get("url")
    axios.get(url)
      .then(response => response.data)
      .then(html => this.outputTarget.innerHTML = html)
      .catch(error => this.outputTarget.innerHTML = error)
  }
}
