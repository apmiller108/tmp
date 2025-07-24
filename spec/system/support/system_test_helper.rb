module SystemTestHelper
  # Creates and attaches a file with actual content to a file input element.
  #
  # This is an alternative to Capybara's attach_file method, which in system tests
  # creates file objects with 0 bytes of content. Zero-byte files can cause
  # JavaScript fetch requests to fail with "TypeError: Failed to fetch" errors
  # because browsers and servers may reject empty file uploads.
  #
  # This method programmatically creates a File object in the browser with real
  # content, properly sets it on the file input, and triggers the change event
  # to simulate user file selection.
  #
  # @param input_id [String] The DOM ID of the file input element
  # @param filename [String] The name for the created file (default: 'test.txt')
  # @param content [String] The content to put in the file (default: test content)
  # @param content_type [String] The MIME type of the file (default: 'text/plain')
  #
  # @example Basic usage
  #   attach_file_to_input(input_id: 'file-upload')
  #
  # @example With custom filename and content
  #   attach_file_to_input(
  #     input_id: 'document-upload',
  #     filename: 'report.txt',
  #     content: 'Quarterly sales report data...'
  #   )
  #
  # @example JSON file
  #   attach_file_to_input(
  #     input_id: 'json-upload',
  #     filename: 'data.json',
  #     content: '{"key": "value"}',
  #     content_type: 'application/json'
  #   )
  def attach_file_to_input(input_id:, filename: 'test.txt', content: nil, content_type: 'text/plain')
    default_content = 'This is a test file for upload testing.'
    file_content = content || default_content

    page.execute_script(<<~JS)
      const fileContent = #{file_content.to_json};

      const file = new File([fileContent], "#{filename}", {
        type: "#{content_type}",
        lastModified: Date.now()
      });

      const fileInput = document.getElementById("#{input_id}");
      if (!fileInput) {
        throw new Error(`File input with ID '${#{input_id}}' not found`);
      }

      // Create DataTransfer object to properly set files
      const dataTransfer = new DataTransfer();
      dataTransfer.items.add(file);
      fileInput.files = dataTransfer.files;

      // Trigger the change event to simulate user file selection
      const event = new Event('change', { bubbles: true });
      fileInput.dispatchEvent(event);
    JS
  end
end

RSpec.configure do |c|
  c.include SystemTestHelper, type: :system
end
