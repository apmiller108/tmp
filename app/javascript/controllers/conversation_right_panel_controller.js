import { Controller } from "@hotwired/stimulus"
import autoAnimate from '@formkit/auto-animate'

export default class ConversationRightPanel extends Controller {
  static targets = ['collapseIcon', 'controls', 'scrollspy', 'relatedChatsFrame']

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
    this.collapseIconTarget.classList.remove('bi-arrows-collapse-vertical')
    this.collapseIconTarget.classList.add('bi-arrows-expand-vertical')
  }

  onShowPanel() {
    this.controlsTarget.classList.remove('panel-hide')
    this.collapseIconTarget.classList.remove('bi-arrows-expand-vertical')
    this.collapseIconTarget.classList.add('bi-arrows-collapse-vertical')
  }

  onConversationLoaded(e) {
    const { conversationId } = e.detail
    if (conversationId) {
      const params = new URLSearchParams()
      params.append('q[order]', 'neighbor_distance asc')
      params.append('q[conversation_id]', conversationId)
      params.append('variant', 'readonly')
      this.relatedChatsFrameTarget.src = `/conversations?${params.toString()}`
      this.relatedChatsFrameTarget.classList.remove('d-none')
    }
  }
}
