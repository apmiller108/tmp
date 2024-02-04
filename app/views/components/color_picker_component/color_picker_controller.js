import { Controller } from "@hotwired/stimulus"

export default class ColorPicker extends Controller {
  static targets = ['input', 'swatchesButton', 'swatches', 'removeColorLink']

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
    this.swatchesButtonTarget.style.color = ''
    this.removeColorLinkTarget.classList.remove('d-none')
    this.dispatch('colorChosen', { detail: { color } })
  }

  reset() {
    this.inputTarget.value = ''
    this.swatchesButtonTarget.style.background = ''
    this.swatchesButtonTarget.style.color = '#000'
    this.removeColorLinkTarget.classList.add('d-none')
    this.dispatch('colorRemoved')
  }
}
