FROM ruby:3.4.4-slim

RUN apt-get update && apt-get install -y \
    imagemagick \
    git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

ENTRYPOINT ["./scripts/docker-entrypoint"]
CMD ["./scripts/weather"]
