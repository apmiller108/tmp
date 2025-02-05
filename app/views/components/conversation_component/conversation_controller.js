import { Controller } from '@hotwired/stimulus'

export default class ConversationController extends Controller {
  static targets = ['turns']

  observer;

  connect() {
    this.scrollTurns()

    // Check for changes in child nodes might affect the conversation container's height
    // When a conversation turn is added, scroll the container down so the new
    // turn is visiable without requiring manual scrolling
    this.observer = new MutationObserver((mutations) => {
      const turnAdded = mutations.some(mutation => mutation.type === 'childList')

      if (turnAdded) {
        this.scrollTurns()
      }
    });

    this.observer.observe(this.turnsTarget, {
      childList: true
    });
  }

  disconnect() {
    this.observer.disconnect();
  }

  // Scrolls the turns container as far down as possible so the most recent turn
  // is in view
  scrollTurns() {
    setTimeout(() => {
      this.element.scrollTop = this.element.scrollHeight
    }, 0)
  }

  onPromptOptionsShow() {
    this.scrollTurns()
  }
}
