import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  cancel() {
    this.element.remove()
  }
}
