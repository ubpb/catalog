import { Controller } from "@hotwired/stimulus"
import axios from "axios"

export default class extends Controller {
  static targets = [ "renewButton", "renewSpinner" ]

  connect() {
  }

  renew() {
    const url = this.data.get("renew-url")

    this.renewButtonTarget.hidden = true;
    this.renewSpinnerTarget.style.display = "inline-block";

    axios.post(url)
      .then(response => response.data)
      .then(html => this.element.innerHTML = html)
      .catch(error => this.element.innerHTML = error)
      .then(() => {
        this.renewButtonTarget.hidden = false;
        this.renewSpinnerTarget.style.display = "none";
      })
  }

}
