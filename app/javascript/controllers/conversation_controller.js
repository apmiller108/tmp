import { Controller } from '@hotwired/stimulus'
import { createUserConversation, updateUserConversation } from '@javascript/http'

export default class ConversationsController extends Controller {
  static targets = ['turns']

  connect() {
    this.userId = this.element.dataset.userId
    this.scrollTurns()
  }

  scrollTurns() {
    this.turnsTarget.scrollTop = this.turnsTarget.scrollHeight
  }

  async onGenerateText(event) {
    const { generate_text: { text_id, content, error }} = event.detail

    try {
      if (!error && content) {
        const conversationParams = { text_id, assistant_response: content, user_id: this.userId }
        const conversationId = document.querySelector('input#generate_text_request_conversation_id').value
        let body;
        if (conversationId) {
          const response = await updateUserConversation({ conversation_id: conversationId, ...conversationParams })
          body = await response.text()
        } else {
          const response = await createUserConversation(conversationParams)
          body = await response.json()
        }
        Turbo.renderStreamMessage(body)
        this.scrollTurns()
      }
    } catch (err) {
      console.log(err)
      alert('An error occurred. Try again')
    } finally {
      // kill spinners
    }
  }
}
