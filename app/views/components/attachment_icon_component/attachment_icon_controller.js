import { Controller } from '@hotwired/stimulus'
import { useHover } from 'stimulus-use'

export default class AttachmentIconController extends Controller {
  static targets = ['content']

  connect() {
    useHover(this, { element: this.element })
  }

  mouseEnter() {
    this.contentTarget.classList.remove('d-none')
  }

  mouseLeave() {
    this.contentTarget.classList.add('d-none')
  }
}
