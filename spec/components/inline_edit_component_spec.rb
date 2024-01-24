# frozen_string_literal: true

require 'rails_helper'

RSpec.describe InlineEditComponent, type: :component do
  subject { page }

  let(:model) { build_stubbed(:user) }
  let(:attribute) { :foo }
  let(:field) { 'FIELD' }
  let(:component) do
    described_class.new(model:, attribute:).tap do |c|
      c.with_field_slot { field }
    end
  end

  describe '.turbo_frame_id' do
    context 'with a single model' do
      let(:dom_id) { ActionView::RecordIdentifier.dom_id(model) }

      it 'creates a unique frame id' do
        expect(described_class.turbo_frame_id(model, attribute)).to eq "turbo_frame_#{dom_id}_#{attribute}"
      end
    end

    context 'with an array of models' do
      let(:models) { [model, build_stubbed(:user)] }
      let(:dom_ids) { models.map { |m| ActionView::RecordIdentifier.dom_id(m) }.join('_') }

      it 'creates a unique frame id' do
        expect(described_class.turbo_frame_id(models, attribute)).to eq "turbo_frame_#{dom_ids}_#{attribute}"
      end
    end
  end

  describe 'render' do
    let(:model) { [build_stubbed(:user), build_stubbed(:memo)] }
    let(:turbo_frame_id) { 'turbo_frame_id' }

    before do
      allow(described_class).to receive(:turbo_frame_id).with(model, attribute).and_return(turbo_frame_id)
      render_inline component
    end

    it 'renders a form with a turbo_frame data tag' do
      expect(page).to have_css("form[action='#{polymorphic_path(model)}'][data-turbo-frame=#{turbo_frame_id}]")
    end

    it 'renders an inline edit turbo frame' do
      expect(page).to have_css("turbo-frame.inline-edit[id='#{turbo_frame_id}']")
    end

    it 'renders the field' do
      within('turbo-frame') do
        expect(page).to have_content field
      end
    end

    it 'renders an edit link' do
      within('turbo-frame') do
        expect(page).to have_link "#{I18n.t('edit')} #{attribute}", href: edit_polymorphic_path(model)
      end
    end
  end
end
