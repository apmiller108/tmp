import { Controller } from "@hotwired/stimulus"

export default class ColorPicker extends Controller {
  static targets = ['colorButton', 'input', 'swatchesButton', 'swatches', 'removeColorLink']

  connect() {
    document.addEventListener('click', this.autoHideSwatches.bind(this))
  }

  disconnect() {
    document.removeEventListener('click', this.autoHideSwatches.bind(this))
  }

  autoHideSwatches(e) {
    if (!this.element.contains(e.target)) {
      this.hideSwatches()
    }
  }

  toggleSwatches() {
    const swatches = this.swatchesTarget
    if (swatches.classList.contains('d-none')) {
      return this.showSwatches()
    }
    this.hideSwatches()
  }

  hideSwatches() {
    this.swatchesTarget.classList.add('d-none')
    this.swatchesButtonTarget.classList.remove('active')
    this.colorButtonTargets.forEach((btn) => btn.style.pointerEvents = 'none');
  }

  showSwatches() {
    this.colorButtonTargets.forEach((btn) => btn.style.pointerEvents = 'auto');
    this.swatchesTarget.classList.remove('d-none')
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

  onRemove() {
    this.inputTarget.value = ''
    this.swatchesButtonTarget.style.background = ''
    this.swatchesButtonTarget.style.color = '#000'
    this.removeColorLinkTarget.classList.add('d-none')
    this.dispatch('colorRemoved')
  }
}
