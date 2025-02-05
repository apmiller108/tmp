import { Controller } from '@hotwired/stimulus'
import TrixSelectors from '@wysiwyg/TrixSelectors'
import TrixConfiguration from '@wysiwyg/TrixConfiguration'
import { generateText, generateImage } from '@javascript/http'
import TurboScrollPreservation from '@javascript/TurboScrollPreservation'
import { initializeTooltipsFor } from '@javascript/mixins/ToolTippable'
import { createGenTextId, createGenImageId} from '@javascript/helpers'

export default class WysiwygEditor extends Controller {
  // This should be invoked as early as possible before the trix editor is
  // instantiated.
  static applyTrixCustomConfiguration() {
    const trixConfiguration = new TrixConfiguration
    trixConfiguration.initialize()
  }

  static targets = [
    'generateTextBtn', 'generateTextDialog', 'generateTextId', 'generateTextInput', 'generateTextSubmit',
    'generateTextTemperature', 'generateTextPreset', 'generateImageBtn', 'generateImageDialog',
    'generateImageName', 'generateImageSubmit', 'generateImagePrompt', 'generateImageNegativePrompt',
    'generateImageAspectRatio', 'aspectRatioExample', 'generateImageStyle', 'notification'
  ];

  editorElem;
  selectedText = ''

  get editorId() {
    return `trix_editor_${this.element.dataset.objectId}`
  }

  get editor() {
    return this.editorElem.editor
  }

  get generateImageStyleOptions() {
    return JSON.parse(this.element.dataset.styleOptions)
  }

  get generaeteImageAspectRatioOptions() {
    return JSON.parse(this.element.dataset.aspectRatioOptions)
  }

  get generateTextPresetOptions() {
    return JSON.parse(this.element.dataset.genTextPresetOptions)
  }

  get generateTextTemperatureOptions() {
    return JSON.parse(this.element.dataset.genTextTemperatureOptions)
  }

  get conversationId() {
    return this.element.dataset.conversationId
  }

  set conversationId(id) {
    this.element.dataset.conversationId = id
  }

  connect () {
    this.editorElem = this.element.querySelector(TrixSelectors.EDITOR)
    this.editorElem.id = this.editorId

    this.initScrollPreserveAndRestore()

    document.addEventListener(TrixConfiguration.selectionChange, this.onSelectionChange.bind(this))
  }

  disconnect() {
    document.removeEventListener(TrixConfiguration.selectionChange, this.onSelectionChange.bind(this))
  }

  initScrollPreserveAndRestore() {
    // Scroll position are cached for elements with data attribute `preserve-scroll` on certain turbo events
    this.editorElem.dataset.preserveScroll = true
    const turboScroll = new TurboScrollPreservation()
    if (turboScroll.scrollPosition(this.editorId)) {
      this.editorElem.scrollTop = turboScroll.scrollPosition(this.editorId)
    }
  }

  generateImageDialogTargetConnected(element) {
    initializeTooltipsFor(element)
  }

  generateImageStyleTargetConnected(element) {
    const options = this.generateImageStyleOptions.map((o) => this.optionForSelect(o))
    options.unshift('<option></option>')
    element.innerHTML = options.join("\n")
  }

  generateImageAspectRatioTargetConnected(element) {
    const options = this.generaeteImageAspectRatioOptions.map((o) => this.optionForSelect(o)).join("\n")
    element.innerHTML = options
  }

  generateTextPresetTargetConnected(element) {
    const options = this.generateTextPresetOptions.map((o) => this.optionForSelect(o))
    options.unshift('<option></option>')
    element.innerHTML = options.join("\n")

    // Automatically set the temperature select value to selected preset's temperature
    element.addEventListener('change', (e) => {
      const { temperature } = this.generateTextPresetOptions.find(o => o.value == e.target.value)
      this.generateTextTemperatureTarget.value = temperature
    });
  }

  generateTextTemperatureTargetConnected(element) {
    const options = this.generateTextTemperatureOptions.map((o) => this.optionForSelect(o)).join("\n")
    element.innerHTML = options
  }

  optionForSelect({ value, label, selected }) {
    return `<option value="${value}" label="${label}" ${selected ? 'selected' : '' }></option>`
  }

  onGenerateImageAspectRatioChange(e) {
    const aspectRatio = e.target.value.replace(":", "/")
    this.aspectRatioExampleTarget.style.aspectRatio = aspectRatio
  }

  onOpenGenerateTextDialog() {
    this.generateTextInputTarget.value = this.selectedText;
    this.generateTextInputTarget.focus()
  }

  onOpenGenerateImageDialog() {
    const promptInput = this.generateImagePromptTarget
    promptInput.value = this.selectedText;
    promptInput.focus()
  }

  onSelectionChange() {
    // Store the currently mouse-selected text
    this.selectedText = window.getSelection().toString()
  }

