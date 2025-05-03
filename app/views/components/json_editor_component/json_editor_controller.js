import { Controller } from "@hotwired/stimulus";
import { EditorView, basicSetup } from "codemirror"
import { json, jsonParseLinter } from "@codemirror/lang-json"
import { lintGutter, linter } from "@codemirror/lint"

export default class JsonEditor extends Controller {
  static targets = ['input', 'editorElem']

  connect() {
    this.initializeEditor()
  }

  disconnect() {
    // tear down editor
  }

  get extensions() {
    return [
      basicSetup,
      json(),
      lintGutter(),
      linter(jsonParseLinter()),
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
    this.formatJson()
  }

  formatJson() {
    try {
      const content = this.editorView.state.doc.toString();
      // Parse and stringify with indentation
      const formatted = JSON.stringify(JSON.parse(content), null, 2);

      // Replace the entire document with the formatted version
      const transaction = this.editorView.state.update({
        changes: {
          from: 0,
          to: this.editorView.state.doc.length,
          insert: formatted
        }
      });

      this.editorView.dispatch(transaction);
    } catch (e) {
      console.error("JSON formatting failed:", e);
    }
  }
}
