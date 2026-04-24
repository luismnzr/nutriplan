import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input"]

  connect() {
    this.initialValues = new Map()
    this.inputTargets.forEach(el => this.initialValues.set(el, el.value))
  }

  save(event) {
    const el = event.currentTarget
    if (this.initialValues.get(el) === el.value) return
    this.initialValues.set(el, el.value)
    this.element.requestSubmit()
  }
}
