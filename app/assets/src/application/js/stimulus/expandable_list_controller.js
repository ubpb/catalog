import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "list",
    "expand",
    "collapse"
  ]

  connect() {
    this.collapse()
  }

  collapse(event) {
    event?.preventDefault()

    const items = this.listTarget.getElementsByTagName('li')

    for (let i = 0; i < items.length; i++) {
      if (i >= 5) {
        items[i].style.display = "none";
      }
    }

    this.hideCollapseTarget()
    if (items.length <= 5) {
      this.hideExpandTarget()
    } else {
      this.showExpandTarget()
    }
  }

  expand(event) {
    event?.preventDefault()

    const items = this.listTarget.getElementsByTagName('li')

    for (let i = 0; i < items.length; i++) {
      items[i].style.display = "block";
    }

    this.hideExpandTarget()
    this.showCollapseTarget()
  }

  hideExpandTarget() {
    this.expandTarget.style.display = "none"
  }

  showExpandTarget() {
    this.expandTarget.style.display = "block"
  }

  hideCollapseTarget() {
    this.collapseTarget.style.display = "none"
  }

  showCollapseTarget() {
    this.collapseTarget.style.display = "block"
  }

}
