FROM openeuler/openeuler:23.03 as BUILDER
RUN dnf update -y && \
    dnf install -y golang && \
    go env -w GOPROXY=https://goproxy.cn,direct

MAINTAINER zengchen1024<chenzeng765@gmail.com>

# build binary
COPY . /go/src/github.com/opensourceways/xihe-training-center
WORKDIR /go/src/github.com/opensourceways/xihe-training-center
RUN cd huaweicloud && GO111MODULE=on CGO_ENABLED=0 go build -o xihe-training-center -buildmode=pie --ldflags "-s -linkmode 'external' -extldflags '-Wl,-z,now'"
RUN tar -xf ./huaweicloud/trainingimpl/tools/obsutil.tar.gz

# copy binary config and utils
FROM openeuler/openeuler:22.03
RUN dnf -y update && \
    dnf in -y shadow git bash && \
    groupadd -g 5000 mindspore && \
    useradd -u 5000 -g mindspore -s /bin/bash -m mindspore

USER mindspore
WORKDIR /opt/app

COPY --chown=mindspore:mindspore --from=BUILDER /go/src/github.com/opensourceways/xihe-training-center/huaweicloud/xihe-training-center /opt/app
COPY --chown=mindspore:mindspore --from=BUILDER /go/src/github.com/opensourceways/xihe-training-center/obsutil /opt/app
COPY --chown=mindspore:mindspore --from=BUILDER /go/src/github.com/opensourceways/xihe-training-center/huaweicloud/trainingimpl/tools/sync_files.sh /opt/app
COPY --chown=mindspore:mindspore --from=BUILDER /go/src/github.com/opensourceways/xihe-training-center/huaweicloud/trainingimpl/tools/upload_folder.sh /opt/app

ENTRYPOINT ["/opt/app/xihe-training-center"]

