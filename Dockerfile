FROM ruby:2.4-alpine

ARG BUNDLER_ARGS="--jobs 3 --retry 3"

RUN adduser -h /foodcritic -g foodcritic -D foodcritic

COPY . /foodcritic

WORKDIR /foodcritic

RUN set -ex && \
  # install dependencies
  apk add --no-cache --virtual alpine-sdk && \
  bundle install --system $BUNDLER_ARGS && \
  bundle exec rake

RUN chown -R foodcritic:foodcritic /foodcritic

USER foodcritic

ENTRYPOINT ["/foodcritic/bin/foodcritic"]
CMD ["/foodcritic/bin/foodcritic","--help"]
