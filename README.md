# clock

A clock. One HTML file, no dependencies, no network, no build.

Open `public/index.html`.

Deployed as an OCI image: a push to `main` builds `ghcr.io/glitchful-dev/site-clock`
via the shared workflow in `glitchful-dev/home-lab`, and the cluster pulls it by
digest. Nothing here knows about the cluster; the cluster does not know this repo
exists. They meet at one `@sha256:` string in an infra-repo PR.

## Use

- **Click the time** — cycle format: `hh:mm:ss` → `hh:mm:ss.xxx` → `hh:mm`
- **Click anywhere else** — toggle light/dark (defaults to your system theme)

## How

Vanilla JS in ~50 lines. A `requestAnimationFrame` loop formats the current
time and touches the DOM only when the text actually changes — so seconds
flip instantly, nothing blinks, and idle frames cost a string compare.
Theming is pure CSS: custom properties, a `prefers-color-scheme` media query
for the default, and a `data-theme` attribute once you've clicked. System
font, tabular digits.
