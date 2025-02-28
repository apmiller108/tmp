import { Controller } from '@hotwired/stimulus'
import { ScrollSpy } from 'bootstrap'

export default class ScrollspyController extends Controller {
  static targets = ['navItem']

  get containerId() {
    return this.element.dataset.containerId
  }

  get targetId() {
    return this.element.dataset.targetId
  }

  connect() {
    const scrollableContainer = document.getElementById(this.containerId)
    this.scrollSpy = new ScrollSpy(scrollableContainer, {
      target: this.targetId,
      smoothScroll: true,
      threshold: [0, 0.25, 0.5, 0.75, 1]
    })
  }

  navItemTargetConnected(element) {
    this.refresh();
    this.dispatch('navItemsChanged')
  }

  navItemTargetDisconnected(element) {
    this.refresh();
  }

  refresh() {
    setTimeout(() => this.scrollSpy?.refresh(), 0)
  }
}
