#!/usr/bin/bash
# use buildah to create a container holding fio

IMAGE="alpine:latest"

container=$(buildah from $IMAGE)
#mountpoint=$(buildah mount $container)
buildah run $container apk add fio
buildah run $container apk add bash
buildah run $container apk add sysstat
buildah run $container apk add iperf
buildah run $container apk add rsync
buildah run $container apk add python3
buildah run $container pip3 install --upgrade pip
buildah run $container pip3 install jaraco.collections
buildah run $container pip3 install zc.lockfile
buildah run $container pip3 install cheroot
buildah run $container pip3 install portend
# buildah run $container apk add py3-more-itertools
# buildah run $container apk add py3-wheel --repository http://dl-cdn.alpinelinux.org/alpine/edge/main/
buildah run $container apk add py3-cherrypy --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing/

buildah run $container mkdir -p /var/lib/fioloadgen/jobs
buildah run $container mkdir -p /var/log/fioloadgen

buildah copy $container ../data/fio/jobs/ /var/lib/fioloadgen/jobs
buildah copy $container ../fioservice.py /fioservice.py
buildah copy $container ../fiotools /fiotools
buildah copy $container ../www /www

# expose port
# buildah config --port 8080 $container

# set working dir
#buildah config --workingdir /usr/share/grafana $container



# entrypoint
buildah config --entrypoint "./fioservice.py --mode=prod start --debug-only" $container

# finalize
buildah config --label maintainer="Paul Cuzner <pcuzner@redhat.com>" $container
buildah config --label description="fioservice API/UI" $container
buildah config --label summary="fioservice" $container
buildah commit --format docker --squash $container fioservice:latest
