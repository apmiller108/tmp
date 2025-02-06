import { Controller } from "@hotwired/stimulus"
import { Popover } from 'bootstrap'

export default class GenerateTextRequestController extends Controller {
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

  moreInfoData() {
    const { model, preset, temperature, tokenCount } = this.element.dataset
    const entries = Object.entries({ model, preset, temperature, tokens: tokenCount }).filter(([, v]) => {
      return !!v
    })
    return Object.fromEntries(entries)
  }

  moreInfoTemplate() {
    return `
      <div class="details-fields p-0">
        ${Object.entries(this.moreInfoData()).map(([k, v]) => this.moreInfoField(k, v)).join("\n")}
      </diev>
    `
  }

  moreInfoField(key, value) {
    const label = String(key).charAt(0).toUpperCase() + String(key).slice(1)
    return `
      <div class="d-flex align-items-center justify-content-between">
        <span class="label me-1">${label}: </span>
        <pre class="value mb-0 p-1">${value}</pre>
      </div>
    `
  }
}
