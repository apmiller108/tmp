import TrixCustomizer from './TrixCustomizer'

export default class TrixHandler {
  static initEventName = 'trix-before-initialize'

  initialize() {
    document.addEventListener(TrixHandler.initEventName, (e) => new TrixCustomizer(e.target) )
  }
}
