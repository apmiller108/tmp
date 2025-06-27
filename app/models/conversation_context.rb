class ConversationContext < ApplicationRecord
  validates :file_ref, :filename, presence: true

  enum :mime_type, {
    'text/csv' => 'text/csv',
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' => 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    'application/vnd.ms-excel' => 'application/vnd.ms-excel',
    'application/json' => 'application/json',
    'application/xml' => 'application/xml',
    'text/xml' => 'text/xml',
    'image/jpeg' => 'image/jpeg',
    'image/png' => 'image/png',
    'image/gif' => 'image/gif',
    'image/webp' => 'image/webp',
    'text/plain' => 'text/plain',
    'text/markdown' => 'text/markdown',
    'text/x-python' => 'text/x-python'
  }, validate: true

  enum :context_type, {
    file: 'file'
  }, validate: true
end
