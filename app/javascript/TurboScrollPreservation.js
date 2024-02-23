export default class TurboScrollPreservation {
  static dataSelector = '[data-preserve-scroll]'

  initialize() {
    this.initScrollPositionsStore()

    window.addEventListener("turbo:before-cache", this.cacheScrollPosition.bind(this))
    window.addEventListener("turbo:before-fetch-request", this.cacheScrollPosition.bind(this))

    window.addEventListener("turbo:before-render", this.restoreScrollPosition.bind(this))
    window.addEventListener("turbo:render", this.restoreScrollPosition.bind(this))
  }

  get scrollPositions() {
    return window.scrollPositions
  }

  set scrollPositions(positions) {
    window.scrollPositions = positions
  }

  scrollPosition(id) {
    return this.scrollPositions[id]
  }

  setScrollPosition({ id, scrollTop }) {
    this.scrollPositions[id] = scrollTop
  }

  initScrollPositionsStore() {
    if (!this.scrollPositions) {
      this.scrollPositions = {}
    }
  }

  cacheScrollPosition() {
    document.querySelectorAll(TurboScrollPreservation.dataSelector).forEach(elem => {
      if (!elem.id) {
        return console.warn('ID is required for elements with data-preserve-scroll')
      }
      this.setScrollPosition(elem)
    })
  }

  restoreScrollPosition() {
    document.querySelectorAll(TurboScrollPreservation.dataSelector).forEach((elem) => {
      const cachedPosition = this.scrollPosition(elem.id)
      if (cachedPosition) {
        elem.scrollTop = cachedPosition
      }
    })
  }
}
