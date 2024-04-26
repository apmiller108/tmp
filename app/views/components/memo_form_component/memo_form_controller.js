import { Controller } from "@hotwired/stimulus"
import { createConversation, updateConversation } from '@javascript/http'
import ToolTippable from '@javascript/mixins/ToolTippable'

export default class MemoFormController extends Controller {
  get memoId() {
    return this.element.dataset.memoId
  }

  get conversationId() {
    return this.element.dataset.conversationId
  }

  set conversationId(id) {
    this.element.dataset.conversationId = id
  }

  connect() {
    ToolTippable.connect.bind(this)()
  }

  disconnect() {
    ToolTippable.disconnect.bind(this)()
  }

  async onSubmit() {
    await this.dispatch('memoFormSubmit')
    this.element.requestSubmit()
  }
  onColorChosen(e) {
    const hexColor = e.detail.color
    const r = parseInt(hexColor.substring(0, 2), 16);
    const g = parseInt(hexColor.substring(2, 4), 16);
    const b = parseInt(hexColor.substring(4, 6), 16);
    const rgb = [r, g, b].join(',')
    this.element.style.border = `0.25rem solid rgba(${rgb}, 0.8)`
    this.element.style.boxShadow = `0 0 0.5rem 0.5rem rgba(${rgb}, 0.5)`
  }

  onColorRemoved() {
    this.element.style.border = ''
    this.element.style.boxShadow = ''
  }

  async onGeneratedTextInserted(e) {
    const { detail: { text_id, content } } = e
    const params = {
      text_id,
      assistant_response: content,
      memo_id: this.memoId
    }
    if (this.conversationId) {
      updateConversation({ conversation_id: this.conversationId, ...params })
    } else {
      const response = await createConversation(params)
      const conversation = await response.json()
      this.conversationId = conversation.id
      this.dispatch('conversationCreated', { detail: { conversationId: this.conversationId } });
    }
  }
}
