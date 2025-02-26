import { Controller } from '@hotwired/stimulus'
import { ScrollSpy } from 'bootstrap'

export default class ScrollspyController extends Controller {
  connect() {
    const scrollableContainer = document.getElementById(this.containerId)
    this.scrollSpy = new ScrollSpy(scrollableContainer, {
      target: this.targetId,
      smoothScroll: true
    })

    this.observer = new MutationObserver((mutations) => {
      const navAdded = mutations.some(mutation => mutation.type === 'childList')

      if (navAdded) {
        this.refresh()
      }
    });

    this.observer.observe(this.element, {
      childList: true,
      subtree: true,
    });
  }

  disconnect() {
    this.observer.disconnect();
  }

  get containerId() {
    return this.element.dataset.containerId
  }

  get targetId() {
    return this.element.dataset.targetId
  }

  refresh() {
    this.scrollSpy.refresh()
  }
}
