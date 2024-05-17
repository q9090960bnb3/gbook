FROM ubuntu:20.04 as builder-env

RUN apt-get update && apt-get install -y xz-utils

WORKDIR /download
ADD https://go.dev/dl/go1.20.linux-amd64.tar.gz .
RUN ls -l
RUN tar -C /usr/local -xzf go1.20.linux-amd64.tar.gz
ENV PATH $PATH:/usr/local/go/bin
ENV GOPROXY=https://goproxy.cn,direct

ADD . /work
WORKDIR /work

RUN go build -ldflags="-w -s" -o gbook

WORKDIR /download
ADD https://nodejs.org/dist/v10.0.0/node-v10.0.0-linux-x64.tar.xz .
RUN tar -xf node-v10.0.0-linux-x64.tar.xz

FROM ubuntu:20.04 as runner

WORKDIR /env
COPY --from=builder-env /download/node-v10.0.0-linux-x64 ./node-v10.0.0-linux-x64

ENV PATH $PATH:/env/node-v10.0.0-linux-x64/bin
RUN npm config set registry https://registry.npmmirror.com/

WORKDIR /app
COPY --from=builder-env /work/gbook .

EXPOSE 4000

CMD [ "/app/gbook" "serve"]

