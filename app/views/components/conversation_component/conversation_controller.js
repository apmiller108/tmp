import { Controller } from '@hotwired/stimulus'
import autoAnimate from '@formkit/auto-animate'

export default class ConversationController extends Controller {
  static targets = ['turns']

  observer;

  connect() {
    autoAnimate(this.turnsTarget)

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

    // This attempts to implement some browser history state management so a
    // back button results in a Turbo Stream request that updates only the
    // messagen leaves the state of the left panel intact. It only works when
    // nativating forward once and then back. If navigating forward more that
    // once, two requests are made: an HTML and the Turbo Stream
    try {
      const conversationId = this.element.dataset.conversationId;

      if (!conversationId) {
        console.warn('No conversation ID found');
        return;
      }

      const desiredPath = `/conversations/${conversationId}/edit`;

      if (window.location.pathname !== desiredPath) {
        const url = new URL(desiredPath, window.location.href)
        Turbo.navigator.history.push(url)
      }

      // Add popstate listener for handling back/forward navigation
      this.boundHandlePopState = this.handlePopState.bind(this);
      window.addEventListener('popstate', this.boundHandlePopState);

    } catch (error) {
      console.error('Error updating URL:', error);
    }
  }

  disconnect() {
    this.observer.disconnect();

    window.removeEventListener('popstate', this.boundHandlePopState);
    this.boundHandlePopState = null;
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

  async handlePopState(event) {
    event.preventDefault()
    event.stopPropagation()
    console.log('Starting popstate handling');

    try {
      console.log('Fetching content');
      const response = await fetch(window.location.href, {
        headers: {
          'Accept': 'text/vnd.turbo-stream.html'
        }
      });

      console.log('Content fetched');

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }

      const html = await response.text();
      console.log('preparing to render');

      console.log('Starting Turbo render');
      await Turbo.renderStreamMessage(html);

    } catch (error) {
      console.error('Error handling popstate:', error);
      Turbo.visit(window.location.href, { action: 'replace' });
    } finally {
      console.log('Finishing popstate handling');
    }
  }
}
