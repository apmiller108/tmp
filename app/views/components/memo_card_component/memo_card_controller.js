import { Controller } from "@hotwired/stimulus"
import { Tooltip } from "bootstrap"
import ToolTippable from '@javascript/mixins/ToolTippable'

class MemoCardController extends Controller {
}

Object.assign(MemoCardController.prototype, ToolTippable)

export default MemoCardController
