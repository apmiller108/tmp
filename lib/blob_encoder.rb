module BlobEncoder
  module_function

  # @param [ActiveStorage::Blob] blob
  def encode64(blob)
    raise ArgumentError, 'File too large' if blob.byte_size > GenerateTextRequest::MAX_FILE_SIZE

    blob.open do |tempfile|
      Base64.strict_encode64(tempfile.read)
    end
  end
end
