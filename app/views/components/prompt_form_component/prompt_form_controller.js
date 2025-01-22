import { Controller } from '@hotwired/stimulus'
import { createGenTextId } from '@javascript/helpers'
import ToolTippable from '@javascript/mixins/ToolTippable'
import LocalStorage from '@javascript/LocalStorage'
import { Collapse } from 'bootstrap'

export default class PromptFormController extends Controller {
  static targets = ['promptInput', 'userId', 'conversationId', 'form', 'submitButton',
                    'showOptionsButton', 'options', 'temperatureSelect',
    'modelSelect', 'presetSelect', 'textId']

  connect() {
    ToolTippable.connect.bind(this)()
    this.focusOnPromptInput()
    this.promptInputTarget.addEventListener('keypress', this.submitOnEnter.bind(this))
    this.formTarget.addEventListener('submit', this.disableForm.bind(this))
    this.textIdTarget.value = createGenTextId();
    this.showOptions()
    this.setPreset()
    this.setTemperature()
  }

  disconnect() {
    document.removeEventListener('keypress', this.submitOnEnter.bind(this))
    document.removeEventListener('submit', this.disableForm.bind(this))
    ToolTippable.disconnect.bind(this)()
  }

  get generateTextPresetData() {
    return JSON.parse(this.presetSelectTarget.dataset.presetJson)
  }

  focusOnPromptInput() {
    this.promptInputTarget.focus()
  }

  showOptions() {
    const localStore = new LocalStorage()
    const options = new Collapse(this.optionsTarget, {
      toggle: false
    })

    if (localStore.getConvoShowOptions() === 'true') {
      options.show()
    }
  }

  setPreset() {
    const urlParams = new URLSearchParams(window.location.search);
    const presetId = urlParams.get('text_preset_id');
    if (presetId) {
      this.presetSelectTarget.value = presetId
    }
  }

  setTemperature() {
    const presetId = this.presetSelectTarget.value
    this.setTemperatureFromSelectedPreset(presetId)
  }

  submitOnEnter(e) {
    if (this.submitButtonTarget.disabled) {
      return e.preventDefault()
    }

    const value = this.promptInputTarget.value.trim()
    if (e.key === "Enter" && !e.shiftKey && value) {
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
    const localStore = new LocalStorage()

    if (localStore.getConvoShowOptions() == 'true') {
      localStore.setConvoShowOptions(false)
      this.showOptionsButtonTarget.querySelector('i').classList.remove('down')
    } else {
      localStore.setConvoShowOptions(true)
      this.showOptionsButtonTarget.querySelector('i').classList.add('down')
      this.dispatch('promptOptionsShow', { detail: {} })
    }
  }

  onChangePreset(e) {
    const presetId = e.target.value
    this.setTemperatureFromSelectedPreset(presetId)
  }

  setTemperatureFromSelectedPreset(presetId) {
    if (presetId) {
      const presetData = this.generateTextPresetData.find(d => d.id === Number(presetId))
      const temperatureValues = Array.from(this.temperatureSelectTarget.querySelectorAll('option')).map(o => o.value)

      if (presetData && temperatureValues.includes(presetData.temperature)) {
        this.temperatureSelectTarget.value = presetData.temperature
      }
    }
  }


  // If there is an error in the background job, enabled the form
  onGenerateText() {
    this.enableForm()
    this.focusOnPromptInput()
  }
}
