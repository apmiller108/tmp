import { Controller } from '@hotwired/stimulus'
import TrixSelectors from '@wysiwyg/TrixSelectors'
import TrixConfiguration from '@wysiwyg/TrixConfiguration'
import TrixCustomizer from '@wysiwyg/TrixCustomizer'
import { generateText } from '@javascript/http'

export default class WysiwygEditor extends Controller {
  static targets = ['generateTextBtn', 'generateTextDialog', 'generateTextId', 'generateTextInput', 'generateTextSubmit']

  editor;
  selectedText;

  connect() {
    this.editor = this.element.querySelector(TrixSelectors.EDITOR).editor
    document.addEventListener(TrixConfiguration.selectionChange, this.onSelectionChange.bind(this))
  }

  disconnect() {
    document.removeEventListener(TrixConfiguration.selectionChange, this.onSelectionChange.bind(this))
  }

  onOpenGenerateTextDialog() {
    this.generateTextInputTarget.value = this.selectedText;
    this.generateTextInputTarget.focus()
  }

  onSelectionChange() {
    // Store the currently mouse-selected text
    this.selectedText = window.getSelection().toString()
  }

  async submitGenerateText(_e) {
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
      // This is used to determine if the placeholder is still present. It could
      // have been removed by the user by this point in which case inserting the
      // generated text is aborted below.
      placeHolderDiv = document.getElementById(id)
    } catch (err) {
      console.log(err)
    } finally {
      placeHolderDiv?.parentElement?.remove() // Remove the placeholder attachment figure
    }

    const responseBody = await response.text()
    Turbo.renderStreamMessage(responseBody)

    if (response.ok && placeHolderDiv) {
      this.editor.recordUndoEntry("InsertGenText")
      this.editor.setSelectedRange(selectedRange[0])
      this.editor.insertString(responseBody)
      console.dir(this.editor.undoManager.undoEntries)
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