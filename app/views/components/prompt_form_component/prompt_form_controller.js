import { Controller } from '@hotwired/stimulus'
import { createGenTextId } from '@javascript/helpers'
import ToolTippable from '@javascript/mixins/ToolTippable'
import LocalStorage from '@javascript/LocalStorage'
import { Collapse } from 'bootstrap'

export default class PromptFormController extends Controller {
  static targets = [
    'promptInput', 'form', 'submitButton', 'showOptionsButton', 'options',
    'temperatureSlider', 'temperatureValue', 'temperatureSelect', 'modelSelect',
    'presetSelect', 'textId', 'toggleTextAreaButton'
  ]

  connect() {
    ToolTippable.connect.bind(this)()
    this.focusOnPromptInput()
    this.promptInputTarget.addEventListener('keypress', this.submitOnEnter.bind(this))
    this.formTarget.addEventListener('submit', this.disableForm.bind(this))
    this.textIdTarget.value = createGenTextId();
    this.initForm()
  }

  disconnect() {
    document.removeEventListener('keypress', this.submitOnEnter.bind(this))
    document.removeEventListener('submit', this.disableForm.bind(this))
    ToolTippable.disconnect.bind(this)()
  }

  get generateTextPresetData() {
    return JSON.parse(this.presetSelectTarget.dataset.presetData)
  }

  get modelData() {
    return JSON.parse(this.modelSelectTarget.dataset.modelData)
  }

  focusOnPromptInput() {
    this.promptInputTarget.focus()
  }

  initForm() {
    this.initializeOptions()
    this.setPreset()
    this.initTemperature()
    this.initializeFileInput()
    this.initializeTextArea()
  }

  initializeOptions() {
    const localStore = new LocalStorage()
    const options = new Collapse(this.optionsTarget, {
      toggle: false
    })

    if (localStore.getConvoShowOptions() === 'true') {
      options.show()
      this.showOptions()
    }
  }

  setPreset() {
    const urlParams = new URLSearchParams(window.location.search);
    const presetId = urlParams.get('text_preset_id');
    if (presetId) {
      this.presetSelectTarget.value = presetId
    }
  }

  initTemperature() {
    const presetId = this.presetSelectTarget.value
    this.updateTemperatureDisplay(this.temperatureSliderTarget.value)
    this.setTemperatureFromSelectedPreset(presetId)
  }

  updateTemperatureDisplay(value) {
    this.temperatureValueTarget.textContent = value

    const temp = parseFloat(value);

    this.temperatureValueTarget.classList.remove('cool', 'medium', 'hot');

    if (temp <= 0.3) {
      this.temperatureValueTarget.classList.add('cool');
    } else if (temp <= 0.7) {
      this.temperatureValueTarget.classList.add('medium');
    } else {
      this.temperatureValueTarget.classList.add('hot');
    }
  }


  initializeFileInput() {
    const selectedModel = this.modelData.find(m => m.api_name === this.modelSelectTarget.value)
    this.dispatch('toggleFileInput', { detail: { disabled: selectedModel.capabilities['image?'] } })
  }

  initializeTextArea() {
    const localStorage = new LocalStorage()

    if (localStorage.getConvoExpandTextArea() === 'true') {
      this.expandTextArea()
    }
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
      this.showOptions()
      localStore.setConvoShowOptions(true)
    }
  }

  showOptions() {
    this.showOptionsButtonTarget.querySelector('i').classList.add('down')
    this.dispatch('promptOptionsShow', { detail: {} })
  }

  onChangePreset(e) {
    const presetId = e.target.value
    this.setTemperatureFromSelectedPreset(presetId)
  }

  setTemperatureFromSelectedPreset(presetId) {
    if (presetId) {
      const presetData = this.generateTextPresetData.find(d => d.id === Number(presetId))

      if (presetData) {
        this.temperatureSliderTarget.value = presetData.temperature
        this.updateTemperatureDisplay(this.temperatureSliderTarget.value)
      }
    }
  }

  onTempInput(e) {
    this.updateTemperatureDisplay(e.target.value)
  }

  onChangeModel() {
    this.initializeFileInput()
  }

  // If there is an error in the background job, enabled the form
  onGenerateText() {
    this.enableForm()
    this.focusOnPromptInput()
  }

  onToggleTextAreaSize() {
    const localStore = new LocalStorage()

    if (this.promptInputTarget.rows === 10) {
      this.promptInputTarget.rows = 2
      this.toggleTextAreaButtonTarget.querySelector('i').classList.remove('up')
      localStore.setConvoExpandTextArea(false)
    } else {
      this.expandTextArea()
      localStore.setConvoExpandTextArea(true)
    }
  }

  expandTextArea() {
    this.promptInputTarget.rows = 10
    this.toggleTextAreaButtonTarget.querySelector('i').classList.add('up')
  }
}
