class HelloChannel < ApplicationCable::Channel
  def subscribed
    stream_from 'hello'
  end

  def hello(_data)
    ActionCable.server.broadcast('hello', { body: 'Hello World!' })
  end
end
