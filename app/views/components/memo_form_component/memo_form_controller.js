import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  async onSubmit() {
    await this.dispatch('memoFormSubmit')
    this.element.requestSubmit()
  }
  onColorChosen(e) {
    const hexColor = e.detail.color
    const r = parseInt(hexColor.substring(0, 2), 16);
    const g = parseInt(hexColor.substring(2, 4), 16);
    const b = parseInt(hexColor.substring(4, 6), 16);
    const rgb = [r, g, b].join(',')
    this.element.style.border = `0.25rem solid rgba(${rgb}, 0.8)`
    this.element.style.boxShadow = `0 0 0.5rem 0.5rem rgba(${rgb}, 0.5)`
  }
}
