import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ['title', 'bodyTurboFrame']

  onOpenModal({ detail: { src, title }}) {
    this.titleTarget.textContent = title
    this.bodyTurboFrameTarget.src = src
  }
}