  async submitGenerateText() {
    const id = createGenTextId()

    if (!this.generateTextInputTarget.value.length) {
      return
    }

    this.generateTextIdTarget.value = id

    let response;
    try {
      this.setNotification('Generating text...')
      response = await generateText({
        prompt: this.generateTextInputTarget.value,
        text_id: this.generateTextIdTarget.value,
        temperature: this.generateTextTemperatureTarget.value,
        generate_text_preset_id: this.generateTextPresetTarget.value,
        conversation_id: this.conversationId
      })

      if (response.status === 401 || response.status === 403) {
        window.location = '/'
      }

      if (response.status === 422) {
        this.clearNotification()
      }

      if (response.ok || response.status === 422) {
        this.generateTextInputTarget.value = ''
        // Generated content is asynchronous. The use of renderStreamMessage is for
        // any turbo streams in the response (ie, flash message)
        const responseBody = await response.text()
        if (responseBody.length) {
          Turbo.renderStreamMessage(responseBody)
        }
      } else {
        throw new Error('Request to generate text was not successful')
      }
    } catch (err) {
      console.log(err)
      this.clearNotification()
      alert('Unable to generate text')
    }
  }

  async submitGenerateImage() {
    const id = createGenImageId()

    if (this.generateImagePromptTarget.value.length === 0) {
      return
    }

    this.generateImageNameTarget.value = id

    let response;
    try {
      this.setNotification('Generating image...')
      response = await generateImage({
        prompt: this.generateImagePromptTarget.value,
        negative_prompt: this.generateImageNegativePromptTarget.value,
        aspect_ratio: this.generateImageAspectRatioTarget.value,
        style: this.generateImageStyleTarget.value,
        image_name: this.generateImageNameTarget.value
      })

      if (response.status === 401 || response.status === 403) {
        window.location = '/'
      }

      if (response.status === 422) {
        this.clearNotification()
      }

      if (response.ok || response.status === 422) {
        this.generateImagePromptInputs.forEach(i => i.value = '')
        // Generated content is asynchronous. The use of renderStreamMessage is for
        // any turbo streams in the response (ie, flash message)
        const responseBody = await response.text()
        if (responseBody.length) {
          Turbo.renderStreamMessage(responseBody)
        }
      } else {
        throw new Error('Request to generate image was not successful')
      }
    } catch (err) {
      console.log(err)
      this.clearNotification()
      alert('Unable to generate text')
    }
  }

  get generateImagePromptInputs() {
    return [
      this.generateImagePromptTarget, this.generateImageNegativePromptTarget
    ]
  }

  /*
    Generate content event handlers:

    Content is generated asynchonously and delivered as JSON objects over
    websocket messages. Those JSON objects transmitted to the client via an
    ActionCable channel, emitted as CustomEvents which are handled here. I was
    unable to render turbo streams into the Trix editor; hence this hack that
    inserts the text or image with the Trix editor functions. Generated content
    is therefore inserted into the editor programatically.

    The notifcation is removed in a finally block.
  */
  onGenerateText(event) {
    const { generate_text: { text_id, content, conversation_id, error }} = event.detail
    // TODO store the selected range in an object with the text_id/image_id.
    // When inserting the generated content, place it at the cached location
    // const selectedRange = this.editor.getSelectedRange()
    try {
      if (!error && content) {
        this.editor.recordUndoEntry("InsertGenText")
        // Insert the content at the end of the selected range, with two line
        // breaks prepended. Add two line breaks after the inserted content.
        this.editor.setSelectedRange(this.editor.getSelectedRange()[1])
        this.editor.insertLineBreak()
        this.editor.insertLineBreak()

        // Convert backtics to `pre` elements for code blocks
        let formattedContent = content.replace(/```(.+)/g, "<pre>").replace(/```/g, '</pre>')
        this.editor.insertHTML(`🤖🤖🤖<br>${formattedContent}<br>🤖🤖🤖`)


        this.editor.setSelectedRange(this.editor.getSelectedRange()[1] + 1)
        this.editor.insertLineBreak()
        this.editor.insertLineBreak()

        this.dispatch('generatedTextInserted', { detail: { content, text_id, conversation_id } });
      }
    } catch (err) {
      console.log(err)
      alert('Unable to generate text')
    } finally {
      this.clearNotification()
    }
  }

  onConversationCreated(e) {
    const id = e.detail.conversationId
    this.conversationId = id
  }

  async onGenerateImage(event) {
    const { generate_image: { image_name, image, error, content_type } } = event.detail
    try {
      if (!error) {
        this.editor.recordUndoEntry("InsertGenImage")
        // Images are Base64 encoded and pushed in JSON objects over websockets. See comment above.
        const base64response = await fetch(`data:${content_type};base64,${image}`)
        const blob = await base64response.blob();
        const ext = content_type.split('/')[1]
        const filename = `${image_name}.${ext}`
        const file = new File([blob], filename, { type: content_type })
        // Insert the image at the end of the selected range, with a line break
        // prepended. Insert a line break after the image.
        this.editor.setSelectedRange(this.editor.getSelectedRange()[1])
        this.editor.insertLineBreak()
        this.editor.insertLineBreak()

        this.editor.insertFile(file)

        this.editor.setSelectedRange(this.editor.getSelectedRange()[1] + 1)
        this.editor.insertLineBreak()
        this.editor.insertLineBreak()

        this.dispatch('generatedImageInserted', { detail: { image_name } })
      } else if (error) {
        throw new Error('Job to generate image was not successful')
      }
    } catch (err) {
      console.log(err)
      alert('Unable to generate image')
    } finally {
      this.clearNotification()
    }
  }

  setNotification(text) {
    this.notificationTarget.textContent = text
    this.notificationTarget.classList.add('alert', 'alert-info', 'i-pulse')
  }

  clearNotification() {
    this.notificationTarget.textContent = ''
    this.notificationTarget.classList.remove('alert', 'alert-info', 'i-pulse')
  }
}
