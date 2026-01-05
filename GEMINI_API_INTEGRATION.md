# Gemini API Integration Specifications

This document outlines the plan to integrate the Gemini API adapter into the existing Rails application, ensuring seamless user interaction for model selection, text generation, and file uploads.

## Analysis

### Current Architecture
1.  **Model Selection:**
    -   **UI:** `PromptFormComponent` uses `GenerativeText.active_models` to populate the model dropdown. Since Gemini models are now registered in `GenerativeText::MODELS`, they automatically appear in the UI.
    -   **Frontend:** `prompt_form_controller.js` handles file input toggling based on model capabilities (already supported via `model_data` serialization).
    -   **Settings:** User settings for default models (`User#setting.text_model`) are string-based and agnostic to the vendor.

2.  **Request Handling:**
    -   **Controller:** `ConversationsController` uses `ConversationForm` to process requests.
    -   **Form:** `ConversationForm` creates a `GenerateTextRequest` with the selected model.
    -   **Job:** `GenerateTextJob` executes the request in the background. It calls `GenerativeText.new.invoke_model(request)`.
    -   **Service:** `GenerativeText` delegates to the appropriate client (Anthropic or Gemini) based on the model's vendor.

3.  **File Uploads:**
    -   **Controller:** `ConversationContextsConversationsController` handles file uploads. Logic has been updated to use `Gemini.upload_file` when the user's preferred model is a Gemini model.
    -   **Context:** `ConversationContext` stores the file reference (URI for Gemini, ID for Anthropic) and mime type.

4.  **Response Handling:**
    -   **Job:** `GenerateTextJob` expects the response object to respond to `.data` (for storage) and `.content` (for broadcasting).
    -   **View:** `GenerateTextRequestComponent` renders the response content.

### Identified Gaps
1.  **Missing `data` Method:** `Gemini::InvokeModelResponse` does not expose the raw response data via a `data` method, which is required by `GenerateTextJob` to save the raw response to the database.

## Development Phases

### Phase 1: Fix Response Interface

**Goal:** Ensure `Gemini::InvokeModelResponse` adheres to the interface expected by `GenerateTextJob`.

- [x] Update `Gemini::InvokeModelResponse` to expose `@response_json` via a `data` method/attribute.
- [x] Add a spec to verify `data` returns the raw hash.

### Phase 2: User Interface Polish (Optional)

**Goal:** Improve visual distinction between models.

- [x] (Optional) Update `ConversationTurnComponent` or CSS to display vendor-specific icons (e.g., Google logo for Gemini) if desired. Currently, it uses a generic robot icon.

### Phase 3: End-to-End Verification

**Goal:** Verify the full flow from UI to Database.

- [x] Verify `GenerateTextJob` runs successfully with a Gemini model.
- [x] Verify `GenerateTextRequest` saves the raw Gemini JSON response in the `response` column.
- [x] Verify streaming works in the browser (simulated via system tests).

## TODOs

- [x] Fix `Gemini::InvokeModelResponse#data`.
- [x] Verify `GenerateTextJob` with Gemini model via console/test.

### Phase 4: Provider-Aware Conversation Contexts

**Goal:** Make `ConversationContext` explicitly aware of its provider to ensure only compatible contexts are used.

- [x] Add `vendor` column to `ConversationContext` table.
- [x] Update `ConversationContextsConversationsController#create` to determine and save the `vendor` when uploading a new file.
- [x] Update `InvokeModelRequest` for both `Anthropic` and `Gemini` to filter contexts based on the active model's vendor.

### Phase 5: Dynamic Context UI

**Goal:** Update the "Attach File" UI to dynamically show contexts that are compatible with the selected model.

- [x] Add a new route/action to fetch available `ConversationContext` records filtered by `vendor`.
- [x] Update `prompt_form_controller.js` to fetch and render the filtered context list when the model selection changes.
- [x] Create a Turbo Stream view to render the updated context list.
- [x] Add vendor badges to the context selection UI.
- [x] Allow uploading `.md` (markdown) files.

### Phase 6: Update Gemini Models

**Goal:** Update the Gemini model list to the latest models.

- [x] Update `lib/gemini.rb` with the latest model names and ensure they are marked as active.
- [x] Set max tokens to 65,536 for all models.


