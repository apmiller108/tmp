import { Controller } from "@hotwired/stimulus"
import * as bootstrap from "bootstrap"

export default class extends Controller {
  static targets = ['cardText']
  toolTippable = [this.cardTextTarget]

  connect() {
    this.toolTippable = this.toolTippable.map(elem => new bootstrap.Tooltip(elem))
  }
}
