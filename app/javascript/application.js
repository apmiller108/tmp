// Entry point for the build script in your package.json
import "@hotwired/turbo-rails"
import "@rails/actiontext"
import * as ActiveStorage from "@rails/activestorage"
import "trix"
import "./controllers"
import WysiwygEditor from "../views/components/wysiwyg_editor_component/wysiwyg_editor_controller.js"
import TurboScrollPreservation from './TurboScrollPreservation'
import { Tooltip } from 'bootstrap'

// import * as ActionCable from '@rails/actioncable'
// ActionCable.logger.enabled = true;

ActiveStorage.start()

WysiwygEditor.applyTrixCustomConfiguration()

const turboScrollPreservation = new TurboScrollPreservation()
turboScrollPreservation.initialize()

// Allow turbo frame elements in popovers to lazy load content
const customTooltipAndPopoverAllowList = Tooltip.Default.allowList
customTooltipAndPopoverAllowList['turbo-frame'] = ['src', 'loading']
