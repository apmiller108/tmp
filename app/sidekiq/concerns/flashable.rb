module Flashable
  extend ActiveSupport::Concern
  def flash
    @flash ||= Struct.new('Flash', :alert, :notice).new
  end
end
