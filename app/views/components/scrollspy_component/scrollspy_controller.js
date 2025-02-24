import { Controller } from '@hotwired/stimulus'
import { ScrollSpy } from 'bootstrap'

export default class ScrollspyController extends Controller {
  connect() {
    const conversation = document.getElementById(this.containerId)
    const scrollSpy = new ScrollSpy(conversation, {
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
