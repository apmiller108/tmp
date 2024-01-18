import { Controller } from "@hotwired/stimulus"
import * as bootstrap from "bootstrap"

export default class extends Controller {
  static targets = ['cardText']
  toolTippable = [this.cardTextTarget]

  connect() {
    try {
      this.toolTippable = this.toolTippable.map(elem => new bootstrap.Tooltip(elem))
    } catch (error) {
      if (error.message === 'this._config is undefined') {
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
