import { Controller } from "@hotwired/stimulus"
import { Popover } from 'bootstrap'

export default class MoreInfo extends Controller {
  popovers;

  connect() {
    const popoverTriggerList = document.querySelectorAll('[data-bs-toggle="popover"]')
    this.popovers = [...popoverTriggerList].map(el => new Popover(el))
  }
}
