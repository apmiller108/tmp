# frozen_string_literal: true

class MessageFormComponent < ApplicationViewComponent
  attr_reader :message

  def initialize(message:)
    @message = message
  end

  def id
    dom_id(message)
  end

  def submit_value
    message.persisted? ? t('message.update') : t('message.create')
  end
end
