import { Controller } from "@hotwired/stimulus";
import { EditorView, basicSetup } from "codemirror"
import { json, jsonParseLinter } from "@codemirror/lang-json"
import { lintGutter, linter } from "@codemirror/lint"

export default class JsonEditor extends Controller {
  static targets = ['input', 'editorElem', 'templateButton']

  connect() {
    this.initializeEditor()
  }

  disconnect() {
    if (this.editorView) {
      this.editorView.destroy();
      this.editorView = null;
    }
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
          this.onInputSchemaChange()
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
    this.formatContent()
  }

  formatContent() {
    try {
      const content = this.editorView.state.doc.toString();
      if (content.length) {
        // Replace the entire document with the formatted version
        const transaction = this.editorView.state.update({
          changes: {
            from: 0,
            to: this.editorView.state.doc.length,
            insert: this.formatJSON(JSON.parse(content)) // content is JSON string
          }
        });

        this.editorView.dispatch(transaction);
      }
    } catch (e) {
      console.error("JSON formatting failed:", e);
    }
  }

  // Parse and stringify with indentation
  formatJSON(json) {
    return JSON.stringify(json, null, 2);
  }

  onInputSchemaChange() {
    const val = this.inputTarget.value
    if (val.length) {
      this.templateButtonTarget.disabled = true
    } else {
      this.templateButtonTarget.disabled = false
    }
  }

  insertSchemaTemplate() {
    const schemaTemplate = {
      "type": "object",
      "required": ["name", "age"],
      "properties": {
        "name": {
          "type": "string",
          "description": "The person's full name"
        },
        "age": {
          "type": "integer",
          "description": "Age in years",
          "minimum": 0
        },
        "email": {
          "type": "string",
          "format": "email",
          "description": "Email address"
        },
        "address": {
          "type": "object",
          "properties": {
            "street": {
              "type": "string"
            },
            "city": {
              "type": "string"
            },
            "state": {
              "type": "string"
            },
            "zipCode": {
              "type": "string",
              "pattern": "^[0-9]{5}(-[0-9]{4})?$"
            }
          }
        },
        "phoneNumbers": {
          "type": "array",
          "items": {
            "type": "object",
            "properties": {
              "type": {
                "type": "string",
                "enum": ["home", "work", "mobile"]
              },
              "number": {
                "type": "string"
              }
            }
          }
        },
        "isActive": {
          "type": "boolean",
          "default": true
        },
        "dateOfBirth": {
          "type": "string",
          "format": "date"
        },
        "tags": {
          "type": "array",
          "items": {
            "type": "string"
          },
          "uniqueItems": true
        }
      }
    };

    // Replace the entire document with the template
    const transaction = this.editorView.state.update({
      changes: {
        from: 0,
        to: this.editorView.state.doc.length,
        insert: this.formatJSON(schemaTemplate)
      }
    });

    this.editorView.dispatch(transaction);
  }
}
