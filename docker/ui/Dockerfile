#
# conductor:server - Build Conductor UI
#
# ===========================================================================================================
# 1. Builder stage 
# ===========================================================================================================
FROM alpine:3.20 AS ui-builder
ARG YARN_OPTS

LABEL maintainer="Orkes OSS <oss@orkes.io>"

# Install dependencies
RUN apk add --update nodejs npm yarn

COPY . /conductor
WORKDIR /conductor/ui

# Include monaco sources into bundle (instead of using CDN)
ENV REACT_APP_MONACO_EDITOR_USING_CDN=false
ENV REACT_APP_ENABLE_ERRORS_INSPECTOR=true
RUN yarn ${YARN_OPTS} install && cp -r node_modules/monaco-editor public/ && yarn ${YARN_OPTS} build
RUN ls -ltr
RUN echo "Done building UI"


# ===========================================================================================================
# 2. Bin stage
# ===========================================================================================================
FROM nginx:1.29.8-alpine

LABEL maintainer="Orkes OSS <oss@orkes.io>"

# Copy compiled UI assets to nginx www directory
WORKDIR /usr/share/nginx/html
RUN rm -rf ./*
COPY --from=ui-builder /conductor/ui/build .
COPY --from=ui-builder /conductor/docker/server/nginx/default.conf.template /etc/nginx/templates/default.conf.template

CMD [ "nginx", "-g", "daemon off;" ]
