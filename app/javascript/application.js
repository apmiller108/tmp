// Entry point for the build script in your package.json
import "@hotwired/turbo-rails"
import "@rails/actiontext"
import "trix"
import "./controllers"
import "./channels/hello_channel"
import TrixConfiguration from './wysiwyg/TrixConfiguration'

// import * as ActionCable from '@rails/actioncable'
// ActionCable.logger.enabled = true;

const trixConfiguration = new TrixConfiguration
trixConfiguration.initialize()
