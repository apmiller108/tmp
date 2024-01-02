class Summary < ApplicationRecord
  belongs_to :summarizable, polymorphic: true, optional: false

  enum :status, {
    created: 'created',
    queued: 'queued',
    in_progress: 'in_progress',
    failed: 'failed',
    completed: 'completed'
  }, default: 'created'

  attribute :content, :string, default: ''

  def bullet_points?
    bullet_points.count > 1
  end

  def bullet_points
    content.split(/^\*\s/).delete_if(&:blank?).map(&:strip)
  end
end
