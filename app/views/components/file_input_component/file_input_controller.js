import { Controller } from '@hotwired/stimulus'

export default class FileInputController extends Controller {
  static targets = ['input', 'uploadProgress']

  onUploadStart() {
    this.uploadProgressTarget.classList.remove('.error')
    this.uploadProgressTarget.style.zIndex = '2'
  }

  onUploadProgress(e) {
    const { progress } = event.detail
    this.uploadProgressTarget.style.width = `${progress}%`
  }

  onUploadEnd() {
    this.uploadProgressTarget.style.zIndex = ''
    this.uploadProgressTarget.style.width = '0'
  }

  onUploadError() {
    this.uploadProgressTarget.classList.add('.error')
  }
}
