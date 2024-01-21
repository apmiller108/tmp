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
  }

  onSelectionChange() {
    // Store the currently mouse-selected text
    this.selectedText = window.getSelection().toString()
  }

  async submitGenerateText(e) {
    const id = this.generateTextId('gentext')
    const selectedRange = this.editor.getSelectedRange()
    const placeHolder = new Trix.Attachment({
      content: this.generatedTextContainer(id), contentType: 'tmp/generate-text-placeholder'
    })

    if (!this.generateTextInputTarget.value.length) {
      return
    }

    this.generateTextIdTarget.value = id
    this.editor.insertAttachment(placeHolder)

    let response;
    try {
      response = await generateText({
        input: this.generateTextInputTarget.value,
        text_id: this.generateTextIdTarget.value
      })
    } catch (err) {
      console.log(err)
    } finally {
      const placeHolderDiv = document.getElementById(id)
      placeHolderDiv.parentElement.remove() // Remove the placeholder attachment figure
    }

    const responseBody = await response.text()
    Turbo.renderStreamMessage(responseBody)

    if (response.ok) {
      this.editor.recordUndoEntry("Insert gen text")
      this.editor.setSelectedRange(selectedRange[0])
      this.editor.insertString(responseBody)
      this.generateTextInputTarget.value = ''
    }
  }

  generateTextId(prefix) {
    const timestamp = new Date().getTime()
    const random = Math.floor(Math.random() * 10000)
    return `${prefix}_${timestamp}_${random}`
  }

  generatedTextContainer(id) {
    return`
      <div id=${id}>Generating text...</div>
    `
  }
}
