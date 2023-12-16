import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    console.log('Hello, this is a Blob Controller!')
  }
  cancel() {
    this.element.remove()
  }
}
