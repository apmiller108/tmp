import { Controller } from '@hotwired/stimulus'
import { createUserConversation, updateUserConversation } from '@javascript/http'

export default class ConversationsController extends Controller {

  connect() {
    this.userId = this.element.dataset.userId
  }

  disconnect() {
  }

  async onGenerateText(event) {
    const { generate_text: { text_id, content, error }} = event.detail

    try {
      if (!error && content) {
        const conversationParams = { text_id, assistant_response: content, user_id: this.userId }
        const conversationId = document.querySelector('input#generate_text_request_conversation_id').value
        if (conversationId) {
          const response = await updateUserConversation({ conversation_id: conversationId, ...conversationParams })
          const body = await response.text()
          Turbo.renderStreamMessage(body)
        } else {
          const response = await createUserConversation(conversationParams)
          const body = await response.json()
          Turbo.renderStreamMessage(body)
        }
      }
    } catch (err) {
      console.log(err)
      alert('An error occurred. Try again')
    } finally {
      // kill spinners
    }
  }
}
