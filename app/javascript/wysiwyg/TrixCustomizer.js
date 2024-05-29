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
    this.dialogs.insertAdjacentHTML('beforeend', this.generateTextDialog)
  }

  createGenerateImageButton() {
    this.fileTools.insertAdjacentHTML('beforeend', this.generateImageButton)
    this.dialogs.insertAdjacentHTML('beforeend', this.generateImageDialog)
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


  get generateTextDialog() {
    return `
      <div class="trix-dialog trix-dialog--heading trix-custom-dialog trix-custom-generate-text" data-trix-dialog="generateText"
            data-trix-dialog-attribute="generateText" data-wysiwyg-editor-target="generateTextDialog">
        <div class="grid" >
          <div class="g-col-6">
            <div class="form-floating gen-text-preset-selects">
              <select id="gen-text-presets" class="form-select form-select-lg" aria-label="gen text presets"
                      name="generate_text_preset_id" data-wysiwyg-editor-target="generateTextPreset">
              </select>
              <label for="generate_text_preset_id">Preset</label>
            </div>
          </div>
          <div class="g-col-6">
            <div class="form-floating temperature-select">
              <select id="temperature" class="form-select form-select-lg" aria-label="style preset" name="temperature"
                      data-wysiwyg-editor-target="generateTextTemperature">
              </select>
              <label for="temperature">Temperature</label>
            </div>
          </div>
          <div class="d-flex g-col-12" >
            <input type="hidden" name="generate_text_id" value="" data-wysiwyg-editor-target="generateTextId" autocomplete="off">
            <input type="text" class="generate-content-input form-control form-control-lg" name="generateText"
                  data-action="keydown.enter->wysiwyg-editor#submitGenerateText:prevent"
                  data-wysiwyg-editor-type-param="text"
                  data-wysiwyg-editor-target="generateTextInput" data-trix-input required>
            <div class="trix-button-group d-inline-flex">
              <input type="button" class="trix-button trix-button--dialog" data-trix-method="setAttribute"
                    value="Submit"
                    data-wysiwyg-editor-type-param="text"
                    data-action="click->wysiwyg-editor#submitGenerateText:prevent">
            </div>
          </div>
        </div>
      </div>
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

  get generateImageDialog() {
    return `
      <div class="trix-dialog trix-dialog--heading trix-custom-dialog trix-custom-generate-image" data-trix-dialog="generateImage"
            data-trix-dialog-attribute="generateImage" data-wysiwyg-editor-target="generateImageDialog">
        <input type="hidden" name="generate_image_name" value="" data-wysiwyg-editor-target="generateImageName" autocomplete="off">
        <div class="grid" >
          <div class="g-col-3">
            <div class="form-floating aspect-ratio-select">
              <select id="aspect-ratio" class="form-select form-select-lg" aria-label="aspect-ratio" name="aspect-ratio"
                      data-wysiwyg-editor-target="generateImageAspectRatio" data-action="change->wysiwyg-editor#onGenerateImageAspectRatioChange">
              </select>
              <label for="aspect-ratio">Aspect Ratio</label>
            </div>
          </div>
          <div class="g-col-3 position-relative">
            <div class="aspect-ratio-example position-absolute" data-wysiwyg-editor-target="aspectRatioExample"></div>
          </div>
          <div class="g-col-6">
            <div class="form-floating style-select">
              <select id="style-preset" class="form-select form-select-lg" aria-label="style preset" name="style-preset"
                      data-wysiwyg-editor-target="generateImageStyle">
              </select>
              <label for="style-preset">Style</label>
            </div>
          </div>
          <div class="g-col-12">
            <div class="input-group promot-group" data-wysiwyg-editor-target="generateImagePromptGroup">
              <div class="form-floating">
                <input type="text" id="prompt" class="generate-content-input form-control form-control-lg" name="generateImage",
                       placeholder="Enter prompt"
                       data-action="keydown.enter->wysiwyg-editor#submitGenerateImage:prevent"
                       data-wysiwyg-editor-type-param="image"
                       data-trix-input required>
                <label for="prompt">Prompt</label>
              </div>
              <div class="form-floating weight-select">
                <select id="weight" class="form-select form-select-lg" aria-label="prompt weight" name="weight">
                  <option selected value="1">1</option>
                  <option value="2">2</option>
                  <option value="3">3</option>
                </select>
                <label for="weight">Weight</label>
              </div>
            </div>
          </div>
          <div class="g-col-sm-3 g-start-md-10 g-col-12">
            <div class="trix-button-group d-inline-flex">
              <input type="button" class="trix-button trix-button--dialog" data-trix-method="setAttribute"
                     value="Submit"
                     data-wysiwyg-editor-type-param="image"
                     data-action="click->wysiwyg-editor#submitGenerateImage:prevent">
            </div>
          </div>
        </div>
      </div>
    `
  }
}
