import { Controller } from '@hotwired/stimulus'
import { ScrollSpy } from 'bootstrap'

export default class ScrollspyController extends Controller {
  connect() {
    const conversation = document.getElementById('conversation_component')
    const scrollSpy = new ScrollSpy(conversation, {
      target: '#navbar-conversation'
    })
  }
}
