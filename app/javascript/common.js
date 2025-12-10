const warningMessage = (componentName) => `React component "${componentName}" is not registered.

Add your component in the React Rails registry:

import registerComponents from 'reactrails/registerComponents'
import ${componentName} from './${componentName}'
registerComponents({
  ${componentName},
  Component1,
  Component2
})`

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
