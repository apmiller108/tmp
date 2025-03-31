# frozen_string_literal: true

class SearchModalComponent < ApplicationViewComponent
  attr_reader :path, :title

  def initialize(path:, title:, form_attrs: {})
    @path = path
    @title = title
    @form_attrs = form_attrs
  end

  def form_attrs
    {
      url: path, method: :get, data: { 'search-modal-target' => 'form' }
    }.deep_merge(@form_attrs)
  end
end
