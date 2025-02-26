import { Controller } from '@hotwired/stimulus'
import { ScrollSpy } from 'bootstrap'

export default class ScrollspyController extends Controller {
  connect() {
    const scrollableContainer = document.getElementById(this.containerId)
    this.scrollSpy = new ScrollSpy(scrollableContainer, {
      target: this.targetId,
      smoothScroll: true
    })
  }

  get containerId() {
    return this.element.dataset.containerId
  }

  get targetId() {
    return this.element.dataset.targetId
  }
}
