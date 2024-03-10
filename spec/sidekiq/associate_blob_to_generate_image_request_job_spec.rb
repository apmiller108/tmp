require 'rails_helper'

RSpec.describe AssociateBlobToGenerateImageRequestJob, type: :job do
  let(:filename) { 'genimage_1234.png' }

  let(:blob) { create :active_storage_blob, filename:, content_type: 'image/png' }
  let!(:generate_image_request) { create :generate_image_request, image_name: blob.filename.base }

  describe '#perform' do
    subject(:perform) { described_class.new.perform(blob.id) }

    it 'associates the blob to the generate image request' do
      expect { perform }.to change {
        blob.reload.generate_image_request
      }.from(nil).to(generate_image_request)
    end
  end
end
