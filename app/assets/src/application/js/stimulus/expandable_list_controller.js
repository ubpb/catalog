import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "list",
    "expand",
    "collapse",
    "item"
  ]

  static values = {
    itemCount: 5
  }

  connect() {
    this.collapse()
  }

  collapse(event) {
    event?.preventDefault()
    const items = this.itemTargets

    for (let i = 0; i < items.length; i++) {
      if (i >= this.itemCountValue) {
        items[i].style.display = "none";
      }
    }

    this.hideCollapseTarget()
    if (items.length <= this.itemCountValue) {
      this.hideExpandTarget()
    } else {
      this.showExpandTarget()
    }
  }

  expand(event) {
    event?.preventDefault()

    const items = this.listTarget.getElementsByTagName('li')

    for (let i = 0; i < items.length; i++) {
      items[i].style.removeProperty("display")
    }

    this.hideExpandTarget()
    this.showCollapseTarget()
  }

  hideExpandTarget() {
    if (this.hasExpandTarget) {
      this.expandTarget.style.display = "none"
    }
  }

  showExpandTarget() {
    if (this.hasExpandTarget) {
      this.expandTarget.style.display = "block"
    }
  }

  hideCollapseTarget() {
    if (this.hasCollapseTarget) {
      this.collapseTarget.style.display = "none"
    }
  }

  showCollapseTarget() {
    if (this.hasCollapseTarget) {
      this.collapseTarget.style.display = "block"
    }
  }

}
