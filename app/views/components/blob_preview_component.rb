# frozen_string_literal: true

class BlobPreviewComponent < ApplicationViewComponent
  attr_reader :blob

  delegate :image?, to: :blob

  def initialize(blob:)
    @blob = blob
  end

  def filename
    blob.filename.to_s[0, 15]
  end

  # rubocop:disable Metrics/MethodLength
  def variant_options
    {
      resize_to_limit: [100, 100],
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
      },
      format: 'webp'
    }
  end
  # rubocop:enable Metrics/MethodLength
end
