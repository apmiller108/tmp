import { Controller } from '@hotwired/stimulus'

export default class FileInputController extends Controller {
  static targets = ['input', 'uploadProgress']

  onUploadStart() {
    console.log('start')
    this.uploadProgressTarget.classList.remove('.error')
    this.uploadProgressTarget.style.zIndex = '2'
  }

  onUploadProgress(e) {
    const { progress } = event.detail
    console.log(`progres: ${progress}`)
    this.uploadProgressTarget.style.width = `${progress}%`
  }

  onUploadEnd() {
    console.log('end')
    this.uploadProgressTarget.style.zIndex = ''
    this.uploadProgressTarget.style.width = '0'
  }

  onUploadError() {
    this.uploadProgressTarget.classList.add('.error')
  }
}
