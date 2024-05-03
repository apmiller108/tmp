# Turbo stream broadcasts view components. The component should defined an +id+
# method which returns the dom target string that is operated upon (eg, update, replace, etc)
module ViewComponentBroadcaster
  module_function

  def call(streamables, component:, **options)
    Turbo::StreamsChannel.broadcast_action_to(
      streamables,
      target: component.id,
      content: ApplicationController.render(component, layout: false),
      **options
    )
  end
end
