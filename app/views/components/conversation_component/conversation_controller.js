import { Controller } from '@hotwired/stimulus'
import ToolTippable from '@javascript/mixins/ToolTippable'

export default class ConversationController extends Controller {
  static targets = ['turns', 'titleField', 'editTitleForm', 'editTitleInput']

  observer;

  connect() {
    this.scrollTurns()

    // Check for changes in child nodes might affect the conversation container's height
    // When a conversation turn is added, scroll the container down so the new
    // turn is visiable without requiring manual scrolling
    this.observer = new MutationObserver((mutations) => {
      const turnAdded = mutations.some(mutation => mutation.type === 'childList')

      if (turnAdded) {
        this.scrollTurns()
      }
    });

    this.observer.observe(this.turnsTarget, {
      childList: true,
    });

    ToolTippable.connect.bind(this)()
  }

  disconnect() {
    this.observer.disconnect();
    ToolTippable.disconnect.bind(this)()
  }

  // Scrolls the turns container as far down as possible so the most recent turn
  // is in view
  scrollTurns() {
    this.turnsTarget.scrollTop = this.turnsTarget.scrollHeight
  }

  onEditTitle() {
    this.showTitleForm()
    this.editTitleInputTarget.focus()
  }

  showTitleForm() {
    this.editTitleFormTarget.classList.remove('d-none')
    this.titleFieldTarget.classList.add('d-none')
  }

  hideTitleForm() {
    // On blur if the element is not dirty just hide the form.
    // The change event (eg, element will be dirty) will submit the form, thereby replacing it
    if (this.editTitleInputTarget.value === this.editTitleInputTarget.defaultValue) {
      this.editTitleFormTarget.classList.add('d-none')
      this.titleFieldTarget.classList.remove('d-none')
    }
  }

  // On change event (blur and the value has changed) submits the form via turbo stream request
  saveTitle() {
    this.editTitleFormTarget.requestSubmit()
  }

  // On enter blue the input. If value changed, a change event will be emitted
  // thereby submitting the form; otherwise the form will be hidden without submitting the form
  blurTitle() {
    this.editTitleInputTarget.blur()
  }

  onGenerateText(event) {
    const { generate_text: { user_id, conversation_id, error }} = event.detail
    const editPath = `/users/${user_id}/conversations/${conversation_id}/edit`

    // If a new conversation was created, update the history state. Hate this.
    if (window.location.pathname === `/users/${user_id}/conversations/new`) {
      window.history.pushState('converstion', 'Edit Conversation', editPath);
    }
  }
}
