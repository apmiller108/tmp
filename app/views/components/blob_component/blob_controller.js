import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ['audio']
  connect() {
    if (this.hasAudioTarget) {
      console.log(this.audioTarget);
    }
  }
}
