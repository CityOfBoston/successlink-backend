FROM ruby:2.4-alpine3.6

WORKDIR /app

# Install the AWS CLI
RUN apk add --update \
  python python-dev curl unzip alpine-sdk postgresql postgresql-dev nodejs nodejs-npm tzdata \
  && cd /tmp \
  && curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip" \
  && unzip awscli-bundle.zip \
  && ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws \
  && rm awscli-bundle.zip \
  && rm -rf awscli-bundle

RUN npm install -g yarn

# By just bringing these in first, we can re-use the npm install layer when the
# package.json and npm-shrinkwrap haven't changed, speeding up recompilation.
ADD Gemfile Gemfile.lock /app/

RUN bundle install --deployment --without="development test"

ADD . /app
RUN chmod a+x entrypoint.sh

ENV RAILS_ENV=production \
    RACK_ENV=production

# RUN bin/rails assets:precompile

EXPOSE 5000

ENTRYPOINT ["./entrypoint.sh"]
CMD ["bundle", "exec", "puma", "-b", "ssl://0.0.0.0:5000?key=server.key&cert=server.crt"]