import { Controller } from '@hotwired/stimulus'
import { generateConversationTitle } from '../http'

export default class ConversationTitleGeneratorController extends Controller {
  static values = {
    conversationId: Number
  }

  async generateTitle(e) {
    this.element.classList.add('rotate-clockwise')
    this.element.disabled = true
    await generateConversationTitle(this.conversationIdValue)

    // Timeout after 30 seconds and reset button state
    setTimeout(() => {
      this.element.classList.remove('rotate-clockwise')
      this.element.disabled = false
    }, 30000)
  }
}
