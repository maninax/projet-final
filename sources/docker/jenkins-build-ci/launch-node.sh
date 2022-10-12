set -eu

docker rmi -f ordiclic/jenkins-build-ci || true
docker build . -t ordiclic/jenkins-build-ci
docker push ordiclic/jenkins-build-ci:latest
# docker run -d -p 23456:22 -v /var/run/docker.sock:/var/run/docker.sock ordiclic/jenkins-build-ci
