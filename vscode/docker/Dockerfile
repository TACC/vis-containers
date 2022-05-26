FROM node:14-bullseye

RUN apt-get update \
  && apt-get upgrade -y \
  && apt-get install -y \
     tini \
     vim.tiny \
     python3-pip

RUN pip3 install jupyter jupyterlab

RUN npm config set python python3

RUN yarn global add code-server

COPY entrypoint.sh /usr/bin/entrypoint.sh

EXPOSE 50080

USER node

ENTRYPOINT ["/usr/bin/entrypoint.sh", "--bind-addr", "0.0.0.0:50080", "."]
