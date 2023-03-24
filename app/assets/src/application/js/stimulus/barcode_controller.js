import { Controller } from "@hotwired/stimulus"
import JsBarcode from "jsbarcode"

export default class extends Controller {
  static values = {
    text: {type: String, default: ""},
    format: {type: String, default: "CODE128"},
    class: {type: String, default: "barcode"},
    margin: {type: Number, default: 0},
    height: {type: Number, default: 60},
    width: {type: Number, default: 2},
    displayValue: {type: Boolean, default: true}
  }

  connect() {
    this.element.innerHTML =
      `<svg
        class="${this.classValue}"
        jsbarcode-format="${this.formatValue}"
        jsbarcode-value="${this.textValue}"
        jsbarcode-margin="${this.marginValue}"
        jsbarcode-height="${this.heightValue}"
        jsbarcode-width="${this.widthValue}"
        jsbarcode-displayValue="${this.displayValueValue}"
      ></svg>`

    JsBarcode(`.${this.classValue}`).init()
  }

}
