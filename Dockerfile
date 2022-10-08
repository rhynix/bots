FROM docker.io/library/ruby:3.1.2

EXPOSE 8080

RUN adduser --disabled-password --home=/code --gecos "" --uid=1000 app
USER app
WORKDIR /code

RUN bundle config set without test && \
    bundle config set deployment true

COPY --chown=app:app Gemfile      Gemfile
COPY --chown=app:app Gemfile.lock Gemfile.lock

RUN bundle install

COPY --chown=app:app . .

CMD ["bin/server"]
