FROM codesimple/elm:0.19 AS elm-builder
WORKDIR /root
COPY . .
RUN elm make --optimize --output ./dist/js/main.elm.js ./src/Main.elm

FROM golang:alpine3.17 AS go-builder
RUN apk update && apk add make
WORKDIR /root
COPY --from=elm-builder /root .
RUN make go-wasm
RUN go install github.com/sharpvik/serve@latest # => /go/bin/serve

FROM alpine:3.17
RUN apk add --no-cache ca-certificates
WORKDIR /root
COPY --from=go-builder /root/dist ./dist
COPY --from=go-builder /go/bin/serve .
EXPOSE 8000
CMD [ "/root/serve", "--dir", "/root/dist", "--port", "8000", "--share" ]
