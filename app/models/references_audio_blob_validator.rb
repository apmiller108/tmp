class ReferencesAudioBlobValidator < ActiveModel::Validator
  def validate(record)
    return if record.respond_to?(:active_storage_blob) && record.active_storage_blob.audio?
    record.errors.add :attachment, "must have audio content"
  end
end
