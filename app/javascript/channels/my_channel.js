import consumer from "./consumer"

consumer.subscriptions.create({ channel: "MyChannel" }, {
  connected() {
  },
  received(data) {
    console.log(data)
  }
})
