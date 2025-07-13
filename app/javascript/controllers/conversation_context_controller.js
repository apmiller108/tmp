import { Controller } from '@hotwired/stimulus'
import { createConversationContext } from '@javascript/http';

export default class ConversationContextController extends Controller {
  static targets = [
    "dropZone", "fileInput", "progressContainer", "progressBar",
    "fileName", "fileSize", "successAlert", "errorAlert",
    "successMessage", "errorMessage", "filesList", "spinner"
  ]

  abortController = null;
  conversationId = null;

  connect() {
    this.conversationId = this.element.dataset.conversationId
  }

  disconnect() {
    if (this.abortController) {
      this.abortController.abort()
    }
  }

  openFileDialog() {
    this.fileInputTarget.click()
  }

  handleFileSelect(event) {
    const file = event.target.files[0]
    if (file) {
      this.uploadContext(file)
    }
  }

  handleDragOver(event) {
    event.preventDefault()
    this.dropZoneTarget.classList.add('border-primary', 'bg-light')
  }

  handleDragLeave(event) {
    event.preventDefault()
    this.dropZoneTarget.classList.remove('border-primary', 'bg-light')
  }

  handleDrop(event) {
    event.preventDefault()
    this.dropZoneTarget.classList.remove('border-primary', 'bg-light')

    const files = event.dataTransfer.files
    if (files.length > 0) {
      this.uploadContext(files[0])
    }
  }

  showSpinner() {
    this.spinnerTarget.classList.remove('d-none')
    this.dropZoneTarget.classList.add('d-none')
  }

  hideSpinner() {
    this.spinnerTarget.classList.add('d-none')
    this.dropZoneTarget.classList.remove('d-none')
  }

  async uploadContext(file) {
    this.hideAlerts()

    // See also https://developer.mozilla.org/en-US/docs/Web/API/AbortController
    this.abortController = new AbortController()

    const formData = new FormData()
    formData.append('file', file)

    try {
      this.showSpinner()
      const response = await createConversationContext(
        this.conversationId,
        file,
        this.abortController.signal
      )

      if (response.ok) {
        const responseBody = await response.text()
        Turbo.renderStreamMessage(responseBody)
        this.showSuccess(`File "${file.name}" uploaded successfully!`)
      } else if (response.status === 413) {
        this.showError('File is too large. Please upload a smaller file.')
      } else {
        const error = await response.json()
        this.showError(error.error || 'Upload failed')
      }
    } catch (error) {
      if (error.name !== 'AbortError') {
        console.error('Upload error:', error)
        this.showError('Upload failed. Please try again.')
      }
    } finally {
      this.hideSpinner()
      this.resetFileInput()
    }
  }

  showSuccess(message) {
    this.successMessageTarget.textContent = message
    this.successAlertTarget.classList.remove('d-none')
    setTimeout(() => this.hideAlerts(), 5000)
  }

  showError(message) {
    this.errorMessageTarget.textContent = message
    this.errorAlertTarget.classList.remove('d-none')
  }

  hideAlerts() {
    this.successAlertTarget.classList.add('d-none')
    this.errorAlertTarget.classList.add('d-none')
  }

  resetFileInput() {
    this.fileInputTarget.value = ''
  }
}
