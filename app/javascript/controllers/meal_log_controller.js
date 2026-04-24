import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["buttons", "form", "input"]

  showModified() {
    this.buttonsTarget.classList.add("hidden")
    this.formTarget.classList.remove("hidden")
    if (this.hasInputTarget) this.inputTarget.focus()
  }
}
