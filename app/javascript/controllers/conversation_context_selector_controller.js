import { Controller } from '@hotwired/stimulus'

export default class ConversationContextSelector extends Controller {
  static targets = ['submitButton', 'select']

  connect() {
    this.toggleSubmit()
  }

  toggleSubmit() {
    const selected = this.selectTarget.selectedOptions
    this.submitButtonTarget.disabled = !selected.length
  }
}
