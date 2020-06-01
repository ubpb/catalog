import { Controller } from "stimulus"
import axios from "axios"

export default class extends Controller {
  static targets = [ "renewButton", "renewSpinner" ]

  connect() {
  }

  renew() {
    const url = this.data.get("renew-url")

    this.renewButtonTarget.disabled = true;
    this.renewSpinnerTarget.style.visibility = "visible";

    axios.post(url)
      .then(response => response.data)
      .then(html => this.element.outerHTML = html)
      .catch(error => this.element.innerHTML = error)
      .then(() => {
        this.renewButtonTarget.disabled = false;
        this.renewSpinnerTarget.style.visibility = "hidden";
      })
  }

}
