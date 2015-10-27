FROM codeclimate/alpine-ruby:b38

RUN apk --update add ruby ruby-dev libffi-dev ruby-bundler ruby-nokogiri build-base

WORKDIR /usr/src/app

COPY Gemfile* /usr/src/app/

RUN bundle install -j 4

RUN adduser -u 9000 -D app
COPY doc/rules.yml /rules.yml

COPY . /usr/src/app

RUN gem build foodcritic.gemspec && gem install foodcritic-5.0.0.gem

RUN apk del build-base && rm -fr /usr/share/ri

RUN chown -R app:app /usr/src/app

WORKDIR /code
USER app

CMD ["/usr/src/app/bin/codeclimate-foodcritic"]
