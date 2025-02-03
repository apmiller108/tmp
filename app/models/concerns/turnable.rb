module Turnable
  extend ActiveSupport::Concern

  included do
    has_one :conversation_turn, as: :turnable, dependent: :destroy
    has_one :conversation, through: :conversation_turn

    delegate :conversation_id, to: :conversation_turn, allow_nil: true
  end
end
