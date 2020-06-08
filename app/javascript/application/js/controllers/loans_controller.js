import { Controller } from "stimulus"
import axios from "axios"

export default class extends Controller {
  static targets = [
    "loader",
    "output",
    "renewAllButton",
    "renewAllModal",
    "renewAllModalBody",
    "renewAllModalButton"
  ]

  connect() {
    this.loadLoans()
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
    this.disableRenewAllModalButton()
    this.openRenewAllModal()

    axios.post(url)
      .then(response => response.data)
      .then(html => this.renewAllModalBodyTarget.innerHTML = html)
      .catch(error => this.renewAllModalBodyTarget.innerHTML = error)
      .then(() => {
        this.updateRenewAllModalHeight()
        this.enableRenewAllModalButton()
        this.enableRenewAllButton()
      })
  }

  disableRenewAllButton() {
    this.renewAllButtonTarget.disabled = true
  }

  enableRenewAllButton() {
    this.renewAllButtonTarget.disabled = false
  }

  disableRenewAllModalButton() {
    this.renewAllModalButtonTarget.disabled = true
  }

  enableRenewAllModalButton() {
    this.renewAllModalButtonTarget.disabled = false
  }

  openRenewAllModal() {
    $(this.renewAllModalTarget).modal({
      backdrop: "static",
      keyboard: false,
      show: true
    })
  }

  closeRenewAllModal() {
    $(this.renewAllModalTarget).modal("dispose")
    window.location = this.data.get("renew-all-redirect-url")
  }

  updateRenewAllModalHeight() {
    $(this.renewAllModalTarget).modal("handleUpdate")
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
