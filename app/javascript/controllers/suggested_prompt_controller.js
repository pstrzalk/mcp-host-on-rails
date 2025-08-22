import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="suggested-prompt"
export default class extends Controller {
  static values = { text: String }

  fillPrompt() {
    // Find the chat prompt input field
    const promptInput = document.getElementById('chat-prompt-input')
    
    if (promptInput && this.textValue) {
      // Fill the input with the suggested prompt text
      promptInput.value = this.textValue
      
      // Focus the input and move cursor to end
      promptInput.focus()
      promptInput.setSelectionRange(promptInput.value.length, promptInput.value.length)
      
      // Optional: scroll to the input area
      promptInput.scrollIntoView({ behavior: 'smooth', block: 'center' })
    }
  }
}