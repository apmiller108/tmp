module ViewComponentBroadcaster
  module_function

  def call(streamables, component:, **options)
    Turbo::StreamsChannel.broadcast_action_to(
      streamables,
      target: component.id,
      content: component.render_in(ActionController::Base.new.view_context),
      **options
    )
  end
end
