import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "warning"]
  static values = { billAmount: Number, otherSplitsTotal: Number }

  check() {
    const value = parseFloat(this.inputTarget.value) || 0
    const remaining = this.billAmountValue - this.otherSplitsTotalValue
    const overBy = value - remaining

    if (overBy > 0) {
      this.warningTarget.textContent = `This exceeds the remaining ¥${remaining.toFixed(0)} by ¥${overBy.toFixed(0)}`
      this.warningTarget.classList.remove("d-none")
    } else {
      this.warningTarget.textContent = ""
      this.warningTarget.classList.add("d-none")
    }
  }
}
