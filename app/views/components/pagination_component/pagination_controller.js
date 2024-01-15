import { Controller } from "@hotwired/stimulus"
import autoAnimate from '@formkit/auto-animate'

export default class Pagination extends Controller {
  static turboStreamEvent = 'turbo:before-stream-render'

  containerElem = this.element.firstElementChild
  animation;

  connect() {
    this.animation = autoAnimate(this.containerElem)
    document.addEventListener(Pagination.turboStreamEvent, this.animationHandler.bind(this))
  }

  animationHandler(e) {
    const target = e.target.getAttribute('target')
    const action = e.target.getAttribute('action')

    // Disable animations when appending new items to the container. It doesn't
    // look good and makes the lazy loading turbo frames visible before they are
    // scrolled to. Keep animation enabled prepend and remove.
    if (target === this.containerElem.id && action === 'append') {
      const renderFunction = e.detail.render

      e.detail.render = async (streamElem) => {
        this.animation.disable()
        await renderFunction(streamElem)
        this.animation.enable()
      }
    }
  }

  disconnect() {
    document.removeEventListener(Pagination.turboStreamEvent, this.animationHandler.bind(this))
  }
}
