FROM golang:latest as BUILDER

MAINTAINER zengchen1024<chenzeng765@gmail.com>

# build binary
COPY . /go/src/github.com/opensourceways/xihe-training-center
WORKDIR /go/src/github.com/opensourceways/xihe-training-center
RUN cd huaweicloud && GO111MODULE=on CGO_ENABLED=0 go build -o xihe-training-center
RUN tar -xf ./huaweicloud/trainingimpl/tools/obsutil.tar.gz

# copy binary config and utils
FROM alpine:3.14
RUN apk update && apk add --no-cache \
        git \
        bash \
        libc6-compat

RUN adduser mindspore -u 5000 -D
WORKDIR /opt/app
RUN chown -R mindspore:mindspore /opt/app

COPY --chown=mindspore:mindspore --from=BUILDER /go/src/github.com/opensourceways/xihe-training-center/huaweicloud/xihe-training-center /opt/app
COPY --chown=mindspore:mindspore --from=BUILDER /go/src/github.com/opensourceways/xihe-training-center/obsutil /opt/app
COPY --chown=mindspore:mindspore --from=BUILDER /go/src/github.com/opensourceways/xihe-training-center/huaweicloud/trainingimpl/tools/sync_files.sh /opt/app
COPY --chown=mindspore:mindspore --from=BUILDER /go/src/github.com/opensourceways/xihe-training-center/huaweicloud/trainingimpl/tools/upload_folder.sh /opt/app

USER mindspore

ENTRYPOINT ["/opt/app/xihe-training-center"]

