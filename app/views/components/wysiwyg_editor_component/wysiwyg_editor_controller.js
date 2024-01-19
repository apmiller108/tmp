import { Controller } from '@hotwired/stimulus'
import { post } from '@rails/request.js'

export default class WysiwygEditor extends Controller {
  static targets = ['generateTextBtn', 'generateTextDialog', 'generateTextId', 'generateTextInput', 'generateTextSubmit']

  editor;

  connect() {
    this.editor = this.element.querySelector('trix-editor').editor
    console.log(this.editor);
  }

  async submitGenerateText(e) {
    const id = this.generateTextId('gentext');
    const placeHolder = new Trix.Attachment({ content: this.generatedTextContainer(id), contentType: 'tmp/generate-text-placeholder' })

    this.generateTextIdTarget.value = id

    this.editor.insertLineBreak()
    this.editor.insertAttachment(placeHolder)
    this.editor.insertLineBreak()

    this.generateTextDialogTarget.classList.remove('trix-active')
    delete this.generateTextDialogTarget.dataset.trixActive

    const body = JSON.stringify({
      generative_text: {
        input: this.generateTextInputTarget.value,
        text_id: this.generateTextIdTarget.value
      }
    });
    const headers = {
      'Content-Type': 'application/json',
      Accept: 'text/vnd.turbo-stream.html',
      'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
    }

    const response = await fetch('/generative_texts', {
      method: 'POST',
      body,
      headers,
    })

    // Remove the placeholder div
    const placeHolderDiv = document.getElementById(id)
    placeHolderDiv.parentElement.remove()

    const text = await response.text()
    Turbo.renderStreamMessage(text) // if 400 response
    this.editor.insertString(text) // if 201 response
    // if successful reset the imput

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
