import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["template", "input", "removeButton"]

  inputTargetConnected(target) {
    if (this.inputTargets.length > 1) {
      target.focus()
    }
  }

  removeButtonTargetConnected() {
    this.updateRemoveButtons()
  }

  removeButtonTargetDisconnected() {
    this.updateRemoveButtons()
  }

  updateRemoveButtons() {
    for (let i = 0; i < this.removeButtonTargets.length; i++) {
      this.removeButtonTargets[i].classList.remove("disabled")
    }

    if (this.removeButtonTargets.length == 1) {
      this.removeButtonTargets[0].classList.add("disabled")
    }
  }

  add_field(event) {
    event?.preventDefault()
    let newFieldContent = this.templateTarget.innerHTML
    let myInputGroup = event.target.closest(".input-group")
    myInputGroup.insertAdjacentHTML('afterend', newFieldContent)
  }

  remove_field(event) {
    event?.preventDefault()
    let myInputGroup = event.target.closest(".input-group")
    myInputGroup.remove()
  }

}
