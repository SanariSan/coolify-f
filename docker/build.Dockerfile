FROM node:20 AS modules
WORKDIR /home/node/proj
COPY --chown=root:root package.json yarn.lock ./
RUN ["yarn", "install", "--pure-lockfile", "--frozen-lockfile", "--network-timeout" , "100000"]

FROM node:20 AS build
ARG REACT_APP_API_URL
ENV REACT_APP_API_URL=${REACT_APP_API_URL}
ARG REACT_APP_API_VERSION
ENV REACT_APP_API_VERSION=${REACT_APP_API_VERSION}
WORKDIR /home/node/proj
COPY --chown=root:root src/ ./src
COPY --chown=root:root public/ ./public
COPY --chown=root:root --from=modules /home/node/proj/package.json /home/node/proj/yarn.lock ./
COPY --chown=root:root --from=modules /home/node/proj/node_modules ./node_modules
COPY --chown=root:root dumb-init_1.2.5_x86_64 /usr/local/bin/dumb-init
RUN chmod +x /usr/local/bin/dumb-init
CMD sh -c ' \
  dumb-init node ./node_modules/cross-env/src/bin/cross-env.js REACT_APP_NODE_ENV=production && \
  node ./node_modules/react-scripts/bin/react-scripts.js build && \
  tail -f /dev/null \
'