import { Controller } from "@hotwired/stimulus"
import { Tooltip } from "bootstrap"

export default class extends Controller {
  static targets = ['cardText']
  toolTippable = [this.cardTextTarget]

  connect() {
    try {
      this.toolTippable = this.toolTippable.map(elem => new Tooltip(elem))
    } catch (error) {
      if (error.stack.includes("_Tooltip._setListeners")) {
        // this error happens when a new controller is instantiated (eg after a
        // successful memo update) and tooltips are created again for elements
        // that already have tooltips from the previous controller's
        // instantiation.
        return;
      } else {
        throw error
      }
    }
  }
}
