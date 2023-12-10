class HelloChannel < ApplicationCable::Channel
  def subscribed
    stream_from 'hello'
  end

  def foo(data)
    puts data
  end
end
