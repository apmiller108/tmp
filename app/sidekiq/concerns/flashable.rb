module Flashable
  def flash
    @flash ||= Struct.new(:alert, :notice).new
  end
end
