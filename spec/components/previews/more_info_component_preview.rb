class MoreInfoComponentPreview < ViewComponent::Preview
  DEFAULT_PATH = 'rails/view_components/more_info_component/default'.freeze

  # This examples uses an image blob, but MoreInfoComponent can wrap anything
  def default
    blob = ActiveStorage::Blob.image.last
    render_with_template(locals: { blob: })
  end
end
