FROM ruby:3.0.2
ARG UNAME=app
ARG UID=1000
ARG GID=1000

LABEL maintainer="mrio@umich.edu"

RUN apt-get update -yqq && apt-get install -yqq --no-install-recommends \
  apt-transport-https

RUN curl -sL https://deb.nodesource.com/setup_14.x | bash -

RUN apt-get update -yqq && apt-get install -yqq --no-install-recommends \
  nodejs \
  vim-tiny

RUN gem install bundler:2.1.4


RUN groupadd -g ${GID} -o ${UNAME}
RUN useradd -m -d /app -u ${UID} -g ${GID} -o -s /bin/bash ${UNAME}
RUN mkdir -p /gems && chown ${UID}:${GID} /gems


COPY --chown=${UID}:${GID} Gemfile* /app/
USER $UNAME

ENV BUNDLE_PATH /gems

#Actually a secret
ENV ALMA_API_KEY 'YOUR_ALMA_API_KEY'
ENV WEBLOGIN_SECRET 'weblogin_secret'

#Not that much of a secret
ENV ALMA_API_HOST 'https://api-na.hosted.exlibrisgroup.com'
ENV WEBLOGIN_ID 'weblogin_id'

WORKDIR /app

CMD ["bundle", "exec", "ruby", "get-this.rb", "-o", "0.0.0.0"]