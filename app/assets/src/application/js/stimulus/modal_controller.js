import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static outlets = [ "modal-dialog" ]

  connect() {
    //console.log("ModalController#connect")
  }

  open(event) {
    event.preventDefault()
    let src = event.currentTarget.href
    if (src) {
      this.modalDialogOutlet.open(src)
    }
  }

  close(event) {
    event.preventDefault()
    this.modalDialogOutlet.close()
  }

}
