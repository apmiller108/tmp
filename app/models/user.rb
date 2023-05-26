class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable,
         :trackable, :validatable, :jwt_authenticatable, jwt_revocation_strategy: self

  def jwt_payload
    super.merge(email:)
  end

  def as_json(*_args)
    super(only: %i[id email])
  end
end
