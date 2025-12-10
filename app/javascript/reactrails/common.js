const warningMessage = (
  componentName
) => `React component "${componentName}" not found in globalThis.ReactRailsComponents registry.

Add your component in the React Rails registry:

import ${componentName} from './${componentName}'
globalThis.ReactRailsComponents = {
  ${componentName},
  Component1,
  Component2
}`

const loadProps = (componentName, jsonStringProps) => {
  jsonStringProps ||= '{}'
  let props = {}
  try {
    props = JSON.parse(jsonStringProps)
  } catch (e) {
    console.error(`Invalid JSON in data-react-props for ${componentName}`, e)
  }
  return props
}

export { warningMessage, loadProps }
