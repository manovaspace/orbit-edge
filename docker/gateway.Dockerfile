ARG REF=main
FROM golang:1.26-alpine AS builder
RUN apk add --no-cache git ca-certificates
ARG REF=main
WORKDIR /src
RUN git clone --depth=1 --branch "${REF}" https://github.com/manovaspace/orbit-api-gateway.git . \
	|| (git clone https://github.com/manovaspace/orbit-api-gateway.git . && git checkout "${REF}")
RUN go get github.com/manovaspace/orbit-auth@main \
	&& go get github.com/manovaspace/orbit-observability@main \
	&& go get github.com/manovaspace/orbit-rate-limiting@main \
	&& go mod tidy \
	&& CGO_ENABLED=0 go build -trimpath -ldflags="-s -w" -o /gateway ./cmd/gateway

FROM alpine:3.21
RUN apk add --no-cache ca-certificates
WORKDIR /app
COPY --from=builder /gateway /app/gateway
COPY --from=builder /src/openapi /app/openapi
EXPOSE 10120 10121
USER nobody
CMD ["/app/gateway"]
