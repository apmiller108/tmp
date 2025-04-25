class Summary < ApplicationRecord
  include StatusEnumable

  belongs_to :summarizable, polymorphic: true, optional: false

  attribute :content, :string, default: ''
end
