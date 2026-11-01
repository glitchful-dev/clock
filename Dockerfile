FROM alpine:3.22@sha256:14358309a308569c32bdc37e2e0e9694be33a9d99e68afb0f5ff33cc1f695dce AS assets

RUN apk add --no-cache brotli
WORKDIR /src
COPY public/ ./dist/

RUN find dist -type f \
      -regex '.*\.\(html\|js\|mjs\|css\|svg\|json\|txt\|xml\|webmanifest\)' \
      -print0 \
    | xargs -0 -n1 sh -c 'gzip -9 -k "$1" && brotli -q 11 -k "$1"' _

# epoch mtimes keep the /public layer digest identical for identical content
RUN find dist -exec touch -d @0 {} +

FROM ghcr.io/static-web-server/static-web-server:2@sha256:2c1a7c3e0feaea5859307403b74e1c575f3ec1499094fc077344173d11abaae2
LABEL org.opencontainers.image.source="https://github.com/glitchful-dev/clock"

COPY --from=assets /src/dist /public

USER 65534
EXPOSE 8080

CMD ["--root", "/public", \
     "--port", "8080", \
     "--compression-static", "true", \
     "--cache-control-headers", "true"]
