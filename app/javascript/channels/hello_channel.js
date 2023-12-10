import consumer from "./consumer"

console.log(consumer);
consumer.subscriptions.create({ channel: "HelloChannel" }, {
  initialized() {
    console.log(this)
  },
  received(data) {
    console.log(data)
  }
})
