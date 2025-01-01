import { Controller } from '@hotwired/stimulus'
import { createUserConversation, updateUserConversation } from '@javascript/http'

export default class PromptFormController extends Controller {
  static targets = ['promptInput', 'userId', 'conversationId', 'form', 'submitButton', 'showOptionsInput']

  connect() {
    this.focusOnPromptInput()
    this.promptInputTarget.addEventListener('keypress', this.submitOnEnter.bind(this))
    this.formTarget.addEventListener('submit', this.disableForm.bind(this))
  }

  disconnect() {
    document.removeEventListener('keypress', this.submitOnEnter.bind(this))
    document.removeEventListener('submit', this.disableForm.bind(this))
  }

  focusOnPromptInput() {
    this.promptInputTarget.focus()
  }

  submitOnEnter(e) {
    if (this.formTarget.disabled) {
      return e.preventDefault()
    }
    if (e.key === "Enter" && !e.shiftKey) {
      e.preventDefault();
      this.formTarget.requestSubmit(); // requestSubmit instead of submit to submit turbo form
    }
  }

  disableForm() {
    this.formTarget.disabled = true
    this.submitButtonTarget.disabled = true
  }

  enableForm() {
    this.formTarget.disabled = false
    this.submitButtonTarget.disabled = false
  }

  async onGenerateText(event) {
    const { generate_text: { text_id, content, error }} = event.detail

    try {
      if (!error && content) {
        const conversationParams = { text_id, assistant_response: content, user_id: this.userIdTarget.value }
        const conversationId =  this.conversationIdTarget.value
        let body;

        // Create or Update a conversation
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
      this.enableForm()
    }
  }

  toggleShowOptions() {
    if (this.showOptionsInputTarget.value == 'true') {
      this.showOptionsInputTarget.value = 'false'
    } else {
      this.showOptionsInputTarget.value = 'true'
    }
    console.log(this.showOptionsInputTarget.value)
  }
}
