# clock

A clock. One HTML file, no dependencies, no network, no build.

Open `public/index.html`, or run it the way it is served in production:

```
docker build -t clock . && docker run --rm -p 8080:8080 clock
```

Deployed as an OCI image: a push to `main` builds this repo's `Dockerfile` and pushes
`ghcr.io/glitchful-dev/site-clock`. The run summary prints the reference, which
`glitchful-dev/home-lab` pins to deploy it. Nothing here knows about the cluster.

## Use

- **Click the time** (or focus it and press Enter/Space) — cycle format: `hh:mm:ss` → `hh:mm:ss.xxx` → `hh:mm`
- **Click anywhere else**, or press **t** — toggle light/dark (defaults to your system theme)

## How

Vanilla JS in ~50 lines. A `requestAnimationFrame` loop formats the current
time and touches the DOM only when the text actually changes — so seconds
flip instantly, nothing blinks, and idle frames cost a string compare.
Styling uses the [Glitchful design system](https://github.com/glitchful-dev/design-system)
tokens, vendored as `public/ds-tokens-<version>.css` so the page still needs no network and
no build. The tokens follow `prefers-color-scheme` by default and a `data-theme` attribute once
you've clicked. Mono, tabular digits. To update the tokens, replace that file with the
new version's `tokens.css` and change the `<link>`; the version in the name keeps caches honest.
