class ClipboardComponentPreview < ViewComponent::Preview
  DEFAULT_PATH = 'rails/view_components/clipboard_component/default'.freeze
  def default
    render ClipboardComponent.new('my-clipboard') do |c|
      c.with_copyable do
        tag.input(type: :text, id: :copyable, data: { 'clipboard-target' => 'source' })
      end
    end
  end
end
