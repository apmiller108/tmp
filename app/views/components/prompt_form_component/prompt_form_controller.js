import { Controller } from '@hotwired/stimulus'
import { createGenTextId } from '@javascript/helpers'
import ToolTippable from '@javascript/mixins/ToolTippable'

export default class PromptFormController extends Controller {
  static targets = ['promptInput', 'userId', 'conversationId', 'form', 'submitButton',
                    'showOptionsInput', 'showOptionsButton', 'options', 'temperatureSelect',
                    'modelSelect', 'presetSelect', 'textId']

  connect() {
    ToolTippable.connect.bind(this)()
    this.focusOnPromptInput()
    this.promptInputTarget.addEventListener('keypress', this.submitOnEnter.bind(this))
    this.formTarget.addEventListener('submit', this.disableForm.bind(this))
    this.textIdTarget.value = createGenTextId();
    this.showOptions()
    this.setPreset()
  }

  disconnect() {
    document.removeEventListener('keypress', this.submitOnEnter.bind(this))
    document.removeEventListener('submit', this.disableForm.bind(this))
    ToolTippable.disconnect.bind(this)()
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

  setPreset() {
    const urlParams = new URLSearchParams(window.location.search);
    const presetId = urlParams.get('text_preset_id');
    if (presetId) {
      this.presetSelectTarget.value = presetId
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
      this.showOptionsButtonTarget.querySelector('i').classList.remove('down')
    } else {
      this.showOptionsInputTarget.value = 'true'
      url.searchParams.set('show_options', 'true');
      this.showOptionsButtonTarget.querySelector('i').classList.add('down')
      this.dispatch('promptOptionsShow', { detail: {} })
    }

    history.replaceState({}, '', url);
  }

  // If there is an error in the background job, enabled the form
  onGenerateText() {
    this.enableForm()
    this.focusOnPromptInput()
  }
}
