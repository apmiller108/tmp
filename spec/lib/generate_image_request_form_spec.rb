require 'rails_helper'

RSpec.describe GenerateImageRequestForm do
  subject(:form) { described_class.new(params) }

  let(:user) { build_stubbed :user }

  let(:valid_params) do
    {
      image_name: '1234abcd',
      style: GenerativeImage::Stability::STYLE_PRESETS.sample,
      dimensions: GenerativeImage::Stability::DIMENSIONS.sample,
      prompts: [
        { text: 'A golden retriever doggy sitting on a farm', weight: 1 },
        { text: 'Clouds in the sky', weight: -1 }
      ],
      user:
    }
  end

  describe 'validation' do
    context 'with valid params' do
      let(:params) { valid_params }

      it { is_expected.to be_valid }
    end

    context 'with invalid params' do
      let(:params) { {} }

      it { is_expected.not_to be_valid }

      it 'has proper validation errors' do
        form.valid?
        expect(form.errors.full_messages).to(
          contain_exactly(
            "Prompts can't be blank", "Image name can't be blank", 'Dimensions is not included in the list',
            'User must exist'
          )
        )
      end
    end
  end

  describe '#submit' do
    context 'with valid params' do
      subject(:form) { described_class.new(params).submit }

      let(:user) { create :user }
      let(:params) { valid_params }

      it 'returns self' do
        expect(form).to be_a described_class
      end

      it 'creates the generate_image_request record' do
        expect(form.generate_image_request).to be_persisted
      end

      it 'creates the prompts' do
        prompts = form.generate_image_request.prompts
        expect(prompts.map { |p| p.slice(:text, :weight) }).to contain_exactly(*valid_params[:prompts])
      end
    end

    context 'with invalid params' do
      subject { described_class.new(params).submit }

      let(:params) { {} }

      it { is_expected.to be false }
    end
  end
end
