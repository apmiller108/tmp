module Gemini
  class FileResponse
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :id, :string # "files/..."
    attribute :filename, :string
    attribute :mime_type, :string
    attribute :size_bytes, :integer
    attribute :created_at, :datetime
    attribute :uri, :string
    attribute :state, :string

    def self.for(data)
      new(
        id: data['uri'], # Store URI as ID for ConversationContext file_ref compatibility
        filename: data['displayName'],
        mime_type: data['mimeType'],
        size_bytes: data['sizeBytes']&.to_i,
        created_at: data['createTime'],
        uri: data['uri'],
        state: data['state']
      )
    end
  end
end
