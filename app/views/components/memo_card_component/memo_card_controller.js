import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ['title'];

  expand(e) {
    const path = e.target.dataset.path
    const title = this.titleTarget.textContent
    this.dispatch("expandMemo", { detail: { path, title } })
  }
}
