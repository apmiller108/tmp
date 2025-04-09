import { Controller } from "@hotwired/stimulus"
import { Modal } from 'bootstrap'

export default class RelatedChatsController extends Controller {
  static targets = ['item', 'modalFrame', 'modal', 'modalEditLink', 'turboFrame']

  conversationId;

  connect() {
    this.conversationId = this.element.dataset.conversationId
  }

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

  onConversationLoaded(e) {
    this.conversationId = e.detail.conversationId
    if (this.conversationId) {
      const url = new URL(this.element.src)
      url.searchParams.set('q[conversation_id]', this.conversationId)
      this.turboFrameTarget.src = url.toString()
      this.turboFrameTarget.classList.remove('d-none')
    } else {
      // When new conversation, don't show related chats
      this.element.classList.add('d-none')
    }
  }

  reload(e) {
    if (this.conversationId == e.detail.embedding_created.conversation_id) {
      this.element.reload()
    }
  }
}
