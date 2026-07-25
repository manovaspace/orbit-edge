ARG REF=main
FROM golang:1.26-alpine AS builder
RUN apk add --no-cache git ca-certificates
ARG REF=main
WORKDIR /src
RUN git clone --depth=1 --branch "${REF}" https://github.com/manovaspace/orbit-notifications.git . \
	|| (git clone https://github.com/manovaspace/orbit-notifications.git . && git checkout "${REF}")
RUN go get github.com/manovaspace/orbit-observability@main \
	&& go mod tidy \
	&& CGO_ENABLED=0 go build -trimpath -ldflags="-s -w" -o /notifications ./cmd/notifications

FROM alpine:3.21
RUN apk add --no-cache ca-certificates
WORKDIR /app
COPY --from=builder /notifications /app/notifications
COPY --from=builder /src/migrations /app/migrations
EXPOSE 10110
USER nobody
CMD ["/app/notifications"]
