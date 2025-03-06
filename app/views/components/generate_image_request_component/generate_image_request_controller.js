import { Controller } from "@hotwired/stimulus"
import { Popover, Modal } from 'bootstrap'

export default class GenerateImageRequestController extends Controller {
  static targets = ['moreInfo', 'image', 'spinner', 'modal', 'fullImage']

  connect() {
    if (this.hasMoreInfoTarget) {
      new Popover(this.moreInfoTarget, {
        content: this.moreInfoTemplate(),
        container: this.element,
        html: true,
        boundary: this.element,
        placement: 'top',
        fallbackPlacements: ['right', 'bottom']
      })
    }
  }

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
    this.imageTarget.classList.remove('d-none')
  }

  get moreInfoSrc() {
    return this.moreInfoTarget.dataset.src
  }

  moreInfoTemplate() {
    return `
      <turbo-frame id="blob_details" src="${this.moreInfoSrc}" loading="lazy">
        <div class="spinner-border text-primary" role="status">
          <span class='visually-hidden">Loading...</span>
        </div>
        Loading...
      </turbo-frame>
    `
  }

  expandImage() {
    const fullSizeUrl = this.imageTarget.dataset.originalUrl
    this.fullImageTarget.src = fullSizeUrl
    const modal = new Modal(this.modalTarget)
    modal.show()
  }
}
