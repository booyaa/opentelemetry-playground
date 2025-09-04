FROM ruby:3.3.4
ADD . /code
WORKDIR /code
RUN gem install bundler
RUN bundle install

EXPOSE 4567
