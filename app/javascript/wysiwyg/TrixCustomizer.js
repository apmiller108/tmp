export default class TrixCustomizer {
  config = Trix.config
  editor;
  textTools;

  constructor(editorElem) {
    this.editor = editorElem
    this.textTools = this.editor.toolbarElement.querySelector('.trix-button-group.trix-button-group--text-tools')

    this.initHighlightButton()
  }

  initHighlightButton() {
    this.config.textAttributes.highlight = { tagName: 'mark', inheritable: 1 }
    this.textTools.insertAdjacentHTML('beforeend', this.highlightButton())
  }

  highlightButton() {
    return `
    <button class="trix-button trix-button--icon trix-button-custom" type="button" data-trix-attribute="highlight"
            data-trix-key="h" tabindex="-1" title="Highlight"><i class="bi bi-highlighter"></i></button>
    `
  }
}
