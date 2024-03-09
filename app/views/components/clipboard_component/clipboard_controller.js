import { Controller } from '@hotwired/stimulus'
import ToolTippable from '@javascript/mixins/ToolTippable'

export default class ClipBoardController extends Controller {
  static targets = ['button', 'source', 'copyIcon', 'successIcon']

  connect() {
    if('clipboard' in navigator) {
      this.buttonTarget.classList.remove('d-none')
      ToolTippable.connect.bind(this)()
    }
  }

  disconnect() {
    ToolTippable.disconnect.bind(this)()
  }

  copy() {
    const text = this.sourceTarget.value || this.sourceTarget.textContent
    navigator.clipboard.writeText(text)
    this.copySuccess()
  }

  copySuccess() {
    this.copyIconTarget.classList.add('d-none')
    this.successIconTarget.classList.remove('d-none')
    setTimeout(this.reset.bind(this), 1000)
  }

  reset() {
    this.copyIconTarget.classList.remove('d-none')
    this.successIconTarget.classList.add('d-none')
  }
}
