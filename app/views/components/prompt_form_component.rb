# frozen_string_literal: true

class PromptFormComponent < ApplicationViewComponent
  attr_reader :conversation

  def initialize(conversation:)
    @conversation = conversation
  end
end
