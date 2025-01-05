import { Controller } from "@hotwired/stimulus"
import { updateConversation, getConversations, autoSaveMemo } from '@javascript/http'
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

  get userId() {
    return this.element.dataset.userId
  }

  async connect() {
    ToolTippable.connect.bind(this)()

    // A newly created memo turbo stream created from an autosave action will
    // not have the conversation ID since the conversation will have been
    // created before the memo is created and therefore it will not yet be
    // associated to the memo yet. In this case, fetch the converstation ID
    // after the turbo stream is handled (rendered) and emit it for any
    // listeners who depend on it (eg, wywiwyg editor). See also
    // onGeneratedTextInserted callback below.
    if (this.memoId && !this.conversationId) {
      const conversations = await getConversations(this.userId, { memo_id: this.memoId })
      if (conversations.length == 1) {
        this.conversationId = conversations[0].id
        this.emitConversationCreated()
      }
    }
  }

  disconnect() {
    ToolTippable.disconnect.bind(this)()
  }

  async onSubmit() {
    await this.dispatch('memoFormSubmit')
    this.element.requestSubmit() // requestSubmit instead of submit to submit turbo form
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
    const { detail: { conversation_id } } = e
    const conversationParams = { memo_id: this.memoId, user_id: this.userId }

    this.conversationId = conversation_id
    const autoSaveTurboStream = await this.autoSave()
    const tempTemplate = document.createElement('template')
    tempTemplate.innerHTML = autoSaveTurboStream

    if (autoSaveTurboStream.length) {
      if (!conversationParams.memo_id) {
        // For new memos, there will not be a memo_id. After autosave completes,
        // however, the memo_id will exist. The memo_id is then extracted from
        // the tuboframe's form element and added to the conversation params in
        // order to associate the conversation to the memo.
        conversationParams.memo_id = tempTemplate.content.querySelector('template')
          .content.querySelector('form').dataset.memoId

        // Update conversation to associate it to the memo
        await updateConversation({ conversation_id: this.conversationId, ...conversationParams })
      }

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

  emitConversationCreated() {
    this.dispatch('conversationCreated', { detail: { conversationId: this.conversationId } });
  }

  formData() {
    return new FormData(this.element)
  }
}
