module ApplicationHelper
  def temp_select_options
    GenerateTextRequest::TEMPERATURE_VALUES.map { |n| [n, n] }
  end

  # @param [ActiveRecord, #dom_id]
  def list_dom_id(record)
    dom_id(record, 'list')
  end

  def tool_type_description(tool_type)
    case tool_type.to_sym
    when :image
      'Enable AI image generation capabilities for this conversation'
    else
      "Enable the #{tool_type.titleize} tools for this conversation"
    end
  end
end
