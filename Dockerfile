FROM ruby:3.3 AS development

ARG UNAME=app
ARG UID=1000
ARG GID=1000
ARG NODE_MAJOR=20


RUN apt-get update -yqq && apt-get install -yqq --no-install-recommends \
  ca-certificates \
  gnupg \
  apt-transport-https \
  nodejs \
  vim-tiny

RUN mkdir -p /etc/apt/keyrings
RUN curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
RUN echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_${NODE_MAJOR}.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list
RUN apt-get update -yqq && apt-get install -yqq --no-install-recommends nodejs

RUN gem install bundler
RUN npm install -g npm

RUN groupadd -g ${GID} -o ${UNAME}
RUN useradd -m -d /app -u ${UID} -g ${GID} -o -s /bin/bash ${UNAME}
RUN mkdir -p /gems && chown ${UID}:${GID} /gems

USER $UNAME

ENV BUNDLE_PATH /gems

WORKDIR /app

FROM development AS production

COPY --chown=${UID}:${GID} . /app
ENV BUNDLE_WITHOUT development:test

RUN --mount=type=secret,id=github_token,uid=1000 \
  github_token="$(cat /run/secrets/github_token)" \
  && BUNDLE_RUBYGEMS__PKG__GITHUB__COM=${github_token} bundle install

RUN npm ci

RUN npm run build
RUN cp js/* public/bundles/

CMD ["bundle", "exec", "rackup", "-p", "4567", "--host", "0.0.0.0"]
