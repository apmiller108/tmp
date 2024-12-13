# frozen_string_literal: true

class PromptFormComponent < ApplicationViewComponent
  attr_reader :conversation

  def initialize(conversation:, disabled: false)
    @conversation = conversation
    @disabled = disabled
  end

  def disabled? = @disabled
end
