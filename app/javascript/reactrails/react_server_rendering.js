import React from 'react'
import ReactDOMServer from 'react-dom/server.browser'

import { loadProps, warningMessage } from './common'

globalThis.renderComponent = (componentName, propsJson) => {
  const Component = globalThis.ReactRailsComponents[componentName]
  if (!Component) {
    throw new Error(warningMessage(componentName))
  }

  const props = loadProps(componentName, propsJson)
  const reactElement = React.createElement(Component, props)
  return ReactDOMServer.renderToString(reactElement)
}
