import { Controller } from '@hotwired/stimulus'

export default class ConversationIndexLiteController extends Controller {
  static targets = ['item']

  onItemClick(e) {
    const item = e.currentTarget
    this.dispatch('itemClicked', {
      detail: {
        conversationId: item.dataset.conversationId,
        conversationTitle: item.dataset.conversationTitle
      }
    })
  }
}
