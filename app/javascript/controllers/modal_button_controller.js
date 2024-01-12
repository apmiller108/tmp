import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  openModal() {
    const { src } = this.dataset()
    this.dispatch("openModal", { detail: { src } })
  }

  dataset() {
    return this.element.dataset
  }
}
