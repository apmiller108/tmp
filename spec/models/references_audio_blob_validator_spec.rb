require 'rails_helper'

RSpec.describe ReferencesAudioBlobValidator do
  class MyModel
    include ActiveModel::Model
    validates_with ReferencesAudioBlobValidator
  end

  subject { MyModel.new }

  context 'when the model does not reference a blob' do
    it 'is not valid' do
      subject.validate
      expect(subject.errors.full_messages).to include 'Attachment must have audio content'
    end
  end

  context 'when the model references a blob' do
    blob = FactoryBot.build_stubbed :active_storage_blob
    before do
      subject.define_singleton_method(:active_storage_blob) { blob }
    end

    context 'when the blob does not have an audio content type' do
      it 'is not valid' do
        allow(blob).to receive(:audio?).and_return(false)
        subject.validate
        expect(subject.errors.full_messages).to include 'Attachment must have audio content'
      end
    end

    context 'when the blob has an audio content type' do
      it { is_expected.to be_valid }
    end
  end
end
