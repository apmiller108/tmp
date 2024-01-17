export default class TrixCustomizer {
  config = Trix.config
  editor;
  textTools;
  blockTools;
  dialogs;

  constructor(editorElem) {
    this.editor = editorElem
    this.textTools = this.editor.toolbarElement.querySelector('[data-trix-button-group="text-tools"]')
    this.blockTools = this.editor.toolbarElement.querySelector('[data-trix-button-group="block-tools"]')
    this.dialogs = this.editor.toolbarElement.querySelector('[data-trix-dialogs]')

    this.initHighlightButton()

    Array.from(["h1", "h2", "h3", "h4", "h5", "h6"]).forEach((tagName, i) => {
      this.config.blockAttributes[`heading${(i + 1)}`] = {
        tagName: tagName,
        terminal: true,
        breakOnReturn: true,
        group: false
      }
    })

    this.editor.toolbarElement.querySelector('[data-trix-attribute="heading1"]').remove()
    this.blockTools.insertAdjacentHTML("afterbegin", this.headingsButton)
    this.dialogs.insertAdjacentHTML("beforeend", this.headingsDialog)
  }

  initHighlightButton() {
    this.config.textAttributes.highlight = { tagName: 'mark', inheritable: 1 }
    this.textTools.insertAdjacentHTML('beforeend', this.highlightButton)
  }

  get highlightButton() {
    return `
      <button class="trix-button trix-button--icon trix-button-custom" type="button" data-trix-attribute="highlight"
              data-trix-key="h" tabindex="-1" title="Highlight">
        <i class="bi bi-highlighter"></i>
      </button>
    `
  }

  get headingsButton() {
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
