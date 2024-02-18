// Entry point for the build script in your package.json
import "@hotwired/turbo-rails"
import "@rails/actiontext"
import "trix"
import "./controllers"
import WysiwygEditor from "../views/components/wysiwyg_editor_component/wysiwyg_editor_controller.js"

WysiwygEditor.applyTrixCustomConfiguration()

// import * as ActionCable from '@rails/actioncable'
// ActionCable.logger.enabled = true;

