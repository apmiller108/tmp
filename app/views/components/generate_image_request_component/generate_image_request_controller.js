import { Controller } from "@hotwired/stimulus"
import { Popover, Tooltip } from 'bootstrap'

export default class GenerateImageRequestController extends Controller {
  static targets = ['moreInfo']

  connect() {
    const conversationElem = document.getElementById('conversation')
    if (this.hasMoreInfoTarget) {
      new Popover(this.moreInfoTarget, {
        content: this.moreInfoTemplate(),
        container: this.element,
        html: true,
        boundary: conversationElem,
        placement: 'right',
        fallbackPlacements: ['bottom', 'top']
      })
    }
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
}
