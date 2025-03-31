import { Controller } from "@hotwired/stimulus"

export default class SearchModalController extends Controller {
  static targets = ['form', 'input', 'closeButton']

  search() {
    const query = this.inputTarget.value.trim()

    if (query.length === 0) {
      return
    }

    this.formTarget.requestSubmit()
  }

  close() {
    this.closeButtonTarget.click()
  }
}
