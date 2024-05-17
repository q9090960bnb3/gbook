FROM golang:1.20 as builder-env

RUN apt-get update && apt-get install -y xz-utils

ENV GOPROXY=https://goproxy.cn,direct

ADD . /work
WORKDIR /work
# RUN ls -l /work
RUN go build -ldflags="-w -s" -o gbook

WORKDIR /download
RUN wget https://nodejs.org/dist/v10.0.0/node-v10.0.0-linux-x64.tar.xz
RUN tar -xf node-v10.0.0-linux-x64.tar.xz

FROM debian:buster

WORKDIR /env
COPY --from=builder-env /download/node-v10.0.0-linux-x64 ./node-v10.0.0-linux-x64

ENV PATH $PATH:/env/node-v10.0.0-linux-x64/bin
RUN npm config set registry https://registry.npmmirror.com/

WORKDIR /app
COPY --from=builder-env /work/gbook .
RUN ./gbook

EXPOSE 4000

CMD [ "/app/gbook" "serve"]

