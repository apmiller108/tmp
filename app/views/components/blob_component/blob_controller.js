import { Controller } from "@hotwired/stimulus"
import autoAnimate from '@formkit/auto-animate'

export default class extends Controller {
  static targets = ['audio', 'transcriptionSection']
  connect() {
    if (this.hasTranscriptionSectionTarget) {
      autoAnimate(this.transcriptionSectionTarget)
    }
  }
}
