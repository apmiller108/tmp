module ActionTextRichTextExtension
  extend ActiveSupport::Concern

  included do
    # This supports doing active record joins to memo polymorphic
    # association (via record_id/record_type)
    # ex: `ActionText::RichText.joins(:memo))`
    has_one :self_ref, class_name: 'ActionText::RichText', foreign_key: :id
    has_one :memo, through: :self_ref, source: :record, source_type: 'Memo'
  end
end
