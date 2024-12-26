# frozen_string_literal: true

class GenerateTextRequest < ApplicationRecord

  MARKDOWN_FORMAT_SYSTEM_MESSAGE = <<~TXT
    You always answer the with markdown formatting which can inlcude headings,
    bold, italic, links, tables, lists, code blocks, and blockquotes.
  TXT

  belongs_to :user
  belongs_to :generate_text_preset, optional: true
  belongs_to :conversation, optional: true

  validates :text_id, presence: true, length: { maximum: 50 }
  validates :prompt, presence: true, length: { maximum: 24_000 }

  def conversation
    super || NullConversation.new
  end

  def system_message
    "#{MARKDOWN_FORMAT_SYSTEM_MESSAGE}\n#{generate_text_preset&.system_message}"
  end
end
