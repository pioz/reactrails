# Reactrails

Reactrails is a Rails engine designed to seamlessly integrate **React** into
a **Rails** application using a modern **esbuild**-based toolchain, with
optional **server-side rendering (SSR)** powered by Node.js.

It provides:

- A simple **view helper** to render React components in your Rails views.
- Automatic **client-side rendering or hydration** using a lightweight loader script.
- Optional **SSR support** for better SEO, improved perceived performance, and a faster first paint.

---

## Installation

Add the gem to your `Gemfile`:

```ruby
gem "reactrails", github: "pioz/reactrails"
```

Then install:

```sh
bundle install
```

Run the installer:

```sh
bin/rails generate reactrails:install
```

This generator will:

1. Insert `javascript_include_tag "reactrails"` in your layout.
2. Create `app/javascript/components/index.js` as an entry point for your components.
3. Import this file from `app/javascript/application.js`.
4. Add `yarn build:ssr` to your `package.json`.
5. Add `ssr: yarn build:ssr --watch` to your `Procfile.dev`.
6. Create the initializer `config/initializers/reactrails.rb`.

---

## Usage

### Register your React components

Reactrails must be initialized by calling the global `initReactRails` function
included via `javascript_include_tag "reactrails"`.

This function accepts:

- `React`
- `ReactDOMClient`
- (optional) `ReactDOMServer` — required if you want SSR
- a **registry object** mapping names to components

Example (`app/javascript/components/index.js`):

```js
import React from 'react'
import ReactDOMClient from 'react-dom/client'
import ReactDOMServer from 'react-dom/server'

import Hello from './Hello'
import Counter from './Counter'

initReactRails(React, ReactDOMClient, ReactDOMServer, {
  Hello,
  Counter
})
```

Make sure this file is bundled by your esbuild setup (for example into `app/assets/builds`).

Reactrails also expects an SSR build of this file at:

```
app/assets/builds/ssr/index.js
```

You can customize this path inside the initializer.

---

## Rendering components in Rails views

Reactrails exposes a single helper:

```ruby
render_component(component_name, props = {}, options = {})
```

Parameters:

- **component_name** — the key used in your JavaScript registry
- **props** — a Ruby hash serialized to JSON
- **options**:
  - `prerender`: enables server-side rendering (SSR)
  - `tag`: the HTML tag to wrap the component (default: `:div`)
  - `html_options`: HTML attributes for the wrapper tag

---

### Client-side rendering

```ruby
<%= render_component "Hello", { name: "Enrico" } %>
```

This will:

1. Output a `<div>` with `data-react-component` and `data-react-props`.
2. Let the client-side loader detect the node and mount the React component via `createRoot`.

---

### Server-side rendering (SSR)

```ruby
<%= render_component "Hello", { name: "Enrico" }, prerender: true %>
```

With `prerender: true`:

1. Reactrails renders the component to an HTML string using Node.js.
2. The markup is embedded inside the wrapper element.
3. On the client side, React hydrates the existing HTML using `hydrateRoot`.

---

## Configuration

Configure Reactrails in `config/initializers/reactrails.rb`. Available options:

- `ssr_init_reactrails_bundle_path` — custom path for the SSR bundle (the build containing your `initReactRails` call).
- `ssr_preload_code` — optional JavaScript executed before SSR, useful for polyfills or exposing globals.

Example:

```ruby
Reactrails.configure do |config|
  config.ssr_init_reactrails_bundle_path = Rails.root.join("app/assets/builds/ssr/index.js")
  config.ssr_preload_code = "// custom global setup"
end
```

---

## How it works internally

### Client loader

The client script:

1. Listens for `turbo:load`.
2. Scans for `[data-react-component]` elements.
3. Reads component names and props.
4. Looks up the component in your registry.
5. Creates a React element.
6. Hydrates if the element already contains HTML, otherwise renders it fresh.

### Server-side rendering

SSR is handled by `Reactrails::ReactRenderer`, which:

1. Reads:
   - Your SSR bundle (`build:ssr`)
   - The gem’s internal SSR runtime (`reactrails.js`)

2. Concatenates & evaluates them inside a Node.js context.
3. Calls:

```
renderComponent(component_name, props_json)
```

which is implemented within the JavaScript runtime.

---

## Troubleshooting

### **Node executable not found**

You may see errors like:

> `Node executable not found`

Solutions:

- Ensure Node.js is installed.
- Make sure `node` is available in your PATH.
- Optionally set:

```sh
export NODE_BINARY_PATH=/path/to/node
```

### **SSR bundle missing**

If you see:

> `Cannot read file app/assets/builds/ssr/index.js`

then your SSR bundle hasn't been built.

Run:

```sh
yarn build:ssr
```

or keep it updated automatically:

```sh
yarn build:ssr --watch
```

### **Components not mounting on the client**

Check:

- The component is registered in `initReactRails`.
- The wrapper element appears in the DOM.
- The props JSON is valid (errors are logged to the console).
- Turbo is enabled; if you don't use Turbo, manually call `loadComponents()`.

---

## Rebuilding gem assets

To rebuild the gem's internal JS bundles:

```sh
bundle install
yarn install
yarn build
```

This regenerates `app/assets/builds/reactrails.js`.

---

## Questions or issues?

Please open an issue or pull request on GitHub:
[https://github.com/pioz/reactrails/issues](https://github.com/pioz/reactrails/issues)

---

## License

Copyright (c) 2025
[Enrico Pilotto (@pioz)](https://github.com/pioz).
Released under the MIT License.
