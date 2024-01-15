require 'rails_helper'

RSpec.describe PaginationComponent, type: :component do
  subject { page }

  let(:container_id) { 'list-container' }
  let(:cursor) { 10 }
  let(:user) { build_stubbed :user }
  let(:path) { [:user_memos_path, user] }

  before do
    render_inline component
  end

  context 'with container slot content' do
    let(:component) do
      described_class.new(container_id:, cursor:, path:).tap do |c|
        c.with_container { "<div id='#{container_id}'></div>".html_safe }
      end
    end
    let(:src) { "/users/#{user.id}/memos.turbo_stream" }

    it { is_expected.to have_css '#pagination-container[data-controller="pagination"]' }
    it { is_expected.to have_css "##{container_id}" }
    it { is_expected.to have_css "turbo-frame#pagination[src='#{src}'][loading='lazy']" }
    it { is_expected.to have_css '.spinner-border' }
  end

  context 'with list slot content' do
    let(:component) do
      described_class.new(container_id:, cursor:, path:).tap do |c|
        c.with_list { "<li id='list-item-1'>Item 1</li>".html_safe }
      end
    end

    it 'renders a turbo stream to append the list to the container' do
      expect(page).to have_css "turbo-stream[action='append'][target='#{container_id}']"
    end

    it 'renders a turbo stream to replace the pagination turbo frame' do
      expect(page).to have_css "turbo-stream[action='replace'][target='pagination']"
    end
  end

  context 'with both container and component slot content' do
    let(:component) do
      described_class.new(container_id:, cursor:, path:).tap do |c|
        c.with_list { 'LIST' }
        c.with_container { 'CONTAINER' }
      end
    end

    it 'does not render anything' do
      expect(page.text).to be_blank
    end
  end
end
