import { Controller } from '@hotwired/stimulus'
import ToolTippable from '@javascript/mixins/ToolTippable'

class MemoController extends Controller {
}

Object.assign(MemoController.prototype, ToolTippable)

export default MemoController
