class FileInputComponentPreview < ViewComponent::Preview
  DEFAULT_PATH = 'rails/view_components/file_input_component/default'.freeze
  FILE_TYPES = %w[image/png].freeze
  MAX_SIZE = 300.kilobytes

  def default
    render_with_template(locals: { file_types: FILE_TYPES, max_size: MAX_SIZE })
  end
end
