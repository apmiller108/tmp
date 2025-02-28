import { Controller } from "@hotwired/stimulus"
import autoAnimate from '@formkit/auto-animate'

export default class ConversationRightPanel extends Controller {
  static targets = ['scrollspy']

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

  onTurnsChanged() {
    this.scrollScrollspyDown()
  }
}
