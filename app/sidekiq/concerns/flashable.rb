module Flashable
  extend ActiveSupport::Concern
  Flash = Struct.new('Flash', :alert, :notice)

  def flash
    @flash ||= Flash.new
  end
end
