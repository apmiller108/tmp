// Entry point for the build script in your package.json
import "@hotwired/turbo-rails"
import "@rails/actiontext"
import "trix"
import * as bootstrap from "bootstrap"
import * as ActionCable from '@rails/actioncable'

import "./controllers"
import "./channels/hello_channel"
import TrixHandler from './wysiwyg/TrixHandler'

// ActionCable.logger.enabled = true;

const trixHandler = new TrixHandler
trixHandler.initialize()
