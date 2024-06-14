module ActionText
  class Content
    def render_attachments(**options, &block)
      content = fragment.replace(ActionText::Attachment.tag_name) do |node|
        puts '*' * 30
        p node
        # p node["content"]
        # p sanitize_content_attachment(node["content"])
        node["content"] = sanitize_content_attachment(node["content"])
        p node
        node.delete("content")
        block.call(attachment_for_node(node, **options))
      end
      self.class.new(content, canonicalize: false)
    end
  end
end
