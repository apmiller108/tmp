require 'rails_helper'

RSpec.describe GenerateImageRequestForm do
  subject(:form) { described_class.new(params) }

  let(:user) { build_stubbed :user }

  let(:aspect_ratio) { GenerativeImage::Stability::ASPECT_RATIOS.sample }
  let(:style) { GenerativeImage::Stability::STYLE_PRESETS.sample }
  let(:valid_params) do
    {
      image_name: '1234abcd',
      style:,
      aspect_ratio:,
      prompt: 'A golden retriever doggy sitting on a farm',
      negative_prompt: 'Clouds in the sky',
      user:
    }
  end

  describe 'image_name' do
    subject(:form) { described_class.new({}).image_name }

    it { is_expected.not_to be_blank }
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
            "Prompt can't be blank", 'Aspect ratio is not included in the list', 'User must exist'
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
        expect(form.generate_image_request.attributes).to(
          include(
            'image_name' => '1234abcd',
            'options' => { 'aspect_ratio' => aspect_ratio, 'quality' => 'standard',
                           'request_type' => 'text_to_image', 'style' => style },
            'status' => 'created',
            'user_id' => user.id
          )
        )
      end

      it 'creates the prompts' do
        prompts = form.generate_image_request.prompts
        expect(prompts.map { |p| p.slice(:text, :weight) }).to(
          contain_exactly(
            {
              'text' => valid_params.fetch(:prompt), 'weight' => 1
            },
            {
              'text' => valid_params.fetch(:negative_prompt), 'weight' => -1
            }
          )
        )
      end

      context 'when the request_type is provided' do
        let(:valid_params) do
          {
            image_name: '1234abcd',
            style:,
            aspect_ratio:,
            prompt: 'A golden retriever doggy sitting on a farm',
            negative_prompt: 'Clouds in the sky',
            request_type: 'image_to_image',
            user:
          }
        end

        it 'creates the generate_image_request record with the given request_type' do
          expect(form.generate_image_request.attributes).to(
            include(
              'image_name' => '1234abcd',
              'options' => { 'aspect_ratio' => aspect_ratio, 'quality' => 'standard',
                             'request_type' => 'image_to_image', 'style' => style },
              'status' => 'created',
              'user_id' => user.id
            )
          )
        end
      end
    end

    context 'with a conversation' do
      let(:user) { create :user }
      let(:conversation) { create :conversation, user:, image_quality: 'high' }
      let(:params) { valid_params.merge conversation: }

      it 'creates a conversation turn' do
        expect { form.submit }.to change(conversation.turns, :count).by(1)
      end

      it 'uses the image quality from the conversation to override the default' do
        expect(form.generate_image_request.attributes).to(
          include(
            'image_name' => '1234abcd',
            'options' => { 'aspect_ratio' => aspect_ratio, 'quality' => 'high',
                           'request_type' => 'text_to_image', 'style' => style },
            'status' => 'created',
            'user_id' => user.id
          )
        )
      end
    end

    context 'with invalid params' do
      subject { described_class.new(params).submit }

      let(:params) { {} }

      it { is_expected.to be false }
    end
  end
end
