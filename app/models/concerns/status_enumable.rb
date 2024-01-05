module StatusEnumable
  extend ActiveSupport::Concern

  included do
    enum :status, {
      created: 'created',
      queued: 'queued',
      in_progress: 'in_progress',
      failed: 'failed',
      completed: 'completed'
    }, default: 'created'

    validates :status, inclusion: { in: statuses.values, message: "%<value>s must be one of #{statuses.values}" }
  end
end
