import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input"]

  pick(event) {
    const value = event.params.value
    this.inputTarget.value = value

    this.element.querySelectorAll("button").forEach(b => {
      const isActive = String(b.dataset.scoreValueParam) === String(value)
      b.classList.toggle("border-accent-500", isActive)
      b.classList.toggle("bg-accent-500/20", isActive)
      b.classList.toggle("text-accent-200", isActive)
      b.classList.toggle("border-ink-700", !isActive)
      b.classList.toggle("bg-ink-900", !isActive)
      b.classList.toggle("text-ink-300", !isActive)
    })
  }
}
