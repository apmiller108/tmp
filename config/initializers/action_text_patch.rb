module ActionText
  class Content
    # Update to 7.1.3.4 prevents images from being rendered (and probably more)
    # See https://github.com/rails/rails/issues/52127
    def render_attachments(**options, &block)
      content = fragment.replace(ActionText::Attachment.tag_name) do |node|
        if node.key? 'content'
          node['content'] = sanitize_content_attachment(node['content'])
        end
        block.call(attachment_for_node(node, **options))
      end
      self.class.new(content, canonicalize: false)
    end
  end
end
