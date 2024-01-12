import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.element.dataset.bsToggle = 'modal'
    this.element.dataset.bsTarget = this.element.dataset.modal
    this.element.dataset.action = 'click->modal-opener#openModal'
  }

  openModal() {
    const { src } = this.element.dataset
    this.dispatch("openModal", { detail: { src } })
  }
}
