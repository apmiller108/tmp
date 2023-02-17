# frozen_string_literal: true

class ItemComponent < ViewComponent::Base
  delegate :name, :done, to: :@item

  def initialize(item:)
    @item = item
  end
end
