import { Controller } from "@hotwired/stimulus"
import autoAnimate from '@formkit/auto-animate'

export default class ConversationLeftPanel extends Controller {
  static targets = ['collapseIcon', 'controls', 'conversationsIndex']

  connect() {
    autoAnimate(this.conversationsIndexTarget)
  }

  onHidePanel() {
    this.controlsTarget.classList.add('panel-hide')
    this.collapseIconTarget.classList.remove('bi-arrows-collapse-vertical')
    this.collapseIconTarget.classList.add('bi-arrows-expand-vertical')
  }

  onShowPanel() {
    this.controlsTarget.classList.remove('panel-hide')
    this.collapseIconTarget.classList.remove('bi-arrows-expand-vertical')
    this.collapseIconTarget.classList.add('bi-arrows-collapse-vertical')
  }
}
