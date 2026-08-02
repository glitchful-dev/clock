# clock

A clock. One HTML file, no dependencies, no network, no build.

Open `index.html`.

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
