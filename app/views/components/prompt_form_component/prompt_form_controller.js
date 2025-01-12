import { Controller } from '@hotwired/stimulus'

export default class PromptFormController extends Controller {
  static targets = ['promptInput', 'userId', 'conversationId', 'form', 'submitButton',
                    'showOptionsInput', 'showOptionsButton', 'options', 'temperatureSelect',
                    'modelSelect', 'presetSelect']

  connect() {
    this.focusOnPromptInput()
    this.promptInputTarget.addEventListener('keypress', this.submitOnEnter.bind(this))
    this.formTarget.addEventListener('submit', this.disableForm.bind(this))
    this.showOptions()
  }

  disconnect() {
    document.removeEventListener('keypress', this.submitOnEnter.bind(this))
    document.removeEventListener('submit', this.disableForm.bind(this))
  }

  focusOnPromptInput() {
    this.promptInputTarget.focus()
  }

  showOptions() {
    const urlParams = new URLSearchParams(window.location.search);
    const showOptions = urlParams.get('show_options');
    if (showOptions === 'true') {
      if (!this.optionsTarget.classList.contains('show')) {
        this.showOptionsButtonTarget.click()
      }
    }
  }

  submitOnEnter(e) {
    if (this.submitButtonTarget.disabled) {
      return e.preventDefault()
    }
    if (e.key === "Enter" && !e.shiftKey) {
      e.preventDefault();
      this.formTarget.requestSubmit(); // requestSubmit instead of submit to submit turbo form
    }
  }

  disableForm() {
    this.submitButtonTarget.disabled = true
  }

  enableForm() {
    this.submitButtonTarget.disabled = false
  }

  onClickShowOptions() {
    let url = new URL(window.location.href);

    if (this.showOptionsInputTarget.value == 'true') {
      this.showOptionsInputTarget.value = 'false'
      url.searchParams.set('show_options', 'false');
    } else {
      this.showOptionsInputTarget.value = 'true'
      url.searchParams.set('show_options', 'true');
      this.dispatch('promptOptionsShow', { detail: {} })
    }

    history.pushState({}, '', url);
  }

  // If there is an error in the background job, enabled the form
  onGenerateText() {
    this.enableForm()
    this.focusOnPromptInput()
  }
}
