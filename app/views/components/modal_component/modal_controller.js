import { Controller } from "@hotwired/stimulus"
import autoAnimate from '@formkit/auto-animate'

export default class extends Controller {
  static targets = ['title', 'bodyTurboFrame']

  connect() {
    autoAnimate(this.bodyTurboFrameTarget)
  }

  onOpenModal({ detail: { src, title }}) {
    this.titleTarget.textContent = title
    this.bodyTurboFrameTarget.src = src
  }
}
