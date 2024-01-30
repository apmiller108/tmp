import { Controller } from "@hotwired/stimulus"

export default class ColorPicker extends Controller {
  static targets = ['input', 'swatchesButton', 'swatches']

  toggleSwatches() {
    const swatches = this.swatchesTarget
    const swatchesOpacity = window.getComputedStyle(this.swatchesTarget).opacity
    if (swatches.classList.contains('show') || swatchesOpacity !== '0') {
      return this.hideSwatches()
    }
    this.showSwatches()
  }

  hideSwatches() {
    this.swatchesTarget.classList.remove('show')
    this.swatchesButtonTarget.classList.remove('active')
  }

  showSwatches() {
    this.swatchesTarget.classList.add('show')
    this.swatchesButtonTarget.classList.add('active')
  }

  onBlur() {
    this.hideSwatches()
  }

  onFocus() {
    this.showSwatches()
  }

  onChoose(e) {
    const color = e.target.dataset.color
    this.inputTarget.value = color
    this.swatchesButtonTarget.style.background = `#${color}`
    this.dispatch("colorChosen", { detail: { color } })
  }

  get colorPickerButtons() {
    return Array.from(this.element.querySelectorAll('.color-picker-btn'))
  }

}
