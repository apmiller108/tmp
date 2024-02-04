import { Controller } from '@hotwired/stimulus'
import TrixSelectors from '@wysiwyg/TrixSelectors'
import TrixConfiguration from '@wysiwyg/TrixConfiguration'
import { generateText } from '@javascript/http'

export default class WysiwygEditor extends Controller {
  static targets = ['generateTextBtn', 'generateTextDialog', 'generateTextId', 'generateTextInput', 'generateTextSubmit']

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

  onSelectionChange() {
    // Store the currently mouse-selected text
    this.selectedText = window.getSelection().toString()
  }

  async submitGenerateText() {
    const id = this.generateTextId('gentext')
    const selectedRange = this.editor.getSelectedRange()
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
        input: this.generateTextInputTarget.value,
        text_id: this.generateTextIdTarget.value
      })

      if (response.status === 401 || response.status === 403) {
        window.location = '/'
      }

      // This is used to determine if the placeholder is still present. It could
      // have been removed by the user by this point in which case inserting the
      // generated text is aborted below.
      placeHolderDiv = document.getElementById(id)
    } catch (err) {
      console.log(err)
    } finally {
      placeHolderDiv?.parentElement?.remove() // Remove the placeholder attachment figure
    }

    // Unable to render turbo streams into the Trix editor. Instead the text
    // content is inserted into the editor programatically. The use of
    // renderStreamMessage is for any other turbo streams in the response (ie,
    // flash message)
    const responseBody = await response.text()
    const tempTemplate = document.createElement('template')
    tempTemplate.innerHTML = responseBody
    const responseText = tempTemplate.content.querySelector('template').content.textContent

    Turbo.renderStreamMessage(responseBody)

    if (response.ok && placeHolderDiv) {
      this.editor.recordUndoEntry("InsertGenText")
      this.editor.setSelectedRange(selectedRange[0])
      this.editor.insertString(responseText)
      this.generateTextInputTarget.value = ''
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

  removeAllPlaceholders() {
    const placeholders = document.querySelectorAll(`.${this.genTextClassName}`)
    placeholders.forEach(p => p.parentElement.remove())
  }
}
