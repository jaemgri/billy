import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["fileInput", "button", "nameField", "descriptionField", "amountField", "categoryField", "dueDateField"]

  trigger() {
    this.fileInputTarget.click()
  }

  async upload(event) {
    const file = event.target.files[0]
    if (!file) return

    const originalText = this.buttonTarget.textContent
    this.buttonTarget.textContent = "Billy is thinking..."
    this.buttonTarget.disabled = true

    const formData = new FormData()
    formData.append("image", file)

    try {
      const csrfToken = document.querySelector('meta[name="csrf-token"]').content
      const response = await fetch("/bills/extract_from_image", {
        method: "POST",
        headers: { "X-CSRF-Token": csrfToken },
        body: formData
      })
      const data = await response.json()

      if (data.name) this.nameFieldTarget.value = data.name
      if (data.description) this.descriptionFieldTarget.value = data.description
      if (data.amount) this.amountFieldTarget.value = data.amount
      if (data.category) this.categoryFieldTarget.value = data.category
      if (data.due_date) this.dueDateFieldTarget.value = data.due_date
    } catch (e) {
      alert("Failed to analyze image. Please try again.")
    } finally {
      this.buttonTarget.textContent = originalText
      this.buttonTarget.disabled = false
      this.fileInputTarget.value = ""
    }
  }
}
