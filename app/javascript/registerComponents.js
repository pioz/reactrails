import React from 'react'
import ReactDOMServer from 'react-dom/server'

const registerComponents = (components) => {
  globalThis.React = React
  globalThis.ReactDOMServer = ReactDOMServer
  globalThis.ReactRailsComponents = components
}

export default registerComponents
