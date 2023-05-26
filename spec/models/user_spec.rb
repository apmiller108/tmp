require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) { build :user }

  describe '#jwt_payload' do
    it 'includes email' do
      expect(user.jwt_payload).to eq({ 'jti' => user.jti, email: user.email })
    end
  end

  describe '#as_json' do
    it 'only contains id and email' do
      expect(user.as_json).to eq({ 'id' => user.id, 'email' => user.email })
    end
  end
end
