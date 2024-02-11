import { Controller } from '@hotwired/stimulus'
import TrixSelectors from '@wysiwyg/TrixSelectors'
import TrixConfiguration from '@wysiwyg/TrixConfiguration'
import { generateText } from '@javascript/http'

export default class WysiwygEditor extends Controller {
  static targets = [
    'generateTextBtn', 'generateTextDialog', 'generateTextId', 'generateTextInput', 'generateTextSubmit',
    'generateImageBtn', 'generateImageDialog', 'generateImageId', 'generateImageInput', 'generateImageSubmit',
  ];

  editorElem;
  selectedText;

  connect () {
    this.editorElem = this.element.querySelector(TrixSelectors.EDITOR)
    document.addEventListener(TrixConfiguration.selectionChange, this.onSelectionChange.bind(this))
  }

  disconnect() {
    document.removeEventListener(TrixConfiguration.selectionChange, this.onSelectionChange.bind(this))
  }

  get editor() {
    return this.editorElem.editor
  }

  onOpenGenerateTextDialog() {
    this.generateTextInputTarget.value = this.selectedText;
    this.generateTextInputTarget.focus()
  }

  onOpenGenerateImageDialog() {
    this.generateImageInputTarget.value = this.selectedText;
    this.generateImageInputTarget.focus()
  }

  onSelectionChange() {
    // Store the currently mouse-selected text
    this.selectedText = window.getSelection().toString()
  }

  async submitGenerateText() {
    const id = this.generateTextId('gentext')
    const placeholder = new Trix.Attachment({
      content: this.generatedTextContainer(id), contentType: 'tmp/generate-text-placeholder'
    })

    if (!this.generateTextInputTarget.value.length) {
      return
    }

    this.generateTextIdTarget.value = id
    this.editor.recordUndoEntry("InsertGenTextPlaceholder")
    this.editor.insertAttachment(placeholder)

    // Clear the selection so the placeholder figure is not selected.
    // Also remove the undo entry that would let the user put the placeholder back.
    // I could only get these things to work by pushing it to the end of the stack.
    setTimeout(() => {
      this.editor.undoManager.undoEntries.pop()
      window.getSelection().empty()
    }, 0)

    let response;
    let placeHolderDiv
    try {
      response = await generateText({
        prompt: this.generateTextInputTarget.value,
        text_id: this.generateTextIdTarget.value
      })

      if (response.status === 401 || response.status === 403) {
        window.location = '/'
      }

      if (response.ok) {
        this.generateTextInputTarget.value = ''
      }
    } catch (err) {
      console.log(err)
      placeHolderDiv?.parentElement?.remove() // Remove the placeholder attachment figure
    }

    // Text is generated asychronously. The use of renderStreamMessage is for
    // any turbo streams in the response (ie, flash message)
    const responseBody = await response.text()
    if (responseBody.length) {
      Turbo.renderStreamMessage(responseBody)
    }
  }

  onGenerateText(event) {
    const { generate_text: { text_id, content, error }} = event.detail
    const selectedRange = this.editor.getSelectedRange()
    const placeHolderDiv = document.getElementById(text_id)
    try {
      // Unable to render turbo streams into the Trix editor. Instead the text
      // content is inserted into the editor programatically. First, determine if
      // the placeholder is still present. It could have been removed by the user
      // by this point in which case inserting the generated text is aborted.
      if (placeHolderDiv && !error) {
        this.editor.recordUndoEntry("InsertGenText")
        this.editor.setSelectedRange(selectedRange[0])
        this.editor.insertString(content)
      }
    } catch (err) {
      console.log(err)
      alert('Unable to generate text')
    } finally {
      // Remove the placeholder attachment figure. The element must be re-selected.
      document.getElementById(text_id).parentElement.remove()
    }

  }

  generateTextId(prefix) {
    const timestamp = new Date().getTime()
    const random = Math.floor(Math.random() * 10000)
    return `${prefix}_${timestamp}_${random}`
  }

  get genTextClassName() {
    return 'gentext-placeholder'
  }

  generatedTextContainer(id) {
    return`
      <div id=${id} class="${this.genTextClassName} alert alert-info i-pulse p-1">Generating text...</div>
    `
  }

  async submitGenerateImage() {
    console.log('submit genereate image')
  }

  removeAllPlaceholders() {
    const placeholders = document.querySelectorAll(`.${this.genTextClassName}`)
    placeholders.forEach(p => p.parentElement.remove())
  }
}
