import { Controller } from '@hotwired/stimulus'
import { ScrollSpy } from 'bootstrap'

export default class ScrollspyController extends Controller {
  static targets = ['nav', 'navItem']

  get containerId() {
    return this.element.dataset.containerId
  }

  get targetId() {
    return this.element.dataset.targetId
  }

  connect() {
    const scrollableContainer = document.getElementById(this.containerId)
    this.scrollSpy = new ScrollSpy(scrollableContainer, {
      target: this.targetId,
      smoothScroll: true,
      threshold: [0, 0.25, 0.5, 0.75, 1]
    })

    scrollableContainer.addEventListener('activate.bs.scrollspy', this.scrollToActiveNav.bind(this))
  }

  disconnect() {
    scrollableContainer.removeEventListener('activate.bs.scrollspy', this.scrollToActiveNav.bind(this))
  }

  scrollToActiveNav() {
    const activeNav = this.navItemTargets.find(i => i.querySelector('a').classList.contains('active'))
    activeNav.scrollIntoView({
      behavior: 'smooth'
    })
  }

  navItemTargetConnected() {
    this.refresh(false)
    this.dispatch('navItemsChanged')
  }

  navItemTargetDisconnected() {
    this.refresh()
  }

  async refresh(navigate = true) {
    await setTimeout(() => this.scrollSpy?.refresh(), 0)
    if (navigate) {
      this.navTarget.lastElementChild.click()
    }
  }
}
