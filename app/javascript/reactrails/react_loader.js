import React from 'react'
import { createRoot, hydrateRoot } from 'react-dom/client'

import { loadProps, warningMessage } from './common'

const loadComponents = () => {
  console.log('LOAD REACT COMPONENTS')
  const nodes = document.querySelectorAll('[data-react-component]')

  nodes.forEach((el) => {
    const componentName = el.dataset.reactComponent
    const Component = globalThis?.ReactRailsComponents?.[componentName] || null
    if (!Component) {
      console.error(warningMessage(componentName))
      return
    }

    const props = loadProps(componentName, el.dataset.reactProps)
    const reactElement = React.createElement(Component, props)

    // If server rendered, use hydrateRoot; otherwise createRoot.
    if (el.hasChildNodes()) {
      hydrateRoot(el, reactElement)
    } else {
      const root = createRoot(el)
      root.render(reactElement)
    }
  })
}

// document.addEventListener('DOMContentLoaded', loadComponents)
document.addEventListener('turbo:load', loadComponents)
