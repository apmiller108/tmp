import { Controller } from "@hotwired/stimulus"
import autoAnimate from '@formkit/auto-animate'

export default class extends Controller {
  static targets = ['bodyTurboFrame', 'closeButton', 'header']

  onOpenListener = 'modal-opener:openModal@window->modal#onOpenModal'
  onCloseListener = 'modal-closer:closeModal@window->modal#onCloseModal'
  observer = new MutationObserver((mutations) => {
    mutations.forEach(() => {
      if (this.bodyTurboFrameTarget.innerHTML.trim() === '') {
        this.onCloseModal()
      }
    })
  })

  connect() {
    this.element.dataset.action = [this.onOpenListener, this.onCloseListener].join(' ')
    this.element.addEventListener('hide.bs.modal', e => this.reset(e));
    // Automatically close the modal if the body is blank (eg, on turbo deletion of a resource)
    this.observer.observe(this.bodyTurboFrameTarget, { childList: true, subtree: true })

    autoAnimate(this.bodyTurboFrameTarget)
  }

  onOpenModal({ detail: { modalSrc, modalHideHeader }}) {
    if (modalHideHeader) {
      this.headerTarget.classList.add('d-none')
    }
    this.bodyTurboFrameTarget.src = modalSrc
  }

  onCloseModal() {
    this.closeButtonTarget.click()
  }

  reset() {
    delete this.bodyTurboFrameTarget.src
    this.headerTarget.classList.remove('d-none')
    this.bodyTurboFrameTarget.innerHTML = ''
  }
}
