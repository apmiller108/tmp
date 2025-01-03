import { Controller } from '@hotwired/stimulus'
import ToolTippable from '@javascript/mixins/ToolTippable'

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
      childList: true,
    });

    ToolTippable.connect.bind(this)()
  }

  disconnect() {
    this.observer.disconnect();
    ToolTippable.disconnect.bind(this)()
  }

  scrollTurns() {
    this.turnsTarget.scrollTop = this.turnsTarget.scrollHeight
  }
}
