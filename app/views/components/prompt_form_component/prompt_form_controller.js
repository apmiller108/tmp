import { Controller } from '@hotwired/stimulus'

export default class PromptFormController extends Controller {
  static targets = ['promptInput', 'userId', 'conversationId', 'form', 'submitButton', 'showOptionsInput']

  connect() {
    this.focusOnPromptInput()
    this.promptInputTarget.addEventListener('keypress', this.submitOnEnter.bind(this))
    this.formTarget.addEventListener('submit', this.disableForm.bind(this))
  }

  disconnect() {
    document.removeEventListener('keypress', this.submitOnEnter.bind(this))
    document.removeEventListener('submit', this.disableForm.bind(this))
  }

  focusOnPromptInput() {
    this.promptInputTarget.focus()
  }

  submitOnEnter(e) {
    if (this.formTarget.disabled) {
      return e.preventDefault()
    }
    if (e.key === "Enter" && !e.shiftKey) {
      e.preventDefault();
      this.formTarget.requestSubmit(); // requestSubmit instead of submit to submit turbo form
    }
  }

  disableForm() {
    this.formTarget.disabled = true
    this.submitButtonTarget.disabled = true
  }

  enableForm() {
    this.formTarget.disabled = false
    this.submitButtonTarget.disabled = false
  }

  toggleShowOptions() {
    if (this.showOptionsInputTarget.value == 'true') {
      this.showOptionsInputTarget.value = 'false'
    } else {
      this.showOptionsInputTarget.value = 'true'
    }
  }
}
