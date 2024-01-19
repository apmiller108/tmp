import { Controller } from '@hotwired/stimulus'

export default class WysiwygEditor extends Controller {
  static targets = ['generateTextBtn', 'generateTextForm', 'generateTextAuthToken',
                    'generateTextId', 'generateTextInput', 'generateTextSubmit']

  editor;

  connect() {
    this.editor = this.element.querySelector('trix-editor').editor
    console.log(this.editor);
  }

  generateTextBtnTargetConnected(elem) {
    console.log(elem)
  }

  submitGenerateText(e) {
    const id = this.generateTextId('gentext');
    const placeHolder = new Trix.Attachment({ content: this.generatedTextContainer(id) })

    this.generateTextAuthTokenTarget.value = document.querySelector('meta[name="csrf-token"]').content
    this.generateTextAuthTokenTarget.name = document.querySelector('meta[name="csrf-param"]').content
    this.generateTextIdTarget.value = id

    this.editor.insertLineBreak()
    this.editor.insertAttachment(placeHolder)
    this.editor.insertLineBreak()

    // close the dialog
    // submit the form
    console.log(this.editor.getPosition())
    // e.target.submit()
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
