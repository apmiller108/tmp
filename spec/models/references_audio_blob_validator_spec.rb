require 'rails_helper'

RSpec.describe ReferencesAudioBlobValidator do
  let(:dummy_model) do
    Class.new do
      include ActiveModel::Model
      validates_with ReferencesAudioBlobValidator
    end
  end

  before do
    stub_const('DummyModel', dummy_model)
  end

  context 'when the model does not reference a blob' do
    it 'is not valid' do
      model = DummyModel.new
      model.validate
      expect(model.errors.full_messages).to include 'Attachment must have audio content'
    end
  end

  context 'when the model references a blob' do
    context 'when the blob does not have an audio content type' do
      let(:dummy_model) do
        Class.new do
          include ActiveModel::Model
          validates_with ReferencesAudioBlobValidator
          def active_storage_blob
            FactoryBot.build_stubbed :active_storage_blob, :image
          end
        end
      end

      it 'is not valid' do
        model = DummyModel.new
        model.validate
        expect(model.errors.full_messages).to include 'Attachment must have audio content'
      end
    end

    context 'when the blob has an audio content type' do
      let(:dummy_model) do
        Class.new do
          include ActiveModel::Model
          validates_with ReferencesAudioBlobValidator
          def active_storage_blob
            FactoryBot.build_stubbed :active_storage_blob, :audio
          end
        end
      end

      it 'is not valid' do
        stub_const('DummyModel', dummy_model)
        model = DummyModel.new
        expect(model).to be_valid
      end
    end
  end
end
