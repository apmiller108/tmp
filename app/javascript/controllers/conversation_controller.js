import { Controller } from '@hotwired/stimulus'
import { createUserConversation, updateUserConversation } from '@javascript/http'

export default class ConversationController extends Controller {
  static targets = ['turns']

  observer;

  connect() {
    this.userId = this.element.dataset.userId
    this.scrollTurns()

    this.observer = new MutationObserver((mutations) => {
      // Check for changes in child nodes might affect the conversation container's height
      const turnAdded = mutations.some(mutation => mutation.type === 'childList')

      // When a conversation turn is added, scroll the container down so the new turn is visiable without requiring manual scrolling
      if (turnAdded) {
        this.scrollTurns()
      }
    });

    // Configure and start the observer to watch for:
    // - Changes in child elements (childList)
    this.observer.observe(this.turnsTarget, {
      childList: true,
    });
  }

  disconnect() {
    observer.disconnect();
  }

  scrollTurns() {
    console.log('scrollTurns')
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
          if (response.redirected) { // redirects to edit after creating a new conversation
            window.location.href = response.url
          } else {
            body = await response.json()
          }
        }
        if (body) {
          Turbo.renderStreamMessage(body)
        }
      }
    } catch (err) {
      console.log(err)
      alert('An error occurred. Try again')
    } finally {
      // this.scrollTurns()
      // kill spinners
    }
  }
}
