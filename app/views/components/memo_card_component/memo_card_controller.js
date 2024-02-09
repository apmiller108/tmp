import { Controller } from "@hotwired/stimulus"
import ToolTippable from '@javascript/mixins/ToolTippable'

export default class MemoCardController extends Controller {
  subscription;

  connect() {
    ToolTippable.connect.bind(this)()
    this.dispatch("memoConnected", { detail: { memoId: this.memoId } })
  }

  disconnect() {
    ToolTippable.disconnect.bind(this)()
  }

  get memoId() {
    return this.element.dataset.memoId
  }
}
