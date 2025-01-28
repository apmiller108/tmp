class FileInputComponent < ApplicationViewComponent
  attr_reader :form, :disabled, :file_types, :max_size

  def initialize(form:, disabled: false, file_types: [], max_size: 10.megabytes)
    @form = form
    @disabled = disabled
    @file_types = file_types
    @max_size = max_size
  end

  def action
    'direct-upload:start->file-input#onUploadStart '\
    'direct-upload:progress->file-input#onUploadProgress '\
    'direct-upload:end->file-input#onUploadEnd '\
    'direct-upload:error->file-input#onUploadError ' \
    'prompt-form:toggleFileInput@window->file-input#onToggleInput ' \
    'change->file-input#onChange'
  end

  def drop_action
    'dragover->file-input#onDragOver '\
    'dragleave->file-input#onDragLeave '\
    'drop->file-input#onDrop'
  end
end
