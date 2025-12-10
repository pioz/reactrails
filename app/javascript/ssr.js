import { loadProps, warningMessage } from './common'

globalThis.renderComponent = (componentName, propsJson) => {
  const Component = globalThis.ReactRailsComponents[componentName]
  if (!Component) {
    throw new Error(warningMessage(componentName))
  }

  const props = loadProps(componentName, propsJson)
  const reactElement = globalThis.React.createElement(Component, props)
  return globalThis.ReactDOMServer.renderToString(reactElement)
}
