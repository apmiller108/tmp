# frozen_string_literal: true

class MoreInfoComponent < ApplicationViewComponent
  attr_reader :id, :src

  def initialize(id:, src:)
    @id = id
    @src = src
  end

  def bs_content
    tag.turbo_frame(id:, src:, lazy: true) do
      tag.div(class: 'spinner-border text-primary my-3', role: :status) do
        tag.span(class: 'visually-hidden') { 'Loading...' }
      end
    end
  end
end
