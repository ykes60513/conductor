#
# conductor:ui - Build Conductor UI
#
# ===========================================================================================================
# 0. Builder stage 1
# ===========================================================================================================
FROM alpine:3.20 AS ui-builder
ARG YARN_OPTS

# Install dependencies
RUN apk add --update nodejs npm yarn

COPY . /conductor
WORKDIR /conductor/ui

# Include monaco sources into bundle (instead of using CDN)
ENV REACT_APP_MONACO_EDITOR_USING_CDN=false
ENV REACT_APP_ENABLE_ERRORS_INSPECTOR=true
RUN YARN_NETWORK_TIMEOUT=600000 yarn ${YARN_OPTS} install && cp -r node_modules/monaco-editor public/ && yarn ${YARN_OPTS} build
RUN ls -ltr
RUN echo "Done building UI"

# ===========================================================================================================
# 2. Bin stage
# ===========================================================================================================
FROM alpine:3.19

RUN apk add nginx curl

# Copy compiled UI assets to nginx www directory
WORKDIR /usr/share/nginx/html
RUN rm -rf ./*
COPY --from=ui-builder /conductor/ui/build .
COPY --from=ui-builder /conductor/docker/server/nginx/nginx.conf /etc/nginx/http.d/default.conf

EXPOSE 5000

HEALTHCHECK --interval=60s --timeout=30s --retries=10 CMD curl -I -XGET http://localhost:5000 || exit 1

CMD ["nginx","-g","daemon off;"]