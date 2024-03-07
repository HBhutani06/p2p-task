FROM golang:1.16 as build
RUN apt-get update && apt-get install -y curl
ARG KUBECTL_VERSION="1.23.2"
RUN curl -LO "https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl" && \
    chmod +x ./kubectl && \
    mv ./kubectl /usr/local/bin/kubectl 
FROM alpine:latest
RUN adduser -D -g '' myuser
RUN apk --no-cache add netcat-openbsd curl aws-cli
COPY --from=build /usr/local/bin/kubectl /usr/local/bin/kubectl
COPY test.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/test.sh
USER myuser
CMD ["/usr/local/bin/test.sh"]