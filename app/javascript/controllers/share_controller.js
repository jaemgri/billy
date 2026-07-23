import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { title: String, text: String, url: String }

  async share(event) {
    const data = {
      title: this.titleValue,
      text: this.textValue,
      url: this.urlValue,
    }

    if (navigator.share) {
      try {
        await navigator.share(data)
      } catch (err) {
        // AbortError = user cancelled; ignore it
        if (err.name !== "AbortError") console.error(err)
      }
    } else if (navigator.clipboard) {
      // Fallback for browsers without Web Share (e.g. desktop Firefox)
      await navigator.clipboard.writeText(this.urlValue)
      event.target.textContent = "Link copied!"
    } else {
      window.prompt("Copy this link:", this.urlValue)
    }
  }
}
