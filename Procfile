release: rails db:migrate
release: rails db:seed
web: bundle exec rails db:migrate && bundle exec rails server -b 0.0.0.0 -p ${PORT:-3000}
