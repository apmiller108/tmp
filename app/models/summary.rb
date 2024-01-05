class Summary < ApplicationRecord
  include StatusEnumable

  belongs_to :summarizable, polymorphic: true, optional: false

  attribute :content, :string, default: ''

  def bullet_points?
    bullet_points.count > 1
  end

  def bullet_points
    content.split(/^\*\s/).delete_if(&:blank?).map(&:strip)
  end
end
