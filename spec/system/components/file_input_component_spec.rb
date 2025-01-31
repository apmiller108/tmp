require 'system_helper'

RSpec.describe 'FileInputComponent', type: :system, js: true do
  let(:max_size) { FileInputComponentPreview::MAX_SIZE }

  before do
    visit FileInputComponentPreview::DEFAULT_PATH
  end

  describe 'file upload behavior' do
    it 'handles valid file upload' do
      file_input = find('input[type="file"]')

      file_path = file_fixture('image.png')
      file_input.attach_file(file_path)

      expect(page).not_to have_css('.invalid-feedback', visible: true)
      expect(page).not_to have_css('input.is-invalid')
    end

    it 'validates file type restrictions' do
      file_input = find('input[type="file"]')

      # Attach a file with invalid file type (see FileInputComponentPreview::FILE_TYPES)
      file_path = Rails.root.join('spec/fixtures/files/test.pdf')
      file_input.attach_file(file_path)

      expect(page).to have_css('.invalid-feedback', text: 'Only PNG files are allowed')
      expect(page).to have_css('input.is-invalid')
    end
  end

  describe 'drag and drop behavior' do
    it 'shows drag and drop visual feedback' do
      file_input_container = find('.c-file-input')

      # Trigger dragover event
      file_input_container.execute_script("this.dispatchEvent(new Event('dragover'))")

      expect(page).to have_css('.c-file-input.border.border-secondary')

      # Trigger dragleave event
      file_input_container.execute_script("this.dispatchEvent(new Event('dragleave'))")

      expect(page).not_to have_css('.c-file-input.border.border-secondary')
    end
  end

  describe 'upload progress' do
    it 'shows upload progress bar during file upload' do
      file_input = find('input[type="file"]')
      progress_bar = find('.upload-progress')

      # Simulate upload start
      file_input.execute_script("this.dispatchEvent(new CustomEvent('direct-upload:start'))")

      expect(progress_bar['style']).to include('z-index: 2')

      # Simulate upload progress
      file_input.execute_script("
        this.dispatchEvent(new CustomEvent('direct-upload:progress', {
          detail: { progress: 50 }
        }))
      ")

      expect(progress_bar['style']).to include('width: 50%')

      # Simulate upload end
      file_input.execute_script("
        this.dispatchEvent(new CustomEvent('direct-upload:end'))
      ")

      expect(progress_bar['style']).to include('width: 0')
      expect(progress_bar['style']).not_to include('z-index: 2')
    end
  end

  describe 'input toggling' do
    it 'toggles input disabled state' do
      file_input = find('input[type="file"]')

      # Initially enabled
      expect(file_input).not_to be_disabled

      # Disable input
      page.execute_script("
        window.dispatchEvent(new CustomEvent('prompt-form:toggleFileInput', {
          detail: { disabled: false }
        }))
      ")

      expect(file_input).to be_disabled

      # Enable input
      page.execute_script("
        window.dispatchEvent(new CustomEvent('prompt-form:toggleFileInput', {
          detail: { disabled: true }
        }))
      ")

      expect(file_input).not_to be_disabled
    end
  end
end
