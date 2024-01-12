import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  openModal() {
    const { src, title } = this.dataset()
    this.dispatch("openModal", { detail: { src, title } })
  }

  dataset() {
    return this.element.dataset
  }
}
