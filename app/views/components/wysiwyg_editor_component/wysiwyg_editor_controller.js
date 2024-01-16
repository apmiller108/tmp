import { Controller } from '@hotwired/stimulus'

export default class WysiwygEditor extends Controller {
  static initEventName = 'trix-initialize'

  connect() {
    document.addEventListener(WysiwygEditor.initEventName, this.initTrix.bind(this))
  }

  initTrix(e) {
    console.dir(e);
    Trix.config.textAttributes.underline = {
      style: { textDecoration: 'underline' },
      parser: (elem) => elem.style.textDecoration === 'underline',
      inheritable: 1
    }

    let underlineEl = document.createElement("button");
    underlineEl.setAttribute("type", "button");
    underlineEl.setAttribute("data-trix-attribute", "underline");
    underlineEl.setAttribute("data-trix-key", "u");
    underlineEl.setAttribute("tabindex", -1);
    underlineEl.setAttribute("title", "underline");
    underlineEl.classList.add("trix-button", "trix-button--icon-underline");
    underlineEl.innerHTML = "U";

    // add button to toolbar - inside the text tools group
    document.querySelector(".trix-button-group--text-tools").appendChild(underlineEl);
  }

  diconnect() {
    document.removeEventListener(WysiwygEditor.initEventName, this.initTrix.bind(this))
  }
}
