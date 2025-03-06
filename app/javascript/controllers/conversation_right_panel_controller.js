import { Controller } from "@hotwired/stimulus"
import autoAnimate from '@formkit/auto-animate'

export default class ConversationRightPanel extends Controller {
  static targets = ['collapseIcon', 'controls', 'scrollspy', 'scrollspyHeading']

  connect() {
    autoAnimate(this.scrollspyTarget)
    this.scrollScrollspyDown()
  }

  // Scroll the overflowed scrollspy nav items into view
  scrollScrollspyDown() {
    setTimeout(() => {
      this.scrollspyTarget.scrollTop = this.scrollspyTarget.scrollHeight
    }, 0)
  }

  onNavItemsChanged() {
    this.scrollScrollspyDown()
  }

  onHidePanel() {
    this.controlsTarget.classList.add('panel-hide')
    this.scrollspyHeadingTarget.classList.add('d-none')
    this.collapseIconTarget.classList.remove('bi-arrows-collapse-vertical')
    this.collapseIconTarget.classList.add('bi-arrows-expand-vertical')
  }

  onShowPanel() {
    this.controlsTarget.classList.remove('panel-hide')
    this.scrollspyHeadingTarget.classList.remove('d-none')
    this.collapseIconTarget.classList.remove('bi-arrows-expand-vertical')
    this.collapseIconTarget.classList.add('bi-arrows-collapse-vertical')
  }
}
