import { Controller } from '@hotwired/stimulus'
import autoAnimate from '@formkit/auto-animate'

export default class ConversationController extends Controller {
  static targets = ['turns']

  observer;

  get conversationId() {
    return this.element.dataset.conversationId
  }

  connect() {
    autoAnimate(this.turnsTarget)

    this.scrollTurns()

    // Check for changes in child nodes might affect the conversation container's height
    // When a conversation turn is added, scroll the container down so the new
    // turn is visiable without requiring manual scrolling
    this.observer = new MutationObserver((mutations) => {
      const turnsChanged = mutations.some(mutation => mutation.type === 'childList')

      if (turnsChanged) {
        this.dispatch('turnsChanged')
        this.scrollTurns()
      }
    });

    this.observer.observe(this.turnsTarget, {
      childList: true,
      subtree: true
    });

    // Updates the browser history after creating a new conversation
    // Otherwise it stays /conversations/new. Was not able to make it work with
    // turbo-action.
    try {
      if (!this.conversationId) {
        console.warn('No conversation ID found');
        return;
      }

      const desiredPath = `/conversations/${this.conversationId}/edit`;

      if (window.location.pathname !== desiredPath) {
        const url = new URL(desiredPath, window.location.href)
        Turbo.navigator.history.push(url)
        window.history.pushState(history.state, '', url)
      }
    } catch (error) {
      console.error('Error updating pushState:', error);
    }

    this.dispatchConversationLoaded()
  }

  disconnect() {
    this.observer.disconnect();
  }

  dispatchConversationLoaded() {
    this.dispatch('conversationLoaded', { detail: { conversationId: this.conversationId } })
  }

  // Scrolls the turns container as far down as possible so the most recent turn
  // is in view
  scrollTurns() {
    this.element.scrollTop = this.element.scrollHeight
  }

  onPromptOptionsShow() {
    this.scrollTurns()
  }
}
