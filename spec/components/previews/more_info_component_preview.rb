class MoreInfoComponentPreview < ViewComponent::Preview
  DEFAULT_PATH = 'rails/view_components/more_info_component/default'.freeze

  # This examples uses an image blob just for the src attribute
  def default
    blob = Memo.joins(:image_blobs).last.image_blobs.first
    render_with_template(locals: { blob: })
  end
end
