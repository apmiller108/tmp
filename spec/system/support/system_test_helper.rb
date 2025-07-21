module SystemTestHelper
  # An alternative to Capybara's attach_file which for some weird reason leaves
  # the input with a file of `0` size causing JS errors
  def attach_file_to_input(input_id:, filename: 'test.txt')
    page.execute_script(<<~JS)
      // Create file with actual text content
      const fileContent = 'This is a test file for upload testing.';

      const file = new File([fileContent], '#{filename}', {
        type: 'text/plain',
        lastModified: Date.now()
      });

      // Set the file on the input
      const fileInput = document.getElementById('#{input_id}');

      // Create DataTransfer object to properly set files
      const dataTransfer = new DataTransfer();
      dataTransfer.items.add(file);
      fileInput.files = dataTransfer.files;

      // Trigger the change event to start the upload
      const event = new Event('change', { bubbles: true });
      fileInput.dispatchEvent(event);
    JS
  end
end

RSpec.configure do |c|
  c.include SystemTestHelper, type: :system
end
