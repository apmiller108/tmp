import { Tooltip } from 'bootstrap'

export default {
  connect() {
    console.log('connect')
    this.toolTippable = Array.from(this.element.querySelectorAll('[data-bs-toggle="tooltip"]')).map(e => new Tooltip(e))
  },

  disconnect() {
    this.toolTippable.forEach(tt => tt.hide())
  }
}
