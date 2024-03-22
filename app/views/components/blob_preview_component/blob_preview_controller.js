import { Controller } from '@hotwired/stimulus'

export default class BlobPreviewController extends Controller {
  static targets = ['image', 'spinner']

  initialize() {
    if (this.hasImageTarget) {
      if (this.imageIsLoaded()) {
        this.removeSpinner()
      } else {
        this.imageTarget.onload = this.removeSpinner.bind(this)
      }
    }
  }

  imageIsLoaded() {
    return this.imageTarget.complete || this.imageTarget.naturalWidth !== 0
  }

  removeSpinner() {
    if (this.hasSpinnerTarget) {
      this.spinnerTarget.remove()
    }
  }
}
