# How this site becomes an image. Self-contained on purpose: `docker build .` in
# this repo produces exactly what CI produces, so the packaging can be tested
# and debugged without pushing anything.
#
# The shared workflow in glitchful-dev/home-lab builds this file with THIS repo
# as the build context. It does not inject or generate a Dockerfile when one is
# present here.
#
# Both stages are digest-pinned, and both carry their tag: a bare digest gives
# Renovate no current version to compare against, so it resolves the image
# against :latest instead.

# ---------------------------------------------------------------- assets ------
# Only here to run gzip and brotli -- there is nothing to compile. The final
# image contains none of this.
FROM alpine:3.22@sha256:14358309a308569c32bdc37e2e0e9694be33a9d99e68afb0f5ff33cc1f695dce AS assets

RUN apk add --no-cache brotli gzip
WORKDIR /src
COPY public/ ./dist/

# Pre-compress at build time, at maximum quality. static-web-server then serves
# the .br/.gz sibling straight off disk, so the running container spends zero CPU
# compressing and every byte is squeezed as hard as it will go -- a cost paid once
# here instead of on every cache miss forever.
RUN find dist -type f \
      -regex '.*\.\(html\|js\|mjs\|css\|svg\|json\|txt\|xml\|webmanifest\)' \
      -exec sh -c 'gzip -9 -k "$1"; brotli -q 11 -k "$1"' _ {} \;

# Normalise every mtime to the epoch.
#
# MEASURED, 2026-08-21: with the flags below this image sends Cache-Control and
# NO ETag and NO Last-Modified. Spec 2 §3.3 calls mtime normalisation mandatory
# because "filesystem-derived validators must not rotate per deploy" -- but there
# are currently no validators at all to rotate, so that rationale does not hold
# as written, and a revalidation costs a full body rather than a 304.
#
# Kept regardless, for a reason that is real today: it stabilises BuildKit's COPY
# cache key, so a rebuild of unchanged assets hits the layer cache. And it makes
# this correct in advance of enabling validators.
#
# TODO: find the static-web-server option that emits ETag (or accept
# Cache-Control-only caching) and re-measure. Until then §3.6's "index.html
# revalidates cheaply" is optimistic.
RUN find dist -exec touch -d @0 {} +

# ----------------------------------------------------------------- serve ------
# Rust, single static binary, scratch base: ~4 MB image, 2-8 MB RSS, no shell and
# no package manager, so the CVE surface is the binary alone.
FROM ghcr.io/static-web-server/static-web-server:2@sha256:2c1a7c3e0feaea5859307403b74e1c575f3ec1499094fc077344173d11abaae2

COPY --from=assets /src/dist /public

# 65534 (nobody). The container needs write access to nothing, and 8080 is above
# 1024 so it binds without privileges. 8080 is also the uniform ingress target
# every apps/edge/config.yml entry points at, so the tunnel config does not need
# to know anything site-specific.
USER 65534
EXPOSE 8080

# --compression-static serves the .br/.gz produced above instead of compressing
# per request. --cache-control-headers emits the ETag and Cache-Control that the
# edge cache rules depend on.
#
# Deliberately no --page-fallback: this is a content site, not an SPA. A fallback
# turns every 404 into a 200 serving index.html, which hides broken links and lets
# the edge cache a wrong body under a wrong URL.
CMD ["--root", "/public", \
     "--port", "8080", \
     "--compression-static", "true", \
     "--cache-control-headers", "true"]
