import TrixSelectors from './TrixSelectors'

export default class TrixCustomizer {
  editor;
  textTools;
  blockTools;
  fileTools;
  dialogs;

  constructor(editorElem) {
    this.editor = editorElem
    this.textTools = this.editor.toolbarElement.querySelector(TrixSelectors.TEXT_TOOLS)
    this.blockTools = this.editor.toolbarElement.querySelector(TrixSelectors.BLOCK_TOOLS)
    this.fileTools = this.editor.toolbarElement.querySelector(TrixSelectors.FILE_TOOLS)
    this.dialogs = this.editor.toolbarElement.querySelector(TrixSelectors.DIALOGS)
  }

  applyCustomizations() {
    this.createHighlightButton()
    this.createHeadingsButton()
    this.createGenerateTextButton()
    this.createGenerateImageButton()
  }

  createHighlightButton() {
    this.textTools.insertAdjacentHTML('beforeend', this.highlightButton)
  }

  createHeadingsButton() {
    this.editor.toolbarElement.querySelector(TrixSelectors.HEADING_ATTR).remove()
    this.blockTools.insertAdjacentHTML("afterbegin", this.headingButtons)
    this.dialogs.insertAdjacentHTML("beforeend", this.headingsDialog)
  }

  createGenerateTextButton() {
    this.fileTools.insertAdjacentHTML('beforeend', this.generateTextButton)
    this.dialogs.insertAdjacentHTML('beforeend', this.generativeAiDialog('Text'))
  }

  createGenerateImageButton() {
    this.fileTools.insertAdjacentHTML('beforeend', this.generateImageButton)
    this.dialogs.insertAdjacentHTML('beforeend', this.generativeAiDialog('Image'))
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
      <div class="trix-dialog trix-dialog--heading trix-custom-dialog trix-custom-heading" data-trix-dialog="headingsGroup"
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

  get generateTextButton() {
    return`
      <button class="trix-button trix-button--icon trix-button-custom" type="button"
              data-trix-action="generateText" data-wysiwyg-editor-target="generateTextBtn"
              data-action="click->wysiwyg-editor#onOpenGenerateTextDialog"
              title="Generate Text" tabindex="-1">
        <i class="bi bi-body-text"></i>
      </button>
    `
  }

  get generateImageButton() {
    return`
      <button class="trix-button trix-button--icon trix-button-custom" type="button"
              data-trix-action="generateImage" data-wysiwyg-editor-target="generateImageBtn"
              data-action="click->wysiwyg-editor#onOpenGenerateImageDialog"
              title="Generate Image" tabindex="-1">
        <i class="bi bi-image-alt"></i>
      </button>
    `
  }

  generativeAiDialog(name) {
    const action = `generate${name}`
    const lowerCase = name.toLowerCase()
    return `
      <div class="trix-dialog trix-dialog--heading trix-custom-dialog trix-custom-generate-${lowerCase}" data-trix-dialog="${action}"
            data-trix-dialog-attribute="${action}" data-wysiwyg-editor-target="${action}Dialog">
        <div class="d-flex" >
          <input type="hidden" name="generate_${lowerCase}_id" value="" data-wysiwyg-editor-target="${action}Id" autocomplete="off">
          <input type="text" class="generate-${lowerCase}-input form-control form-control-lg" name="${action}"
                 data-action="keydown.enter->wysiwyg-editor#submitGenerate${name}:prevent"
                 data-wysiwyg-editor-target="${action}Input" data-trix-input required>
          <div class="trix-button-group d-inline-flex">
            <input type="button" class="trix-button trix-button--dialog" data-trix-method="setAttribute"
                   value="Submit"
                   data-action="click->wysiwyg-editor#submitGenerate${name}:prevent">
          </div>
        </div>
      </div>
    `
  }
}
