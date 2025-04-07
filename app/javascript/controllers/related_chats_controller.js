import { Controller } from "@hotwired/stimulus"
import { Modal } from 'bootstrap'

export default class RelatedChatsController extends Controller {
  static targets = ['item', 'modalFrame', 'modal', 'modalEditLink']

  showConversation(event) {
    event.preventDefault()

    const conversationId = event.currentTarget.dataset.conversationId
    const conversationTitle = event.currentTarget.dataset.conversationTitle

    // Set the modal title
    document.getElementById('relatedChatModalLabel').textContent = conversationTitle

    // Set the src attribute of the turbo frame to load the conversation content
    this.modalFrameTarget.src = `/conversations/${conversationId}/`
    this.modalEditLinkTarget.src = `/conversations/${conversationId}/edit`

    // Show the modal
    const modal = new Modal(this.modalTarget)
    modal.show()
  }
}
