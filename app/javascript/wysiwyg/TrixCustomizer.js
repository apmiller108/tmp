import TrixSelectors from './TrixSelectors'

export default class TrixCustomizer {
  editor;
  textTools;
  blockTools;
  dialogs;

  constructor(editorElem) {
    this.editor = editorElem
    this.textTools = this.editor.toolbarElement.querySelector(TrixSelectors.TEXT_TOOLS)
    this.blockTools = this.editor.toolbarElement.querySelector(TrixSelectors.BLOCK_TOOLS)
    this.dialogs = this.editor.toolbarElement.querySelector(TrixSelectors.DIALOGS)
  }

  applyCustomizations() {
    this.createHighlightButton()
    this.createHeadingButtons()
  }

  createHighlightButton() {
    this.textTools.insertAdjacentHTML('beforeend', this.highlightButton)
  }

  createHeadingButtons() {
    this.editor.toolbarElement.querySelector(TrixSelectors.HEADING_ATTR).remove()
    this.blockTools.insertAdjacentHTML("afterbegin", this.headingButtons)
    this.dialogs.insertAdjacentHTML("beforeend", this.headingsDialog)
  }

  get highlightButton() {
    return `
      <button class="trix-button trix-button--icon trix-button-custom" type="button" data-trix-attribute="highlight"
              data-trix-key="h" tabindex="-1" title="Highlight">
        <i class="bi bi-highlighter"></i>
      </button>
    `
  }

  get headingButtons() {
    return`
      <button class="trix-button trix-button--icon trix-button-custom" type="button"
              data-trix-action="headingsGroup" title="Heading" tabindex="-1">
        <i class="bi bi-card-heading"></i>
      </button>
    `
  }

  get headingsDialog() {
    return `
      <div class="trix-dialog trix-dialog--heading trix-custom-heading" data-trix-dialog="headingsGroup"
            data-trix-dialog-attribute="headingsGroup">
        <div class="d-flex align-items-baseline">
          <input type="text" name="headingsGroup" class="trix-dialog-hidden__input" data-trix-input>
          <div class="trix-button-group">
            <button type="button" class="trix-button trix-button--dialog" data-trix-attribute="heading1">
              <i class="bi bi-type-h1"></i>
            </button>
            <button type="button" class="trix-button trix-button--dialog" data-trix-attribute="heading2">
              <i class="bi bi-type-h2"></i>
            </button>
            <button type="button" class="trix-button trix-button--dialog" data-trix-attribute="heading3">
              <i class="bi bi-type-h3"></i>
            </button>
            <button type="button" class="trix-button trix-button--dialog" data-trix-attribute="heading4">
              <i class="bi bi-type-h4"></i>
            </button>
            <button type="button" class="trix-button trix-button--dialog" data-trix-attribute="heading5">
              <i class="bi bi-type-h5"></i>
            </button>
            <button type="button" class="trix-button trix-button--dialog" data-trix-attribute="heading6">
              <i class="bi bi-type-h6"></i>
            </button>
          </div>
        </div>
      </div>
    `
  }
}
