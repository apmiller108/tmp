import { Controller } from '@hotwired/stimulus'

export default class ConversationsController extends Controller {
  // TODO: GenerateTextRequestsController responds with Turbo stream to append user content
  // TODO: onGenerateText updates conversation with assistant response. It responds with turbo stream to append assistant segment
  connect() {
  }

  disconnect() {
  }

  onGenerateText(event) {
    console.log(event)
  }
}
