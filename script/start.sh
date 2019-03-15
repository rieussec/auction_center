#!/bin/bash
yarn install
bundle install
if [ ${RAILS_ENV} = "production" ]
then
    bundle exec bin/delayed_job start
    bundle exec rails assets:precompile
fi
rails server