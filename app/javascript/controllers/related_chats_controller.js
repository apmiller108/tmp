import { Controller } from "@hotwired/stimulus"
import { Modal } from 'bootstrap'

export default class RelatedChatsController extends Controller {
  static targets = ['modalTitle', 'modalFrame', 'modal', 'modalEditLink', 'modalContent', 'turboFrame']

  conversationId;
  modal;

  connect() {
    this.conversationId = this.element.dataset.conversationId
    this.modal = new Modal(this.modalTarget)
  }

  showConversation(event) {
    event.preventDefault()

    const conversationId = event.detail.conversationId
    const conversationTitle = event.detail.conversationTitle

    // Set the modal title
    this.modalTitleTarget.textContent = conversationTitle

    // Set the src attribute of the turbo frame to load the conversation content
    this.modalFrameTarget.src = `/conversations/${conversationId}/`
    this.modalEditLinkTarget.href = `/conversations/${conversationId}/edit`

    // Show the modal
    this.modal.show()
  }

  hideConversation() {
    this.modal.hide()
  }

  onConversationLoaded(e) {
    this.conversationId = e.detail.conversationId
    if (this.conversationId) {
      const url = new URL(this.turboFrameTarget.src)
      url.searchParams.set('q[conversation_id]', this.conversationId)
      this.turboFrameTarget.src = url.toString()
      this.element.classList.remove('d-none')
    } else {
      // When new conversation, don't show related chats
      this.element.classList.add('d-none')
    }
  }

  onEditLinkClick() {
    this.hideConversation()
  }

  reload(e) {
    if (this.conversationId == e.detail.embedding_created.conversation_id) {
      this.turboFrameTarget.reload()
    }
  }

  toggleModalSize() {
    if (this.modalContentTarget.classList.contains('modal-lg')) {
      this.modalContentTarget.classList.remove('modal-lg')
      this.modalContentTarget.classList.add('modal-fullscreen')
    } else {
      this.resetModalSize()
    }
  }

  resetModalSize() {
    this.modalContentTarget.classList.remove('modal-fullscreen')
    this.modalContentTarget.classList.add('modal-lg')
  }
}
