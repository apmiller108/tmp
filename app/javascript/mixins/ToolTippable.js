import { Tooltip } from 'bootstrap'

export const initializeTooltipsFor = (elem) => Array.from(elem.querySelectorAll('[data-bs-toggle="tooltip"]')).map(e => new Tooltip(e))

export default {
  connect() {
    try {
      this.toolTippable = initializeTooltipsFor(this.element)
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
  },

  disconnect() {
    this.toolTippable.forEach(tt => tt.hide())
  }
}
