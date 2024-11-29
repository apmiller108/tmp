import { Controller } from '@hotwired/stimulus'

export default class ConversationsController extends Controller {
  connect() {
  }

  disconnect() {
  }

  onGenerateText(event) {
    console.log(event)
  }
}
