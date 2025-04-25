# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TranscriptionSummaryComponent, type: :component do
  subject { page }

  let(:user) { build_stubbed :user }
  let(:transcription) { build_stubbed :transcription, summary: }
  let(:summary) { build_stubbed :summary, content:, status: }
  let(:component) { described_class.new(transcription:) }

  context 'with a summary' do
    before do
      with_current_user(user) { render_inline(component) }
    end

    context 'when summary is being generated' do
      let(:content) { '' }
      let(:status) { Summary.statuses.slice(:created, :queued, :in_progress).values.sample }

      it { is_expected.to have_css '.alert-info', text: I18n.t('summary.generating') }
    end

    context 'when the summary has displayable content' do
      let(:content) { 'summary content' }
      let(:status) { Summary.statuses.slice(:completed, :in_progress).values.sample }

      it 'shows the summary content' do
        expect(page).to have_content(summary.content)
      end
    end
  end

  context 'when a summary does not exit' do
    let(:summary) { nil }

    before { with_current_user(user) { render_inline(component) } }

    it { is_expected.to have_button I18n.t('summary.create') }
  end
end
