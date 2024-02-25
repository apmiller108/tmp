module Flashable
  extend ActiveSupport::Concern
  def flash
    @flash ||= Struct.new(:alert, :notice).new
  end
end
