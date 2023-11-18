class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, and :timeoutable
  devise :database_authenticatable, :jwt_authenticatable, :omniauthable,
         :registerable, :recoverable, :rememberable, :trackable, :validatable,
         jwt_revocation_strategy: self, omniauth_providers: %i[github]

  has_many :messages, dependent: :destroy

  def self.from_omniauth(auth)
    find_or_create_by(provider: auth.provider, uid: auth.uid) do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20]
    end
  end

  def self.new_with_session(params, session)
    super.tap do
      data = session['devise.github_data'] && session['devise.github_data']['extra']['raw_info']

      user.email = data['email'] if data && user.email.blank?
    end
  end

  def jwt_payload
    super.merge(email:)
  end

  def as_json(*_args)
    super(only: %i[id email])
  end
end
