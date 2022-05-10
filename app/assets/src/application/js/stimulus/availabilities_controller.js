import { Controller } from "@hotwired/stimulus"
import axios from "axios"

export default class extends Controller {
  static targets = ["record", "error"]
  static values = { url: String }

  connect() {
    // Hide error target
    this.hideErrorTarget()
    // Hide all outputs
    this.hideAllOutputs()

    // Check each record target if there is a recordId
    // on that element and if availability checking is
    // enabled for that record. If this is the case, select
    // the recordId and show the output.
    let recordIds = this.recordTargets.map(recordTarget => {
      if (this.isCheckingEnabledForRecord(recordTarget)) {
        this.showOutputForRecord(recordTarget)
        return recordTarget.dataset.recordId
      }
    }).filter(String)

    // For each recordId try to load availability information
    this.getAvailabilities(recordIds)
  }

  getAvailabilities(recordIds) {
    axios.get(`${this.urlValue}?record_ids=${recordIds.join(",")}`)
      .then(response => response.data)
      .then(availabilities => this.updatePage(availabilities))
      .catch(error => this.handleError())
  }

  handleError() {
    this.hideAllOutputs()
    this.showErrorTarget()
  }

  isCheckingEnabledForRecord(recordTarget) {
    return recordTarget.hasAttribute("data-availabilities-enabled")
  }

  hideAllOutputs() {
    this.recordTargets.forEach(recordTarget => {
      this.hideOutputForRecord(recordTarget)
    })
  }

  hideOutputForRecord(recordTarget) {
    let output = this.getOutputForRecord(recordTarget)
    if (output) {
      output.style.display = "none"
    }
  }

  showOutputForRecord(recordTarget, innerHTML = null) {
    let output = this.getOutputForRecord(recordTarget)
    if (output) {
      output.style.display = "block"

      if (innerHTML) {
        output.innerHTML = innerHTML
      }
    }
  }

  getOutputForRecord(recordTarget) {
    return recordTarget.querySelector("[data-availabilities-output]")
  }

  hideErrorTarget() {
    if (this.hasErrorTarget) {
      this.errorTarget.style.display = "none"
    }
  }

  showErrorTarget() {
    if (this.hasErrorTarget) {
      this.errorTarget.style.display = "block"
    }
  }

  updatePage(availabilities) {
    // Hide all outputs
    this.hideAllOutputs()

    // Iterate over all record targets...
    this.recordTargets.forEach(recordTarget => {
      // load the availabilities for the current recordId
      let matchedAvailabilities = availabilities.find(availability => {
        return availability.record_id == recordTarget.dataset.recordId
      })

      let output = this.getOutputForRecord(recordTarget)

      // Update the page using the output target
      if (matchedAvailabilities) {
        this.showOutputForRecord(
          recordTarget,
          matchedAvailabilities.html_content
        )
      }
    })
  }

}
