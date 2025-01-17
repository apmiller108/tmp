module ApplicationHelper
  def temp_select_options
    GenerateTextRequest::TEMPERATURE_VALUES.map { |n| [n, n] }
  end
end
