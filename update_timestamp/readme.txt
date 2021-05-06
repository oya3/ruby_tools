# 1st setup for bundler
$ gem install bundler

# --- gem install local ---
# old command: $ bundle install --path vendor/bundle
$ bundle config set path 'vendor/bundle'
$ bundle install

# --- gem install global ---
$ bundle install

# 実行
$ bundle exec ruby main.rb <target path>

# 例
$ bundle exec ruby main.rb "test.org"
