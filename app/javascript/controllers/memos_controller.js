import { Controller } from "@hotwired/stimulus"
import consumer from '@javascript/channels/consumer'

export default class extends Controller {
  toBeSubscribedMemos = []
  subscriptions = []

  connect() {
    setInterval(() => this.subscribeToMemos(), 2000)
  }

  disconnect() {
    this.subscriptions.forEach(subscription => consumer.subscriptions.remove(subscription))
  }

  onMemoConnected(e) {
    this.toBeSubscribedMemos.push(e.detail.memoId);
  }

  subscribeToMemos() {
    const memoIds = [...this.toBeSubscribedMemos].filter(m => m)
    if (memoIds.length) {
      const subscription = consumer.subscriptions.create({ channel: 'MemoChannel', memo_ids: memoIds }, {
        received(data) {
          console.log(data)
        }
      })

      this.subscriptions.push(subscription)

      memoIds.forEach((id) => {
        const index = this.toBeSubscribedMemos.indexOf(id)
        delete this.toBeSubscribedMemos[index]
      });
    }
  }
}
