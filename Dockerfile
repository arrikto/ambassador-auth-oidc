FROM golang:1.13 as builder

WORKDIR /go/src/ambassador-auth-oidc
# Download all dependencies
COPY go.mod .
COPY go.sum .
RUN go mod download
# Copy in the code and compile
COPY *.go /go/src/ambassador-auth-oidc/
RUN CGO_ENABLED=0 go build -a -o /go/bin/ambassador-auth-oidc

FROM alpine:3.10
LABEL org.label-schema.vcs-url="https://github.com/ajmyyra/ambassador-auth-oidc"
LABEL org.label-schema.version="1.3"
RUN apk update && apk add ca-certificates && rm -rf /var/cache/apk/*
RUN addgroup -S auth && adduser -S -G auth auth
USER auth
WORKDIR /app
COPY --from=builder /go/bin/ambassador-auth-oidc /app/
ENTRYPOINT [ "./ambassador-auth-oidc" ]
