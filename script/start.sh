#!/bin/bash
yarn install
RAILS_ENV=production bundle exec bin/delayed_job start
rails server -e production
