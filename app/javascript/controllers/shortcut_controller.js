import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="shortcut"
export default class extends Controller {
  static targets = ["textarea", "form", "submitButton"]

  connect() {
    this.setupKeyboardShortcuts()
    this.setupFormSubmissionFeedback()
  }

  setupKeyboardShortcuts() {
    // Add event listener to the textarea target
    if (this.hasTextareaTarget) {
      this.textareaTarget.addEventListener('keydown', this.handleKeydown.bind(this))
    }
  }

  setupFormSubmissionFeedback() {
    if (this.hasFormTarget) {
      this.formTarget.addEventListener('turbo:submit-start', this.showLoadingState.bind(this))
      this.formTarget.addEventListener('turbo:submit-end', this.hideLoadingState.bind(this))
    }
  }

  handleKeydown(event) {
    // Check for CMD+Enter (Mac) or Ctrl+Enter (Windows/Linux)
    if ((event.metaKey || event.ctrlKey) && event.key === 'Enter') {
      event.preventDefault()
      this.submitForm()
    }
  }

  submitForm() {
    // Submit the form target
    if (this.hasFormTarget) {
      this.formTarget.requestSubmit()
    } else {
      console.log("No form target found")
    }
  }

  showLoadingState() {
    // Disable textarea and submit button
    if (this.hasTextareaTarget) {
      this.textareaTarget.disabled = true
      this.textareaTarget.classList.add('opacity-50')
    }
    
    if (this.hasSubmitButtonTarget) {
      this.originalButtonText = this.submitButtonTarget.innerHTML
      this.submitButtonTarget.disabled = true
      this.submitButtonTarget.classList.add('opacity-75', 'cursor-not-allowed')
      this.submitButtonTarget.innerHTML = `
        <svg class="animate-spin -ml-1 mr-3 h-5 w-5 text-white inline" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
          <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
          <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
        </svg>
        Sending...
      `
    }
  }

  hideLoadingState() {
    // Re-enable textarea and submit button
    if (this.hasTextareaTarget) {
      this.textareaTarget.disabled = false
      this.textareaTarget.classList.remove('opacity-50')
    }
    
    if (this.hasSubmitButtonTarget) {
      this.submitButtonTarget.disabled = false
      this.submitButtonTarget.classList.remove('opacity-75', 'cursor-not-allowed')
      this.submitButtonTarget.innerHTML = this.originalButtonText || 'Send'
    }
  }
}
