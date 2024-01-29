import { Controller } from '@hotwired/stimulus'
import autoAnimate from '@formkit/auto-animate'

export default class FlashMessage extends Controller {
  static targets = ['closeButton']

  connect() {
    const autoDismiss = this.element.dataset.autoDismiss
    if (autoDismiss) {
      const ms = (Number(autoDismiss) * 1000)
      setTimeout(() => {
        this.closeButtonTarget.click()
      }, ms)
    }
  }
}
