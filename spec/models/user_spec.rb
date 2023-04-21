require 'rails_helper'

RSpec.describe User, type: :model do
  describe '#generate_jwt' do
    let(:user) { build(:user, email: 'foo@example.com') }

    subject(:jwt) { user.generate_jwt }

    it 'returns a JWT with a payload containing the email' do
      payload = JWT.decode(jwt, Rails.application.secrets.secret_key_base, true, algorithm: 'HS256')[0]
      expect(payload['email']).to eq user.email
    end
  end
end
