# 1st ruby setup
$ gem install bundler

# --- gem install local ---
# old command: $ bundle install --path vendor/bundle
$ bundle config set path 'vendor/bundle'
$ bundle install

# --- gem install global ---
$ bundle install

# 実行
$ bundle exec ruby wmain.rb


