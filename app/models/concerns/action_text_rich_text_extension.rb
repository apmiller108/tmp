module ActionTextRichTextExtension
  extend ActiveSupport::Concern

  included do
    # This supports doing active record joins to memo polymorphic
    # association (via record_id/record_type)
    # ex: `ActionText::RichText.joins(:memo))`

    # rubocop:disable Rails/InverseOf
    has_one :self_ref, class_name: 'ActionText::RichText', foreign_key: :id, dependent: nil
    has_one :memo, through: :self_ref, source: :record, source_type: 'Memo'
    # rubocop:enable Rails/InverseOf
  end
end
