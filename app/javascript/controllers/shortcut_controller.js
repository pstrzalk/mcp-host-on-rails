import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="shortcut"
export default class extends Controller {
  static targets = ["textarea", "form"]

  connect() {
    this.setupKeyboardShortcuts()
  }

  setupKeyboardShortcuts() {
    // Add event listener to the textarea target
    if (this.hasTextareaTarget) {
      this.textareaTarget.addEventListener('keydown', this.handleKeydown.bind(this))
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
}
