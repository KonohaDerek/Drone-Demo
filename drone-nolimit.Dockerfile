FROM golang:latest AS builder
ARG GOARCH
ARG GOOS
RUN dpkg --add-architecture amd64
RUN apt-get update && apt-get install -y --no-install-recommends gcc-x86-64-linux-gnu libc6-dev-amd64-cross ca-certificates tzdata
RUN git clone -b v2.14.0 --depth=1 https://github.com/drone/drone
# RUN cd drone && GOOS=linux GOARCH=amd64 go install -trimpath -ldflags='-w -s' -tags nolimit ./cmd/drone-server
# RUN cd drone && GOARCH=${GOARCH} CGO_ENABLED=1 GOOS=${GOOS} go build  -gcflags=-trimpath=$GOPATH -asmflags=-trimpath=$GOPATH -ldflags "-w -s -extldflags \"-static\"" -o /go/bin/${GOOS}_${GOARCH}/drone-server ./cmd/drone-server
WORKDIR drone
RUN go mod tidy
RUN go mod vendor
RUN GOARCH=${GOARCH} CGO_ENABLED=1 GOOS=${GOOS} go build -o /dev/null -tags "nolimit" github.com/drone/drone/cmd/drone-server
RUN GOARCH=${GOARCH} CGO_ENABLED=1 GOOS=${GOOS} go build -ldflags "-w -s -extldflags \"-static\"" -tags "nolimit"  -o /go/bin/${GOOS}_${GOARCH}/drone-server github.com/drone/drone/cmd/drone-server

FROM alpine:3.11

ARG GOARCH
ARG GOOS

EXPOSE 80 443
VOLUME /data
RUN [ ! -e /etc/nsswitch.conf ] && echo 'hosts: files dns' > /etc/nsswitch.conf

ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ENV GODEBUG=netdns=go
ENV XDG_CACHE_HOME=/data
ENV DRONE_DATABASE_DRIVER=sqlite3
ENV DRONE_DATABASE_DATASOURCE=/data/database.sqlite
ENV DRONE_RUNNER_OS=${GOOS}
ENV DRONE_RUNNER_ARCH=${GOARCH}
ENV DRONE_SERVER_PORT=:80z
ENV DRONE_SERVER_HOST=localhost
ENV DRONE_DATADOG_ENABLED=true
ENV DRONE_DATADOG_ENDPOINT=https://stats.drone.ci/api/v1/series

COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /usr/share/zoneinfo /usr/share/zoneinfo
COPY --from=builder /go/bin/${GOOS}_${GOARCH}/drone-server /bin/

# ADD release/{GOOS}/amd64/drone-server /bin/
ENTRYPOINT ["/bin/drone-server"]