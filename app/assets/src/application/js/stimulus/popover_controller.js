import { Controller } from "@hotwired/stimulus"
import { Modal } from "bootstrap"

export default class extends Controller {
  static targets = [ "output", "modal" ]

  modal = null;

  connect() {
    this.outputTarget.hidden = true;

    this.modal = new Modal(this.modalTarget, {
      backdrop: "static",
      keyboard: true,
      show: false
    });
    document.body.append(this.modalTarget);
  }

  show(event) {
    event.preventDefault();
    this.modal.show(document.body);
  }

}
