import consumer from "./consumer"

consumer.subscriptions.create({ channel: "HelloChannel" }, {
  connected() {
    this.perform('hello')
  },
  received(data) {
    console.log(data)
  }
})
