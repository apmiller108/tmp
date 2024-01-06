import { Controller } from "@hotwired/stimulus"
import autoAnimate from '@formkit/auto-animate'

export default class extends Controller {
  static targets = ['transcriptionSummaryTab']
  connect() {
    if (this.hasTranscriptionSummaryTabTarget) {
      autoAnimate(this.transcriptionSummaryTabTarget)
    }
  }
}
