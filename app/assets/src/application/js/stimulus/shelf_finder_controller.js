import { Controller } from "@hotwired/stimulus"
import axios from "axios"

export default class extends Controller {
  static targets = [
    "output"
  ]

  static values = {
    url: String
  }

  connect() {
    axios.get(this.urlValue)
      .then(response => response.data)
      .then(data => this.outputLocation(data))
      .catch(error => this.outputTarget.innerHTML = "ERROR")
  }

  outputLocation(data) {
    var locationStrings = data.locations.map(location => {
      if (!location.closed_stack) {
        var locationLabel = location.display_name
        var shelfLabel = location.shelves.length > 1 ? "Regale" : "Regal"
        var shelfIdentifiers = location.shelves.map(shelf => shelf.identifier)

        var newLocationValue = locationLabel + ", " + shelfLabel + " " + shelfIdentifiers.join(", ")
        return newLocationValue;
      }
    });

    this.outputTarget.innerHTML = locationStrings.join("<br/>")
  }

}
