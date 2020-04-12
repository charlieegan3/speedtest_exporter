# Copyright (C) 2016-2019 Nicolas Lamirault <nicolas.lamirault@gmail.com>

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM golang:alpine as builder

ENV CGO_ENABLED=0
ENV GOOS=linux
ENV GOARCH=amd64
ENV GO111MODULE=on

RUN apk update \
    && apk add --no-cache git ca-certificates tzdata \
    && update-ca-certificates

RUN adduser -D -g '' appuser

ADD . ${GOPATH}/src/app/
WORKDIR ${GOPATH}/src/app

ARG go_arch
RUN GOARCH=${go_arch} go build -a -installsuffix cgo -ldflags="-w -s" -o /go/bin/speedtest_exporter

# --------------------------------------------------------------------------------

# needed for arm base
FROM alpine:3.11

COPY --from=builder /go/bin/speedtest_exporter /usr/bin/speedtest_exporter

EXPOSE 9112

ENTRYPOINT [ "/usr/bin/speedtest_exporter" ]
