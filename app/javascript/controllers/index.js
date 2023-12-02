import { application } from "./application"
// The ability to use globbing depends on esbuild-rails npm package
import controllers from './**/*_controller.js'
import componentControllers from '../../views/components/**/*_controller.js'

// Simplifies the controller name, but preserves some meaningful namespacing
// Ex:
//   app/views/components/foo/bar_controller.js -> foo--bar
//   app/assets/javascript/home_controller.js -> home
const controllerName = (defaultName) => {
  const namespaces = [
    ...new Set(defaultName.split("--").filter((pathSegment) => !["..", "views", "components"].includes(pathSegment))),
  ];
  return namespaces.join("--");
};
controllers.concat(componentControllers).forEach((controller) => {
  application.register(controllerName(controller.name), controller.module.default)
});
