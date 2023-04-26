import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static outlets = [ "modal-dialog" ]

  connect() {
  }

  open(event) {
    event.preventDefault()
    this.modalDialogOutlet.open(event.currentTarget.href)
  }

  close(event) {
    event.preventDefault()
    this.modalDialogOutlet.close()
  }

}
