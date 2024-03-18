import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "source", "copyButton", "copiedMessage"
  ]

  connect() {
    this.hideCopiedMessage()
    this.showCopyButton()
  }

  copy(event) {
    event.preventDefault()
    if (!this.hasSourceTarget) { return }

    this.sourceTarget.select()
    this.sourceTarget.setSelectionRange(0, 99999) // For mobile devices
    navigator.clipboard.writeText(this.sourceTarget.value)

    this.hideCopyButton()
    this.showCopiedMessage()
  }

  hideCopyButton() {
    if (!this.hasCopyButtonTarget) { return }

    this.copyButtonTarget.style.display = "none"
  }

  showCopyButton() {
    if (!this.hasCopyButtonTarget) { return }

    this.copyButtonTarget.style.display = "block"
  }

  hideCopiedMessage() {
    if (!this.hasCopiedMessageTarget) { return }

    this.copiedMessageTarget.style.display = "none"
  }

  showCopiedMessage() {
    if (!this.hasCopiedMessageTarget) { return }

    this.copiedMessageTarget.style.display = "block"
  }
}
