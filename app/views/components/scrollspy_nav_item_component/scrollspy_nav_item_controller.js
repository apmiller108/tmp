import { Controller } from "@hotwired/stimulus"

export default class ScrollspyNavItem extends Controller {
  static targets = ['link']

  // Clicking on the icon nested inside the anchor tag breaks the scrollspy.
  // This delegate the click event to the anchor
  onClickIcon(e) {
    e.preventDefault()
    e.stopPropagation()
    this.linkTarget.click()
  }

  onClickLink(e) {
    // Remove focus on link so the tooltip will be hidden on mouseleave
    e.target.blur()
  }
}
