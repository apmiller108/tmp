import { Controller } from "@hotwired/stimulus";
import { EditorView, basicSetup } from "codemirror"
import { json } from "@codemirror/lang-json"
import { lintGutter } from "@codemirror/lint"

export default class JsonEditor extends Controller {
  static targets = ['input', 'editorElem']

  connect() {
    this.initializeEditor()
  }

  disconnect() {
  }

  get extensions() {
    return [
      basicSetup,
      json(),
      lintGutter(),
      EditorView.lineWrapping,
      EditorView.updateListener.of(update => { // of returns an extension
        if (update.docChanged) {
          this.inputTarget.value = update.state.doc.toString()
        }
      })
    ]
  }

  initializeEditor() {
    this.editorView = new EditorView({
      doc: this.inputTarget.value,
      extensions: this.extensions,
      parent: this.editorElemTarget
    })
  }
}
