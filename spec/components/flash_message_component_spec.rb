require 'rails_helper'

RSpec.describe FlashMessageComponent, type: :component do
  let(:alert) { nil }
  let(:notice) { nil }
  let(:flash) { instance_double ActionDispatch::Flash::FlashHash, alert:, notice: }
  let(:validation_errors) { ['Error 1', 'Error 2'] }
  let(:errors) { instance_double(ActiveModel::Errors, full_messages: validation_errors) }
  let(:record) { double }

  context 'when flash has notice' do
    let(:notice) { 'This is a notice message.' }

    it 'renders an alert-info message' do
      render_inline(described_class.new(flash:))

      expect(page).to have_css('.alert-info', text: 'This is a notice message.')
    end
  end

  context 'when flash has alert' do
    let(:alert) { 'This is an alert message.' }

    it 'renders an alert-warning message' do
      render_inline(described_class.new(flash:))

      expect(page).to have_css('.alert-warning', text: 'This is an alert message.')
    end
  end

  context 'when record has validation errors' do
    let(:alert) { 'This is an alert message.' }

    before do
      allow(record).to receive(:errors).and_return(errors)
      allow(errors).to receive(:any?).and_return(true)
    end

    it 'renders validation error messages' do
      render_inline(described_class.new(flash:, record:))

      validation_errors.each do |e|
        expect(page).to have_css('.list-group-item-warning', text: e)
      end
    end
  end

  context 'when record does not have validation errors' do
    let(:alert) { 'This is an alert message.' }
    let(:validation_errors) { [] }

    before do
      allow(record).to receive(:errors).and_return(errors)
      allow(errors).to receive(:any?).and_return(false)
    end

    it 'does not render validation error messages' do
      render_inline(described_class.new(flash:, record:))

      expect(page).not_to have_css('.list-group-item-warning')
    end
  end
end
