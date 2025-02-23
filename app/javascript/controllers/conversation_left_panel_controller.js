import { Controller } from "@hotwired/stimulus"
import autoAnimate from '@formkit/auto-animate'

export default class ConversationLeftPanel extends Controller {
  static targets = ['collapseIcon', 'controls', 'conversationsIndex', 'listItem']

  activeConversationId = null

  connect() {
    autoAnimate(this.conversationsIndexTarget)


    this.observer = new MutationObserver((mutations) => {
      const listChanged = mutations.some(mutation => mutation.type === 'childList')

      if (listChanged) {
        this.setActiveConversation()
      }
    });

    this.observer.observe(this.conversationsIndexTarget, {
      subtree: true,
      childList: true
    });
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
    this.activeConversationId = e.detail.conversationId
    if (this.activeConversationId) {
      this.setActiveConversation()
    }
  }

  onNewConversation(){
    this.activeConversationId = null
    this.setActiveConversation()
  }

  setActiveConversation() {
    const activeConvo = this.listItemTargets.find(i => i.dataset.conversationId == this.activeConversationId)
    this.listItemTargets.forEach(i => i.classList.remove('text-bg-light'))
    if (activeConvo) {
      activeConvo.classList.add('text-bg-light')
    }
  }
}
