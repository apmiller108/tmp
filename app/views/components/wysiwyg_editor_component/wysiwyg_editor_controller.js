import { Controller } from '@hotwired/stimulus'
import TrixSelectors from '@wysiwyg/TrixSelectors'
import TrixConfiguration from '@wysiwyg/TrixConfiguration'
import { generateText, generateImage } from '@javascript/http'
import TurboScrollPreservation from '@javascript/TurboScrollPreservation'

export default class WysiwygEditor extends Controller {
  // This should be invoked as early as possible before the trix editor is
  // instantiated.
  static applyTrixCustomConfiguration() {
    const trixConfiguration = new TrixConfiguration
    trixConfiguration.initialize()
  }

  static targets = [
    'generateTextBtn', 'generateTextDialog', 'generateTextId', 'generateTextInput', 'generateTextSubmit',
    'generateImageBtn', 'generateImageDialog', 'generateImageId', 'generateImageSubmit', 'generateImagePromptGroup',
    'generateImageDimensions', 'generateImageStyle'
  ];

  editorElem;
  selectedText;

  get editorId() {
    return `trix_editor_${this.element.dataset.objectId}`
  }

  get editor() {
    return this.editorElem.editor
  }

  get generateImageStyleOptions() {
    return JSON.parse(this.element.dataset.styleOptions)
  }

  get generateImageDimensionsOptions() {
    return JSON.parse(this.element.dataset.dimensionOptions)
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

  generateImageStyleTargetConnected(element) {
    const options = this.generateImageStyleOptions.map((o) => this.optionForSelect(o)).join("\n")
    element.innerHTML = options
  }

  generateImageDimensionsTargetConnected(element) {
    const options = this.generateImageDimensionsOptions.map((o) => this.optionForSelect(o)).join("\n")
    element.innerHTML = options
  }

  optionForSelect({ value, label, selected }) {
    return `<option value="${value}" label="${label}" ${selected ? 'selected' : '' }></option>`
  }

  onOpenGenerateTextDialog() {
    this.generateTextInputTarget.value = this.selectedText;
    this.generateTextInputTarget.focus()
  }

  onOpenGenerateImageDialog() {
    const promptInput = this.generateImagePromptInputs.pop()
    promptInput.value = this.selectedText;
    promptInput.focus()
  }

  onSelectionChange() {
    // Store the currently mouse-selected text
    this.selectedText = window.getSelection().toString()
  }

  async submitGenerateText(e) {
    const { params: { type } } = e
    const id = this.createGenerativeId(`gen${type}`)

    if (!this.generateTextInputTarget.value.length) {
      return
    }

    this.generateTextIdTarget.value = id

    this.insertGenerativePlaceholder(id, type)

    let response;
    try {
      response = await generateText({
        prompt: this.generateTextInputTarget.value,
        text_id: this.generateTextIdTarget.value
      })

      if (response.status === 401 || response.status === 403) {
        window.location = '/'
      }

      if (response.status === 422) {
        const placeHolderDiv = document.getElementById(id)
        placeHolderDiv?.parentElement?.remove()
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

      // Remove the placeholder attachment figure
      const placeHolderDiv = document.getElementById(id)
      placeHolderDiv?.parentElement?.remove()
      alert('Unable to generate text')
    }
  }

  async submitGenerateImage(e) {
    const { params: { type } } = e
    const id = this.createGenerativeId(`gen${type}`)

    if (this.generateImagePromptInputs.some(i => i.value.length === 0)) {
      return
    }

    this.generateImageIdTarget.value = id

    this.insertGenerativePlaceholder(id, type)

    let response;
    try {
      const prompts = this.generateImagePromptGroupTargets.map((g) => {
        return {
          text: g.querySelector('input').value,
          weight: g.querySelector('select[name="weight"]').value
        }
      })
      response = await generateImage({
        prompts,
        dimensions: this.generateImageDimensionsTarget.value,
        style: this.generateImageStyleTarget.value,
        image_id: this.generateImageIdTarget.value
      })

      if (response.status === 401 || response.status === 403) {
        window.location = '/'
      }

      if (response.status === 422) {
        const placeHolderDiv = document.getElementById(id)
        placeHolderDiv?.parentElement?.remove()
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

      // Remove the placeholder attachment figure
      const placeHolderDiv = document.getElementById(id)
      placeHolderDiv?.parentElement?.remove()
      alert('Unable to generate text')
    }
  }

  get generateImagePromptInputs() {
    return this.generateImagePromptGroupTargets.map(g => g.querySelector('input'))
  }

  /*
    Generate content event handlers:

    Content is generated asynchonously and delivered as JSON objects over
    websocket messages. Those JSON objects are received by an ActionCable
    channel, emitted as CustomEvents and handled here. I was unable to render
    turbo streams into the Trix editor.

    Generated content is inserted into the editor programatically. First,
    determine if the placeholder is still present. It could have been removed by
    the user by this point in which case inserting the generated text is
    aborted.

    This placeholder is removed in a finally block. It must be re-queried for some reason.
  */
  onGenerateText(event) {
    const { generate_text: { text_id, content, error }} = event.detail
    const selectedRange = this.editor.getSelectedRange()
    const placeHolderDiv = document.getElementById(text_id)
    try {
      if (placeHolderDiv && !error) {
        this.editor.recordUndoEntry("InsertGenText")
        this.editor.setSelectedRange(selectedRange[0])
        this.editor.insertString(content)
      }
    } catch (err) {
      console.log(err)
      alert('Unable to generate text')
    } finally {
      document.getElementById(text_id).parentElement.remove()
    }
  }

  async onGenerateImage(event) {
    const { generate_image: { image_id, image, error }} = event.detail
    const selectedRange = this.editor.getSelectedRange()
    const placeHolderDiv = document.getElementById(image_id)
    try {
      if (placeHolderDiv && !error) {
        this.editor.recordUndoEntry("InsertGenImage")
        this.editor.setSelectedRange(selectedRange[0])

        // Images are Base64 encoded and pushed in JSON objects over websockets. See comment above.
        const base64response = await fetch(`data:image/png;base64,${image}`)
        const blob = await base64response.blob();
        const file = new File([blob], image_id, { type: 'image/png' })
        this.editor.insertFile(file)
      } else if (error) {
        throw new Error('Job to generate image was not successful')
      }
    } catch (err) {
      console.log(err)
      alert('Unable to generate image')
    } finally {
      document.getElementById(image_id).parentElement.remove()
    }
  }

  createGenerativeId(prefix) {
    const timestamp = new Date().getTime()
    const random = Math.floor(Math.random() * 10000)
    return `${prefix}_${timestamp}_${random}`
  }

  insertGenerativePlaceholder(id, type) {
    const placeholder = new Trix.Attachment({
      content: this.generativeContainer(id, type), contentType: 'tmp/generative-content-placeholder'
    })
    this.editor.recordUndoEntry("InsertGenerativeContentPlaceholder")
    this.editor.insertAttachment(placeholder)

    // Clear the selection so the placeholder figure is not selected.
    // Also remove the undo entry that would let the user put the placeholder back.
    // I could only get these things to work by pushing it to the end of the stack.
    setTimeout(() => {
      this.editor.undoManager.undoEntries.pop()
      window.getSelection().empty()
    }, 0)
  }

  generativeContainer(id, type) {
    return`
      <div id=${id} class="gen${type}-placeholder alert alert-info i-pulse p-1">Generating ${type}...</div>
    `
  }

  removeAllPlaceholders() {
    const placeholders = document.querySelectorAll(`.${this.genTextClassName}`)
    placeholders.forEach(p => p.parentElement.remove())
  }
}
