import { Controller } from '@hotwired/stimulus'

export default class FileInputController extends Controller {
  static targets = ['input', 'uploadProgress', 'invalidFeedback']

  get fileTypes() {
    return JSON.parse(this.element.dataset.fileTypes)
  }

  get maxSize() {
    return this.element.dataset.maxSize
  }

  onDragOver() {
    this.element.classList.add('border', 'border-secondary', 'border-1')
  }

  onDragLeave() {
    this.element.classList.remove('border', 'border-secondary', 'border-1')
  }

  onDrop() {
    this.element.classList.remove('border', 'border-secondary', 'border-1')
  }

  onUploadStart() {
    this.uploadProgressTarget.classList.remove('.error')
    this.uploadProgressTarget.style.zIndex = '2'
  }

  onUploadProgress() {
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

  onToggleInput(e) {
    console.log(e)
    const { disabled } = event.detail
    if (disabled) {
      this.inputTarget.removeAttribute('disabled')
    } else {
      this.inputTarget.setAttribute('disabled', true)
    }
  }

  onChange(e) {
    this.validate(e)
  }

  validate() {
    const file = this.inputTarget.files[0]

    if (!file) return true

    this.resetError()

    if (file.size > Number(this.maxSize)) {
      this.showError(`File size must be less than ${this.maxSize.charAt(0)}MB`)
      return false
    }

    if (!this.fileTypes.includes(file.type)) {
      const types = this.fileTypes.map(t => t.split('/')[1].toUpperCase() ).join(', ')
      this.showError(`Only ${types} files are allowed`)
      return false
    }

    return true
  }

  resetError() {
    this.inputTarget.classList.remove("is-invalid")
    this.invalidFeedbackTarget.textContent = ""
    this.invalidFeedbackTarget.style.display = 'none'
  }

  showError(message) {
    this.inputTarget.classList.add("is-invalid")
    this.invalidFeedbackTarget.style.display = 'block'
    this.invalidFeedbackTarget.textContent = message
    this.inputTarget.value = ""
  }
}
