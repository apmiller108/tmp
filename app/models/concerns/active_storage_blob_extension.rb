module ActiveStorageBlobExtension
  extend ActiveSupport::Concern

  included do |base|
    base.const_set(:PLAIN_TEXT_ATTACHMENT_TEMPLATE, '%%JSON{{%<json>s}}')
    base.const_set(:PLAIN_TEXT_ATTACHMENT_PATTERN, /%JSON\{\{.+\}\}/)
    base.const_set(:PLAIN_TEXT_JSON_ATTACHMENT_PATTERN, /%JSON\{\{(?<json>.+)\}\}/)
    base.const_set(:WEBP_VARIANT_OPTS, {
      format: 'webp',
      saver: {
        strip: true,
        quality: 75,
        define: {
          webp: {
            lossless: false,
            alpha_quality: 85,
            thread_level: 1
          }
        }
      }
    })

    has_one :transcription_job, foreign_key: :active_storage_blob_id,
                                inverse_of: :active_storage_blob, dependent: :destroy
    has_one :transcription, foreign_key: :active_storage_blob_id,
                            inverse_of: :active_storage_blob, dependent: :destroy

    has_one :active_storage_blobs_generate_image_request, foreign_key: :active_storage_blob_id, dependent: :destroy,
                                                          inverse_of: :active_storage_blob
    has_one :generate_image_request, through: :active_storage_blobs_generate_image_request

    # rubocop:disable Rails/InverseOf
    has_one :rich_text_attachment, -> {
      where(name: 'embeds', record_type: 'ActionText::RichText')
    }, class_name: 'ActiveStorage::Attachment', dependent: nil
    # rubocop:enable Rails/InverseOf
    has_one :rich_text, through: :rich_text_attachment
    has_one :memo, through: :rich_text

    scope :audio, -> { where("content_type like 'audio/%'") }
    scope :image, -> { where("content_type like 'image/%'") }
    scope :audio_not_transcribed_for, ->(memo_id:) {
      audio
        .joins(attachments: { rich_text: :memo })
        .left_joins(:transcription)
        .where(memos: { id: memo_id }, transcriptions: { id: nil })
    }

    scope :associated_with_user, ->(user_id) {
      left_joins(:memo, :generate_image_request)
        .where(memo: { user_id: }).or(GenerateImageRequest.where(user_id:))
    }

    after_create_commit :associate_generated_image_to_request, if: ->(blob) { blob.generated_image? }

    def attachable_plain_text_representation(caption = nil)
      # rubocop:disable Style/FormatString
      caption || sprintf(self.class::PLAIN_TEXT_ATTACHMENT_TEMPLATE,
                         json: attributes.slice('id', 'content_type', 'filename').to_json)
      # rubocop:enable Style/FormatString
    end

    def associate_generated_image_to_request
      AssociateBlobToGenerateImageRequestJob.perform_async(id)
    end

    def generated_image?
      !!(image? && filename.base =~ /\Agenimage_.+/)
    end

    def original_lossless_generated_image_blob
      return unless generated_image?

      generate_image_request.image_blob
    end
  end
end
