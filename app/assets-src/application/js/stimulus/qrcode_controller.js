import { Controller } from "@hotwired/stimulus"
import QRCode from "qrcode"

export default class extends Controller {
  static values = {
    text: {type: String, default: ""},
    margin: {type: Number, default: 0},
    scale: {type: Number, default: 2}
  }

  connect() {
    QRCode.toDataURL(this.textValue, {
      margin: this.marginValue,
      scale: this.scaleValue
    }).then(url => {
      this.element.innerHTML = `<img src="${url}" alt="QR Code" />`
    })
  }
}
