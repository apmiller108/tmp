class FlashMessageComponent < ApplicationViewComponent
  attr_reader :flash, :record, :auto_dismiss

  CSS_CLASSES = {
    info: { alert: 'alert-info', icon: 'bi-info-square' },
    warning: { alert: 'alert-warning', icon: 'bi-exclamation-triangle' },
    success: { alert: 'alert-success', icon: 'bi-check-circle' }
  }.freeze

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
    notice || alert || flash[:success]
  end

  def alert_class
    css_classes.fetch(:alert)
  end

  def icon_class
    css_classes.fetch(:icon)
  end

  private

  def css_classes
    CSS_CLASSES.fetch(type, :info)
  end

  def type
    if notice
      :info
    elsif alert
      :warning
    elsif flash[:success]
      :success
    end
  end
end
