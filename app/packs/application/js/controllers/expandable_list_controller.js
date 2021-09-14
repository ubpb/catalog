import { Controller } from "stimulus"

export default class extends Controller {
  static targets = [
    "list",
    "expand"
  ]

  connect() {
    this.collapse()
  }

  collapse() {
    const items = [...this.listTarget.getElementsByTagName('li')]

    items.forEach((item, index) => {
      if (index >= 5) {
        item.style.display = "none";
      }
    });

    if (items.length <= 5) {
      this.hideExpandTarget()
    }
  }

  expand(event) {
    event.preventDefault()
    const items = [...this.listTarget.getElementsByTagName('li')]

    items.forEach((item, index) => {
      item.style.display = "block";
    });

    this.hideExpandTarget()
  }

  hideExpandTarget() {
    this.expandTarget.style.display = "none"
  }

  showExpandTarget() {
    this.expandTarget.style.display = "block"
  }

}
