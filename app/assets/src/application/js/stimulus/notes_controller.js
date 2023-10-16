import { Controller } from "@hotwired/stimulus"
import axios from "axios"

export default class extends Controller {
  static targets = ["record"]
  static values = { url: String, scope: String, enabled: Boolean}

  connect() {
    if (this.enabledValue) {
      // Check each record target if there is a note
      // for that element.
      let recordIds = this.recordTargets.map(recordTarget => {
          return recordTarget.dataset.recordId
      }).filter(String)

      // For all recordIds try to load notes
      axios.get(`${this.urlValue}.json?record_ids=${recordIds.join(",")}`)
        .then(response => response.data)
        .then(notes => {
          this.notes = notes
          this.updateTargets()
        })
    }
  }

  findNote(recordId) {
    if (this.notes) {
      let matchedNote = this.notes?.find(note => {
        return note.record_id == recordId
      })

      return matchedNote;
    }
  }

  getFormInputForRecord(recordTarget) {
    return recordTarget.querySelector("[data-notes-form-input]")
  }

  getRecordTargetById(recordId) {
    var matchedRecordTarget

    this.recordTargets.forEach(recordTarget => {
        if (!matchedRecordTarget)
        if (recordTarget.dataset.recordId == recordId)
        {
          matchedRecordTarget = recordTarget;
        }
    })

    return matchedRecordTarget;
  }

  updateTargets() {
    // update content of all targets
    this.recordTargets.forEach(recordTarget => {
      this.updateTarget(recordTarget)
    })
  }

  updateTarget(recordTarget) {
    this.removeStateClasses(recordTarget);

    let note = this.findNote(recordTarget.dataset.recordId)

    if (note) {
      recordTarget.classList.add("note");

      let output_content = recordTarget.querySelector("[data-notes-output-content]")
      if (output_content.textContent !== undefined) {
        output_content.textContent = decodeURI(note?.value)
      }
    }

    this.updateDropDownIcon(recordTarget, note);
  }

  updateDropDownIcon(recordTarget, note) {
    let dd_btn = recordTarget.querySelector("[data-notes-btn-icon]");

    if (dd_btn) {
      if (note) {
        dd_btn.classList.add("fa-solid");
        dd_btn.classList.remove("fa-regular");
      }
      else {
        dd_btn.classList.remove("fa-solid");
        dd_btn.classList.add("fa-regular");
      }
    }
  }

  removeStateClasses(recordTarget) {
    recordTarget.classList.remove("note");
    recordTarget.classList.remove("error");
    recordTarget.classList.remove("edit");
  }

  save(event) {
    event.preventDefault()

    if (this.enabledValue) {
      var recordTarget = this.getRecordTargetById(event.target.dataset.recordId)

      var note = this.findNote(event.target.dataset.recordId)
      let input = this.getFormInputForRecord(recordTarget)

      if (note) {
        axios.put(`${this.urlValue}/${note.id}`, {
          id: note.id, record_id: event.target.dataset.recordId, value: input.value, scope: recordTarget.dataset.recordScope
        })
        .then(response => {
          note.value = input.value
          this.updateTarget(recordTarget)
        })
        .catch(error => {
          recordTarget.classList.add("error");
        })
      }
      else {
        if (input) {
          axios.post(`${this.urlValue}`, {
            record_id: event.target.dataset.recordId, value: input.value, scope: recordTarget.dataset.recordScope
          })
          .then(response => {
            this.notes.push (response.data)
            this.updateTarget(recordTarget)
          })
          .catch(error => {
            recordTarget.classList.add("error");
          })
        }
      }
    }
  }

  cancel(event) {
    event.preventDefault()
    var recordTarget = this.getRecordTargetById(event.target.dataset.recordId)

    this.updateTarget(recordTarget)
  }

  edit(event) {
    event.preventDefault()

    if (this.enabledValue) {
      var recordTarget = this.getRecordTargetById(event.target.dataset.recordId)

      let note = this.findNote(event.target.dataset.recordId)
      let input = this.getFormInputForRecord(recordTarget)

      recordTarget.classList.add("edit");

      if (note?.value) {
        input.value = note.value
      }
      else {
        input.value = null
      }

      input.focus();
    }
  }

  delete(event) {
    event.preventDefault()

    if (this.enabledValue) {
      var recordTarget = this.getRecordTargetById(event.target.dataset.recordId)

      var note = this.findNote(event.target.dataset.recordId)

      if (note) {
        axios.delete(`${this.urlValue}/${note.id}`)
          .then(response => {
            var index = this.notes.indexOf(note)
            if (index > -1) {
              this.notes.splice(index, 1);
            }

            this.updateTarget(recordTarget)
          })
          .catch(error => {
            recordTarget.classList.add("error");
          })
      }
    }
  }

}
