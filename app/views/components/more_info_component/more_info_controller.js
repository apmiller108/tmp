import { Controller } from "@hotwired/stimulus"

export default class MoreInfo extends Controller {
  static targets = ['content', 'button']

  connect() {
    document.addEventListener('click', this.hideContent.bind(this))
    // Adding action dynamically to bypass sanitizers (ie, Trix)
    this.buttonTarget.dataset.action = 'click->more-info#onClick'
  }

  disconnect() {
    document.removeEventListener('click', this.hideContent.bind(this))
  }

  onClick() {
    if (this.contentTarget.classList.contains('d-none')) {
      return this.contentTarget.classList.remove('d-none')
    }
    this.contentTarget.classList.add('d-none')
  }

  hideContent(e) {
    if (!this.element.contains(e.target)) {
      this.contentTarget.classList.add('d-none')
    }
  }
}
