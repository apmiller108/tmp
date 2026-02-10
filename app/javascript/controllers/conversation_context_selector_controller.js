import { Controller } from '@hotwired/stimulus'

export default class ConversationContextSelector extends Controller {
  static targets = ['submitButton', 'select']

  connect() {
    this.toggleSubmit()
    this.boundOnModelChanged = this.onModelChanged.bind(this)
    this.boundOnContextModalOpened = this.onContextModalOpened.bind(this)

    document.addEventListener('prompt-form:model-changed', this.boundOnModelChanged)
    document.addEventListener('conversation-context:opened', this.boundOnContextModalOpened)

    this.disableIncompatibleOptions()
  }

  disconnect() {
    document.removeEventListener('prompt-form:model-changed', this.boundOnModelChanged)
    document.removeEventListener('conversation-context:opened', this.boundOnContextModalOpened)
  }

  toggleSubmit() {
    const selected = Array.from(this.selectTarget.selectedOptions)
    this.submitButtonTarget.disabled = !selected.length
  }

  onModelChanged(event) {
    this.selectTarget.dataset.currentVendor = event.detail.vendor
    this.disableIncompatibleOptions()
  }

  onContextModalOpened(event) {
    this.selectTarget.dataset.currentVendor = event.detail.vendor
    this.disableIncompatibleOptions()
  }

  disableIncompatibleOptions() {
    const currentVendor = this.selectTarget.dataset.currentVendor
    if (!currentVendor) return

    Array.from(this.selectTarget.options).forEach(option => {
      const optionVendor = option.dataset.vendor
      if (optionVendor && optionVendor !== currentVendor) {
        option.disabled = true
        option.selected = false // Deselect if it was selected and now incompatible
      } else {
        option.disabled = false
      }
    })
    this.toggleSubmit()
  }
}
