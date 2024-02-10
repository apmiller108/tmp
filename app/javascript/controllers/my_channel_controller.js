import { Controller } from '@hotwired/stimulus'
import consumer from '@javascript/channels/consumer'

export default class MyChannelController extends Controller {
  subscription

  connect() {
    const dispatch = this.dispatch.bind(this)
    this.subscription = consumer.subscriptions.create({ channel: 'MyChannel' }, {
      received(data) {
        const messageType = Object.keys(data)[0]
        switch (messageType) {
        case 'generate_text':
          dispatch("generateText", { detail: data })
          break;
        default:
          throw new Error(`Unkonwn message type: ${messageType}`)
        }
      }
    })
  }

  disconnect() {
    consumer.subscriptions.remove(this.subscription)
  }
}
