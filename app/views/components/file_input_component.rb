class FileInputComponent < ApplicationViewComponent
  attr_reader :form, :disabled

  def initialize(form:, disabled: true)
    @form = form
    @disabled = disabled
  end

  def action
    'direct-upload:start->file-input#onUploadStart '\
    'direct-upload:progress->file-input#onUploadProgress '\
    'direct-upload:end->file-input#onUploadEnd '\
    'direct-upload:error->file-input#onUploadError ' \
    'prompt-form:toggleFileInput@window->file-input#onToggleInput'
  end
end
