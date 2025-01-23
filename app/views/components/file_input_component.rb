class FileInputComponent < ApplicationViewComponent
  attr_reader :form

  def initialize(form:)
    @form = form
  end

  def action
    'direct-upload:start->file-input#onUploadStart '\
    'direct-upload:progress->file-input#onUploadProgress '\
    'direct-upload:end->file-input#onUploadEnd '\
    'direct-upload:error->file-input#onUploadError'
  end
end
