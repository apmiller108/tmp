# Gemini API Adapter Specifications

This document outlines the plan to build an adapter to consume the Google Gemini API, achieving feature parity with the existing Anthropic API integration.

## Goals

1.  **Generate Text:** Support text generation with Gemini models. [DONE]
2.  **Multimodal:** Support file uploads (images, PDFs) and usage in requests. [DONE]
3.  **Tool Calling:** Support function calling (tools). [DONE]
4.  **Streaming:** Support streaming responses. [DONE]

## Architecture

The integration will follow the existing pattern used for Anthropic:
-   **Namespace:** `Gemini` module in `lib/gemini.rb` and `lib/gemini/`. [DONE]
-   **Client:** `Gemini::Client` to handle HTTP requests. [DONE]
-   **Request Object:** `Gemini::InvokeModelRequest` to format the payload. [DONE]
-   **Response Object:** `Gemini::InvokeModelResponse` and `Gemini::StreamResponse` to normalize outputs. [DONE]
-   **Turns:** `Gemini::Turn` to format conversation history. [DONE]
-   **Files:** `Gemini::FilesClient` for the Files API. [DONE]

## Development Phases

### Phase 1: Foundation & Text Generation

**Goal:** successfully generate text from a single prompt using a Gemini model.

- [x] Create `lib/gemini.rb` and `lib/gemini/client.rb`.
- [x] Implement `Gemini::Client#initialize` using `GEMINI_API_KEY`.
- [x] Define Gemini models in `lib/gemini.rb` (e.g., `gemini-3-flash-preview`, `gemini-2.5-pro`).
- [x] Update `GenerativeText::MODELS` to include Gemini models (vendor: `:google`).
- [x] Update `GenerativeText.client_for` to handle `:google` vendor.
- [x] Create `lib/gemini/invoke_model_request.rb` to format basic text prompts.
- [x] Create `lib/gemini/invoke_model_response.rb` to wrap the response.
- [x] Implement `Gemini::Client#invoke_model`.
- [x] Verify basic text generation in Rails console.

### Phase 2: Multi-turn Conversations (Chat)

**Goal:** Support conversation history.

- [x] Create `lib/gemini/turn.rb`.
- [x] Implement `Gemini::Turn.for(request, turns:)` to format `GenerateTextRequest` and history into Gemini's `contents` format (`role`, `parts`).
- [x] Update `GenerateTextRequest#to_turn` to handle `:google` vendor.
- [x] Update `Gemini::InvokeModelRequest` to accept and format the full conversation history.
- [x] Verify multi-turn chat in Rails console.

### Phase 3: Streaming

**Goal:** Support real-time response streaming.

- [x] Create `lib/gemini/stream_event.rb` to parse SSE chunks.
- [x] Create `lib/gemini/stream_response.rb` to aggregate chunks.
- [x] Implement `Gemini::Client#invoke_model_stream`.
- [x] Verify streaming works in the UI.

### Phase 4: Multimodal & Files

**Goal:** Support attaching images and PDFs to prompts.

- [x] Create `lib/gemini/files_client.rb` to wrap Gemini Files API (`upload`, `get`, `delete`).
- [x] Add `upload_file` and `delete_file` methods to `lib/gemini.rb`.
- [x] Update `Gemini::Turn` to include file parts in the content.
- [x] Verify image/PDF analysis.

### Phase 5: Tool Calling

**Goal:** Support defining and invoking tools.

- [x] Update `Gemini::InvokeModelRequest` to map `LlmTool` definitions to Gemini's `tools` -> `function_declarations` format.
- [x] Handle tool use responses in `Gemini::InvokeModelResponse`.
- [x] Verify the model can call tools (e.g., getting the weather, or whatever tools are defined).

### Phase 6: Polish & Testing

**Goal:** Ensure code quality and stability.

- [x] Add RSpec tests for `Gemini::Client`.
- [x] Add RSpec tests for `Gemini::Turn` and `Gemini::InvokeModelRequest`.
- [x] Add VCR cassettes for API interactions (using WebMock stubs in this implementation).
- [x] Ensure error handling (map Gemini errors to `Gemini::ClientError` equivalents).

## Reference: Data Structures

**Gemini Content Format:**
```json
{
  "role": "user",
  "parts": [
    { "text": "Hello" },
    { "file_data": { "mime_type": "...", "file_uri": "..." } }
  ]
}
```

**Gemini Tools Format:**
```json
{
  "function_declarations": [
    {
      "name": "get_weather",
      "description": "...",
      "parameters": { ... }
    }
  ]
}
```