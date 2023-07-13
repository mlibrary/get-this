FROM ruby:3.2 AS development

ARG UNAME=app
ARG UID=1000
ARG GID=1000

RUN curl -sL https://deb.nodesource.com/setup_18.x | bash -

RUN apt-get update -yqq && apt-get install -yqq --no-install-recommends \
  apt-transport-https \
  nodejs \
  vim-tiny

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

RUN --mount=type=secret,id=gh_package_read_token,uid=1000 \
  read_token="$(cat /run/secrets/gh_package_read_token)" \
  && BUNDLE_RUBYGEMS__PKG__GITHUB__COM=${read_token} bundle install

RUN npm ci

RUN npm run build
RUN cp js/* public/bundles/

CMD ["bundle", "exec", "rackup", "-p", "4567", "--host", "0.0.0.0"]
