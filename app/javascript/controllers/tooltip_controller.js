import { Controller } from '@hotwired/stimulus'
import ToolTippable from '@javascript/mixins/ToolTippable'

export default class TooltipController extends Controller {
  connect() {
    ToolTippable.connect.bind(this)()
  }

  disconnect() {
    ToolTippable.disconnect.bind(this)()
  }
}
