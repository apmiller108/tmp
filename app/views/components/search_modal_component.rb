# frozen_string_literal: true

class SearchModalComponent < ApplicationViewComponent
  attr_reader :path, :title

  def initialize(path:, title:)
    @path = path
    @title = title
  end
end
