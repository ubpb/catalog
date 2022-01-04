import { Controller } from "@hotwired/stimulus"
import axios from "axios"

export default class extends Controller {
  static targets = ["recordId", "output", "error"]
  static values = { url: String }

  connect() {
    // Hide error target
    this.hideErrorTarget()

    // Fetch the record IDs from the DOM. For each
    // recordID target there must be a data-record-id
    // element on the node which holds the record ID value.
    let recordIds = this.recordIdTargets.map(element => {
      return element.dataset.recordId
    }).filter(String)

    // Load availabilities from the server and update the
    // page.
    this.getAvailabilities(recordIds)
  }

  getAvailabilities(recordIds) {
    axios.get(`${this.urlValue}?record_ids=${recordIds.join(",")}`)
      .then(response => response.data)
      .then(availabilities => this.updatePage(availabilities))
      .catch(error => this.handleError())
  }

  handleError() {
    this.hideAllOutputTargets()
    this.showErrorTarget()
  }

  hideAllOutputTargets() {
    this.outputTargets.forEach(outputTarget => {
      outputTarget.style.display = "none";
    })
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
    // Hide all output targets
    this.hideAllOutputTargets()

    // Iterate over all recordId targets...
    this.recordIdTargets.forEach((recordIdTarget, index) => {
      // get the recordId value from the target
      let recordId = recordIdTarget.dataset.recordId
      // load the availabilities for the current recordId
      let matchedAvailabilities = availabilities.find(element => {
        return element.record_id == recordId
      })
      // Select the output target: For each recordId target, there must
      // be a matching output target, so we can use the index of the
      // current recordId target to select the matching output target.
      let outputTarget = this.outputTargets[index]

      // Update the page using the output target
      if (matchedAvailabilities && outputTarget) {
        outputTarget.innerHTML = matchedAvailabilities.html_content
        outputTarget.style.display = "block";
      }
    })
  }

}
