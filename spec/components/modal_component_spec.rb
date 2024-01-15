require 'rails_helper'

RSpec.describe ModalComponent, type: :component do
  describe 'class methods' do
    describe '.id' do
      subject { described_class.id }

      it { is_expected.to eq 'tmp-modal' }
    end

    describe '.turbo_frame_body_id' do
      subject { described_class.turbo_frame_body_id }

      it { is_expected.to eq 'tmp-modal-body' }
    end
  end

  describe 'rendered' do
    subject { page }

    let(:size) { nil }
    let(:component) { described_class.new(size:) }

    before { render_inline component }

    it { is_expected.to have_css '#tmp-modal.c-modal[data-controller="modal"]' }
    it { is_expected.not_to have_css 'h1.modal-title' }
    it { is_expected.not_to have_css '.modal-footer' }
    it { is_expected.to have_css 'button.btn-close[data-bs-dismiss="modal"]' }
    it { is_expected.to have_css 'turbo-frame#tmp-modal-body[loading="lazy"][data-modal-target="bodyTurboFrame"]' }
    it { is_expected.to have_css '.spinner-border' }

    context 'with a size option' do
      let(:size) { :xl }

      it 'sets the appropriate modal size based on the size option' do
        expect(page).to have_css ".modal-dialog.modal-#{size}"
      end
    end

    context 'with a title slot' do
      let(:title) { Faker::DcComics.title }
      let(:component) do
        described_class.new.tap do |c|
          c.with_title { title }
        end
      end

      it { is_expected.to have_css 'h1.modal-title', text: title }
    end

    context 'with a footer slot' do
      let(:footer) { 'FOOTER' }
      let(:component) do
        described_class.new.tap do |c|
          c.with_footer { footer }
        end
      end

      it { is_expected.to have_css '.modal-footer', text: footer }
    end
  end
end
