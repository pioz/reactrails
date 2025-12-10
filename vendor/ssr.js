(() => {
  // app/javascript/common.js
  var warningMessage = (componentName) => `React component "${componentName}" not found in globalThis.ReactRailsComponents registry.

Add your component in the React Rails registry:

import ${componentName} from './${componentName}'
globalThis.ReactRailsComponents = {
  ${componentName},
  Component1,
  Component2
}`;
  var loadProps = (componentName, jsonStringProps) => {
    jsonStringProps ||= "{}";
    let props = {};
    try {
      props = JSON.parse(jsonStringProps);
    } catch (e) {
      console.error(`Invalid JSON in data-react-props for ${componentName}`, e);
    }
    return props;
  };

  // app/javascript/ssr.js
  globalThis.renderComponent = (componentName, propsJson) => {
    const Component = globalThis.ReactRailsComponents[componentName];
    if (!Component) {
      throw new Error(warningMessage(componentName));
    }
    const props = loadProps(componentName, propsJson);
    const reactElement = globalThis.React.createElement(Component, props);
    return globalThis.ReactDOMServer.renderToString(reactElement);
  };
})();
//# sourceMappingURL=ssr.js.map
