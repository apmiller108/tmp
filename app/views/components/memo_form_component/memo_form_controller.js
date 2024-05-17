import { Controller } from "@hotwired/stimulus"
import { createConversation, updateConversation, getConversation, autoSaveMemo } from '@javascript/http'
import ToolTippable from '@javascript/mixins/ToolTippable'

export default class MemoFormController extends Controller {
  get memoId() {
    return this.element.dataset.memoId
  }

  set memoId(id) {
    this.element.dataset.memoId = id
  }

  get conversationId() {
    return this.element.dataset.conversationId
  }

  set conversationId(id) {
    this.element.dataset.conversationId = id
  }

  async connect() {
    ToolTippable.connect.bind(this)()

    // A new memo turbo stream created from an autosave action will not have the
    // conversation ID since the conversation creation happens after the memo is
    // created. In this case, fetch the converstation ID after the turbo stream
    // is handled and emit it for any listeners who depend on it (eg, wywiwyg
    // editor)
    if (this.memoId && !this.conversationId) {
      const conversation = await getConversation(this.memoId)
      if (conversation) {
        this.conversationId = conversation.id
        this.emitConversationCreated()
      }
    }
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
    const conversationParams = {
      text_id,
      assistant_response: content,
      memo_id: this.memoId
    }

    const autoSaveTurboStream = await this.autoSave()

    if (autoSaveTurboStream.length) {
      if (!conversationParams.memo_id) {
        // For new memos, there will not be a memo_id. After autosave completes,
        // however, the memo_id will exist. The memo_id is then extracted from
        // the tuboframe's form element and added to the conversation params.
        const tempTemplate = document.createElement('template')
        tempTemplate.innerHTML = autoSaveTurboStream
        conversationParams.memo_id = tempTemplate.content.querySelector('template')
                                                 .content.querySelector('form').dataset.memoId
      }

      await this.createOrUpdateConversation(conversationParams)

      Turbo.renderStreamMessage(autoSaveTurboStream)
    }
  }

  async onGeneratedImageInserted(e) {
    // TODO: figure out how to autosave. After this event, the file is direct
    // uploaded. Cannot save until the upload completed.
    console.log(e.detail)
  }

  async autoSave() {
    const form = this.formData()
    const memo = {
      id: this.memoId,
      title: form.get('memo[title]'),
      content: form.get('memo[content]'),
      color: form.get('memo[color]')
    }

    try {
      const response = await autoSaveMemo(memo)
      return await response.text()
    } catch (error) {
      console.log(error)
    }
  }

  async createOrUpdateConversation(params) {
    if (this.conversationId) {
      await updateConversation({ conversation_id: this.conversationId, ...params })
    } else {
      const response = await createConversation(params)
      const conversation = await response.json()
      this.conversationId = conversation.id
      this.emitConversationCreated()
    }
  }

  emitConversationCreated() {
    this.dispatch('conversationCreated', { detail: { conversationId: this.conversationId } });
  }

  formData() {
    return new FormData(this.element)
  }
}
