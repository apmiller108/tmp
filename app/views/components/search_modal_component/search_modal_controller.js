import { Controller } from "@hotwired/stimulus"
import { Modal } from 'bootstrap'

export default class SearchModalController extends Controller {
  static targets = ['form', 'input', 'closeButton', 'modal']

  connect() {
    this.modal =  new Modal(this.modalTarget)
    document.addEventListener('keydown', this.handleKeydown.bind(this))
  }

  disconnect() {
    document.removeEventListener('keydown', this.handleKeydown.bind(this))
    this.modal.dispose()
  }

  search() {
    const query = this.inputTarget.value.trim()

    if (query.length === 0) {
      return
    }

    this.formTarget.requestSubmit()
  }

  close() {
    this.closeButtonTarget.click()
  }

  onModalShown(){
    this.inputTarget.focus()
  }

  handleKeydown(event) {
    // "/" as a shortcut (like GitHub, Slack) to open search modal
    if (event.key === "/" && !this.isInInputField(event.target)) {
      event.preventDefault()
      this.openModal()
    }
  }

  openModal() {
    this.modal.show()
  }

  isInInputField(elem) {
    return elem.isContentEditable ||
      elem.tagName === 'INPUT' ||
      elem.tagName === 'TEXTAREA' ||
      elem.tagName === 'SELECT'
  }
}
