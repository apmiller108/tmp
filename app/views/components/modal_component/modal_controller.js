import { Controller } from "@hotwired/stimulus"
import autoAnimate from '@formkit/auto-animate'

export default class extends Controller {
  static targets = ['bodyTurboFrame', 'closeButton']

  observer = new MutationObserver((mutations) => {
    mutations.forEach((mutation) => {
      if (this.bodyTurboFrameTarget.innerHTML.trim() === '') {
        this.onCloseModal()
      }
    })
  })

  connect() {
    this.element.dataset.action = 'modal-opener:openModal@window->modal#onOpenModal modal-closer:closeModal@window->modal#onCloseModal'
    autoAnimate(this.bodyTurboFrameTarget)
    this.observer.observe(this.bodyTurboFrameTarget, { childList: true, subtree: true });
  }

  onOpenModal({ detail: { src }}) {
    this.bodyTurboFrameTarget.src = src
  }

  onCloseModal() {
    this.closeButtonTarget.click();
  }
}
