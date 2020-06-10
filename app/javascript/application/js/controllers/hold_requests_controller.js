import { Controller } from "stimulus"
import axios from "axios"

export default class extends Controller {
  static targets = [
    "loader",
    "output"
  ]

  connect() {
    this.loadHoldRequests()
  }

  loadHoldRequests() {
    const url = this.data.get("url")

    this.hideOutput()
    this.showLoader()

    axios.get(url)
      .then(response => response.data)
      .then(html => this.outputTarget.innerHTML = html)
      .catch(error => this.outputTarget.innerHTML = error)
      .then(() => {
        this.hideLoader()
        this.showOutput()
      })
  }

  showLoader() {
    this.loaderTarget.style.display = "block";
  }

  hideLoader() {
    this.loaderTarget.style.display = "none";
  }

  showOutput() {
    this.outputTarget.style.display = "block";
  }

  hideOutput() {
    this.outputTarget.style.display = "none";
  }

}
