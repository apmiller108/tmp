module ApplicationHelper
  def temp_select_options
    GenerateTextRequest::TEMPERATURE_VALUES.map { |n| [n, n] }
  end

  # @param [ActiveRecord, #dom_id]
  def list_dom_id(record)
    dom_id(record, 'list_')
  end
end
