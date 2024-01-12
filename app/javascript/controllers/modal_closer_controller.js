import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.element.dataset.action = 'click->modal-closer#closeModal:prevent'
  }

  closeModal() {
    this.dispatch("closeModal")
  }
}
