class FlashMessageComponent < ApplicationViewComponent
  attr_reader :flash, :record, :auto_dismiss

  delegate :alert, :notice, to: :flash
  delegate :errors, to: :record, allow_nil: true

  def initialize(flash:, record: nil, auto_dismiss: nil)
    @flash = flash
    @record = record
    @auto_dismiss = auto_dismiss
  end

  def validation_errors?
    errors&.any?
  end

  def message
    notice || alert
  end

  def alert_class
    if notice
      'alert-info'
    else
      'alert-warning'
    end
  end
end
