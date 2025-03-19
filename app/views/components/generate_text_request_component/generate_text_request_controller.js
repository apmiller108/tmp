import { Controller } from "@hotwired/stimulus"
import { Popover } from 'bootstrap'
import mermaid from "mermaid"

export default class GenerateTextRequestController extends Controller {
  static targets = ['moreInfo']

  connect() {
    if (this.hasMoreInfoTarget) {
      new Popover(this.moreInfoTarget, {
        content: this.moreInfoTemplate,
        container: this.element,
        html: true,
        boundary: this.element,
        placement: 'right',
        fallbackPlacements: ['bottom', 'top'],
        trigger: 'focus' // Dismiss on next click. Cross-browser support requires elem be `a` tag with tabindex.
      })
    }

    this.initializeMermaidDiagrams()
  }

  get mermaidDiagrams() {
    return this.element.querySelectorAll('pre[lang="mermaid"]')
  }

  initializeMermaidDiagrams() {
    const validDiagrams = Array.from(this.mermaidDiagrams).filter((pre) => {
      return mermaid.parse(pre.textContent, { suppressErrors: true }) // returns false if invalid mermaid syntax
    })

    if (validDiagrams.length) {
      mermaid.run({ nodes: validDiagrams })
    }
  }

  get moreInfoTemplate() {
    return this.element.dataset.moreInfoTemplate
  }
}
