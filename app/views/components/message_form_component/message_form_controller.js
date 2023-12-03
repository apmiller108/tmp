import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    console.log('hello from view_component dir!')
  }
  disconnect() {
    console.log('goodbye')
  }
  cancel() {
    this.element.remove()
  }
}
