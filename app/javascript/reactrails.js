const warningMessage = (componentName) => `React component "${componentName}" is not registered.

Add your component in the React Rails registry:

---
import React from 'react'
import ReactDOMClient from 'react-dom/client'
import ReactDOMServer from 'react-dom/server'

import ${componentName} from './${componentName}'

initReactRails(React, ReactDOMClient, ReactDOMServer, {
  ${componentName},
  Component1,
  Component2
})
---`

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

const init = (React, ReactDOMClient, ReactDOMServer, registryComponents) => {
  const loadComponents = () => {
    console.log('LOAD REACT COMPONENTS')
    const nodes = document.querySelectorAll('[data-react-component]')

    nodes.forEach((el) => {
      const componentName = el.dataset.reactComponent
      const Component = registryComponents?.[componentName] || null
      if (!Component) {
        console.error(warningMessage(componentName))
        return
      }

      const props = loadProps(componentName, el.dataset.reactProps)
      const reactElement = React.createElement(Component, props)

      // If server rendered, use hydrateRoot; otherwise createRoot.
      if (el.hasChildNodes()) {
        ReactDOMClient.hydrateRoot(el, reactElement)
      } else {
        const root = ReactDOMClient.createRoot(el)
        root.render(reactElement)
      }
    })
  }

  if (typeof document !== 'undefined') {
    // document.addEventListener('DOMContentLoaded', loadComponents)
    document.addEventListener('turbo:load', loadComponents)
  }

  if (ReactDOMServer) {
    globalThis.renderComponent = (componentName, propsJson) => {
      const Component = registryComponents?.[componentName] || null
      if (!Component) {
        throw new Error(warningMessage(componentName))
      }

      const props = loadProps(componentName, propsJson)
      const reactElement = React.createElement(Component, props)
      return ReactDOMServer.renderToString(reactElement)
    }
  }
}

globalThis.initReactRails = init
