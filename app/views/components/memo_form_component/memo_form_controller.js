import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  async onSubmit() {
    await this.dispatch('memoFormSubmit')
    this.element.requestSubmit()
  }
}
