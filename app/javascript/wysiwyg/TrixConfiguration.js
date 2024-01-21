import TrixCustomizer from './TrixCustomizer'

export default class TrixConfiguration {
  static beforeInitialize = 'trix-before-initialize'
  static selectionChange = 'trix-selection-change'
  static headings = ["h1", "h2", "h3", "h4", "h5", "h6"]

  config = Trix.config

  initialize() {
    document.addEventListener(TrixConfiguration.beforeInitialize, (e) => {
      const customizer = new TrixCustomizer(e.target)
      customizer.applyCustomizations()
    })

    this.configureHeadings()
    this.configureHighlight()
  }

  configureHeadings() {
    TrixConfiguration.headings.forEach((tagName, i) => {
      const attribute = `heading${i + 1}`
      this.config.blockAttributes[attribute] = {
        tagName,
        terminal: true,
        breakOnReturn: true,
        group: false
      }
    });
  }

  configureHighlight() {
    this.config.textAttributes.highlight = {
      tagName: 'mark',
      inheritable: true,
    }
  }
}
