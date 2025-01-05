# Turbo stream broadcasts view components. The component should defined an +id+
# method which returns the dom target string that is operated upon (eg, update, replace, etc)
# Otherwise use the +target:* option.
module ViewComponentBroadcaster
  module_function

  def call(streamables, component:, target: nil, **options)
    Turbo::StreamsChannel.broadcast_action_to(
      streamables,
      target: target || component.id,
      content: ApplicationController.render(component, layout: false),
      **options
    )
  end
end
