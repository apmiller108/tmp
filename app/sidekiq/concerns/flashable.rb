module Flashable
  def flash
    @flash ||= Struct.new(:alert, :notice).new
  end

  def broadcast_flash_to_user(user:, message:, record: nil)
    flash.alert = message

    ViewComponentBroadcaster.call(
      [user, TurboStreams::STREAMS[:main]],
      component: FlashMessageComponent.new(flash:, record:),
      action: :update
    )
  end
end
