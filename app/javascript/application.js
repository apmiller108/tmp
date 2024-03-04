// Entry point for the build script in your package.json
import "@hotwired/turbo-rails"
import "@rails/actiontext"
import "trix"
import "./controllers"
import WysiwygEditor from "../views/components/wysiwyg_editor_component/wysiwyg_editor_controller.js"
import TurboScrollPreservation from './TurboScrollPreservation'
import { Popover } from 'bootstrap'

WysiwygEditor.applyTrixCustomConfiguration()

const turboScrollPreservation = new TurboScrollPreservation()
turboScrollPreservation.initialize()

const bsPopoverAllowList = Popover.Default.allowList
bsPopoverAllowList['turbo-frame'] = ['src', 'lazy']

// import * as ActionCable from '@rails/actioncable'
// ActionCable.logger.enabled = true;


