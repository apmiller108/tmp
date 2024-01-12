import { Controller } from "@hotwired/stimulus"
import autoAnimate from '@formkit/auto-animate'

export default class extends Controller {
  static targets = ['bodyTurboFrame']

  connect() {
    autoAnimate(this.bodyTurboFrameTarget)
  }

  onOpenModal({ detail: { src }}) {
    this.bodyTurboFrameTarget.src = src
  }
}
