require 'rails_helper'

RSpec.describe Anthropic::FilesClient do
  let(:client) { described_class.new }
  let(:anthropic_key) { 'test_anthropic_key' }

  before do
    ENV['ANTHROPIC_KEY'] = anthropic_key
  end

  after do
    ENV.delete('ANTHROPIC_KEY')
  end

  describe '#initialize' do
    it 'sets the correct URL prefix' do
      expect(client.conn.url_prefix.to_s).to eq(Anthropic::HOST + '/')
    end

    it 'sets the x-api-key header' do
      expect(client.conn.headers['x-api-key']).to eq(anthropic_key)
    end

    it 'sets the anthropic-version header' do
      expect(client.conn.headers['anthropic-version']).to eq(Anthropic::VERSION)
    end

    it 'sets the anthropic-beta header' do
      expect(client.conn.headers['anthropic-beta']).to eq(Anthropic::FilesClient::BETA_VERSION)
    end
  end

  describe '#upload_file' do
    let(:file_path) { file_fixture('test_file.txt') }
    let(:uploaded_file) do
      Rack::Test::UploadedFile.new(file_path, 'text/plain', true)
    end
    let(:anthropic_response_body) do
      {
        'id' => 'file_abc123',
        'type' => 'file',
        'filename' => 'test_file.txt',
        'mime_type' => 'text/plain',
        'size_bytes' => 10,
        'created_at' => '2023-01-01T12:00:00Z'
      }
    end

    before do
      stub_request(:post, Anthropic::HOST + Anthropic::FilesClient::PATH)
        .to_return(status: 200, body: anthropic_response_body.to_json, headers: { 'Content-Type' => 'application/json' })
    end

    it 'uploads the file and returns a FileResponse object' do
      file_response = client.upload_file(uploaded_file)
      expect(file_response).to be_an_instance_of(Anthropic::FileResponse)
    end

    it 'closes and unlinks the tempfile' do
      expect(uploaded_file.tempfile).to receive(:unlink)
      client.upload_file(uploaded_file)
    end

    context 'when the API returns an error' do
      before do
        stub_request(:post, Anthropic::HOST + Anthropic::FilesClient::PATH)
          .to_return(status: 400, body: { error: { type: 'invalid_request_error', message: 'Bad request' } }.to_json)
      end

      it 'raises an Anthropic::InvalidRequestError' do
        expect { client.upload_file(uploaded_file) }.to raise_error(Anthropic::InvalidRequestError, 'Bad request')
      end
    end
  end

  describe '#list_files' do
    let(:anthropic_response_body) do
      {
        'data' => [
          {
            'id' => 'file_abc123',
            'type' => 'file',
            'filename' => 'document1.pdf',
            'mime_type' => 'application/pdf',
            'size_bytes' => 1000,
            'created_at' => '2023-01-01T12:00:00Z'
          }
        ]
      }
    end

    before do
      stub_request(:get, Anthropic::HOST + Anthropic::FilesClient::PATH)
        .to_return(status: 200, body: anthropic_response_body.to_json, headers: { 'Content-Type' => 'application/json' })
    end

    it 'returns an array of FileResponse objects' do
      file_responses = client.list_files
      expect(file_responses).to be_an(Array)
      expect(file_responses.first).to be_an_instance_of(Anthropic::FileResponse)
      expect(file_responses.first.filename).to eq('document1.pdf')
    end
  end

  describe '#get_file' do
    let(:file_id) { 'file_abc123' }
    let(:anthropic_response_body) do
      {
        'id' => file_id,
        'type' => 'file',
        'filename' => 'document.pdf',
        'mime_type' => 'application/pdf',
        'size_bytes' => 12_345,
        'created_at' => '2023-01-01T12:00:00Z'
      }
    end

    before do
      stub_request(:get, Anthropic::HOST + "#{Anthropic::FilesClient::PATH}/#{file_id}")
        .to_return(status: 200, body: anthropic_response_body.to_json, headers: { 'Content-Type' => 'application/json' })
    end

    it 'returns a single FileResponse object' do
      file_response = client.get_file(file_id)
      expect(file_response).to be_an_instance_of(Anthropic::FileResponse)
      expect(file_response.id).to eq(file_id)
    end

    context 'when the file is not found' do
      before do
        stub_request(:get, Anthropic::HOST + "#{Anthropic::FilesClient::PATH}/#{file_id}")
          .to_return(status: 404, body: { error: { type: 'not_found_error', message: 'File not found' } }.to_json)
      end

      it 'raises an Anthropic::NotFoundError' do
        expect { client.get_file(file_id) }.to raise_error(Anthropic::NotFoundError, 'File not found')
      end
    end
  end

  describe '#delete_file' do
    let(:file_id) { 'file_abc123' }
    let(:response_body) do
      {
        'id' => 'foo123',
        'type' => 'file_deleted'
      }.to_json
    end

    before do
      stub_request(:delete, Anthropic::HOST + "#{Anthropic::FilesClient::PATH}/#{file_id}")
        .to_return(status: 200, body: response_body, headers: { 'Content-Type' => 'application/json' })
    end

    it 'returns a FileResponse object on successful deletion' do
      result = client.delete_file(file_id)
      expect(result).to be_a Anthropic::FileResponse
    end

    context 'when the API returns an error' do
      before do
        stub_request(:delete, Anthropic::HOST + "#{Anthropic::FilesClient::PATH}/#{file_id}")
          .to_return(status: 400, body: { error: { type: 'invalid_request_error', message: 'Bad request' } }.to_json)
      end

      it 'raises an Anthropic::InvalidRequestError' do
        expect { client.delete_file(file_id) }.to raise_error(Anthropic::InvalidRequestError, 'Bad request')
      end
    end
  end
end
