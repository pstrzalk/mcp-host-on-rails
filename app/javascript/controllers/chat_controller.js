import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="chat"
export default class extends Controller {
  
  connect() {
    this.scrollToBottom()
  }

  scrollToBottom() {
    // Scroll the chat messages container to the bottom
    this.element.scrollTop = this.element.scrollHeight
  }

  // Called when new content is added to chat (can be triggered externally)
  contentAdded() {
    // Small delay to ensure content is rendered
    setTimeout(() => {
      this.scrollToBottom()
    }, 100)
  }
}