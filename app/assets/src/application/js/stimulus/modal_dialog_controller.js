import { Controller } from "@hotwired/stimulus"
import * as bootstrap from "bootstrap"

export default class extends Controller {
  static targets = [ "modal", "frame", "loadingTemplate" ]
  static modal = null

  connect() {
    this.modal = new bootstrap.Modal(this.modalTarget, {
      backdrop: true,
      keyboard: true,
      show: false
    });

    // this.modalTarget.addEventListener("show.bs.modal", (event) => {
    //   console.log("show.bs.modal")
    // })
  }

  open(src) {
    if (this.hasLoadingTemplateTarget) {
      this.frameTarget.innerHTML = this.loadingTemplateTarget.innerHTML
    } else {
      this.frameTarget.innerHTML = `
        <div class="modal-body">
          <div class="text-center">
            <i class="fa-solid fa-spinner fa-spin-pulse fa-lg"></i>
          </div>
        </div>
      `
    }

    this.modal.show()
    this.frameTarget.src = src
  }

  close() {
    this.modal.hide()
  }

}
