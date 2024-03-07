class MoreInfoComponent < ApplicationViewComponent
  renders_one :wrapped

  attr_reader :id, :src

  def initialize(id:, src:)
    @id = id
    @src = src
  end
end
