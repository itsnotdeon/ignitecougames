# IGNITE GitHub Pages Proxy

This project includes an optional Vercel-compatible proxy for browser QA against the
GitHub Pages deployment.

## Endpoint

After deploying this repository to Vercel:

- `/ignite` proxies the GitHub Pages root.
- `/ignite/redesign/index.html` proxies the redesigned app.
- Relative CSS, JavaScript, image, and module-import paths continue through the proxy.

The upstream is intentionally fixed to:

`https://itsnotdeon.github.io/ignitecougames`

The proxy does **not** accept an arbitrary destination URL or host. Only paths under
the IGNITE GitHub Pages prefix are forwarded.

## Local / deployment notes

The function is implemented in `api/ignite/[...path].js` and requires a Vercel
deployment (or another runtime that supports the same serverless handler contract).

This proxy exists to provide a same-origin browser-accessible QA surface when the
GitHub Pages origin itself is not reachable by the QA browser. It is not intended
to be an open web proxy.
