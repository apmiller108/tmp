import { Controller } from "@hotwired/stimulus"
import autoAnimate from '@formkit/auto-animate'

export default class extends Controller {
  static targets = ['bodyTurboFrame', 'closeButton']

  onOpenLister = 'modal-opener:openModal@window->modal#onOpenModal'
  onCloseListner = 'modal-closer:closeModal@window->modal#onCloseModal'
  observer = new MutationObserver((mutations) => {
    mutations.forEach((mutation) => {
      if (this.bodyTurboFrameTarget.innerHTML.trim() === '') {
        this.onCloseModal()
      }
    })
  })

  connect() {
    this.element.dataset.action = [this.onOpenLister, this.onCloseListner].join(' ')
    this.element.addEventListener('hide.bs.modal', e => this.reset(e));
    this.observer.observe(this.bodyTurboFrameTarget, { childList: true, subtree: true })

    autoAnimate(this.bodyTurboFrameTarget)
  }

  onOpenModal({ detail: { src }}) {
    this.bodyTurboFrameTarget.src = src
  }

  onCloseModal() {
    this.closeButtonTarget.click()
  }

  reset(_e) {
    delete this.bodyTurboFrameTarget.src
    this.bodyTurboFrameTarget.innerHTML = ''
  }
}
