import { Controller } from "@hotwired/stimulus"
import axios from "axios"
import { Modal } from "bootstrap"

export default class extends Controller {
  static targets = [
    "loader",
    "output",
    "renewAllButton",
    "renewAllModal",
    "renewAllModalBody",
    "renewAllModalCloseButton"
  ]

  modal = null;

  connect() {
    this.loadLoans()
    this.modal = new Modal(this.renewAllModalTarget, {
      backdrop: "static",
      keyboard: false,
      show: false
    });
  }

  loadLoans() {
    const url = this.data.get("url")

    this.hideOutput()
    this.showLoader()

    axios.get(url)
      .then(response => response.data)
      .then(html => this.outputTarget.innerHTML = html)
      .catch(error => this.outputTarget.innerHTML = error)
      .then(() => {
        this.hideLoader()
        this.showOutput()
      })
  }

  renewAll() {
    const url = this.data.get("renew-all-url")

    this.disableRenewAllButton()
    this.disableRenewAllModalCloseButton()
    this.openRenewAllModal()

    axios.post(url)
      .then(response => response.data)
      .then(html => this.renewAllModalBodyTarget.innerHTML = html)
      .catch(error => this.renewAllModalBodyTarget.innerHTML = error)
      .then(() => {
        this.updateRenewAllModalHeight()
        this.enableRenewAllModalCloseButton()
        this.enableRenewAllButton()
      })
  }

  disableRenewAllButton() {
    this.renewAllButtonTarget.disabled = true
  }

  enableRenewAllButton() {
    this.renewAllButtonTarget.disabled = false
  }

  disableRenewAllModalCloseButton() {
    this.renewAllModalCloseButtonTarget.disabled = true
  }

  enableRenewAllModalCloseButton() {
    this.renewAllModalCloseButtonTarget.disabled = false
  }

  openRenewAllModal() {
    this.modal.show()
  }

  closeRenewAllModal() {
    this.modal.dispose()
    window.location = this.data.get("renew-all-redirect-url")
  }

  updateRenewAllModalHeight() {
    this.modal.handleUpdate()
  }

  showLoader() {
    this.loaderTarget.style.display = "block";
  }

  hideLoader() {
    this.loaderTarget.style.display = "none";
  }

  showOutput() {
    this.outputTarget.style.display = "block";
  }

  hideOutput() {
    this.outputTarget.style.display = "none";
  }

}
