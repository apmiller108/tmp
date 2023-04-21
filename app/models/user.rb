class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable,
         :trackable, :validatable

  def generate_jwt
    JWT.encode(
      { email: email, exp: 30.days.from_now.to_i },
      Rails.application.secrets.secret_key_base,
      'HS256'
    )
  end
end
