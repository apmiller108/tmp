# app/models/anthropic/file_response.rb
module Anthropic
  class FileResponse
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :id, :string
    attribute :type, :string
    attribute :filename, :string
    attribute :mime_type, :string
    attribute :size_bytes, :integer
    attribute :created_at, :datetime
    attribute :downloadable, :boolean, default: false

    def self.for(data)
      if data['data'].respond_to?(:each)
        data['data'].map { |r| new(r) }
      else
        new(data)
      end
    end

    def file?
      type == 'file'
    end
  end
end
