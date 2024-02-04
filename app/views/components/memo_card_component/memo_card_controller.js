import { Controller } from "@hotwired/stimulus"
import ToolTippable from '@javascript/mixins/ToolTippable'

class MemoCardController extends Controller {
}

Object.assign(MemoCardController.prototype, ToolTippable)

export default MemoCardController
