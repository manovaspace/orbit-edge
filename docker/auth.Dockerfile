# Standalone build from public github.com/manovaspace/orbit-auth (no monorepo).
# ARG REF selects git ref (branch, tag, or commit SHA).
ARG REF=main
FROM golang:1.26-alpine AS builder
RUN apk add --no-cache git ca-certificates
ARG REF=main
WORKDIR /src
RUN git clone --depth=1 --branch "${REF}" https://github.com/manovaspace/orbit-auth.git . \
	|| (git clone https://github.com/manovaspace/orbit-auth.git . && git checkout "${REF}")
# Refresh module pins after force-pushes on dependency repos
RUN go get github.com/manovaspace/orbit-notifications@main \
	&& go get github.com/manovaspace/orbit-observability@main \
	&& go mod tidy \
	&& CGO_ENABLED=0 go build -trimpath -ldflags="-s -w" -o /auth ./cmd/auth

FROM alpine:3.24
RUN apk add --no-cache ca-certificates
WORKDIR /app
COPY --from=builder /auth /app/auth
COPY --from=builder /src/migrations /app/migrations
EXPOSE 10100
USER nobody
CMD ["/app/auth"]
