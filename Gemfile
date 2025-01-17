source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby IO.read(".ruby-version").strip

gem "addressable", "~> 2.7"
gem "alma_api", "~> 2.0"
gem "barby", "~> 0.6"
gem "bcrypt", "~> 3.1"
gem "bibtex-ruby", "~> 6.1", require: "bibtex"
gem "bootsnap", ">= 1.4.2", require: false
gem "chunky_png", "~> 1.4"
gem "csv", "~> 3.0"
gem "dry-struct", "~> 1.4"
gem "elasticsearch", "~> 8.12"
gem "faraday", "~> 2.7", "< 3"
gem "hashids", "~> 1.0"
gem "hexapdf", "~> 1.0"
gem "inline_svg", "~> 1.9"
gem "jbuilder", "~> 2.7"
gem "kaminari-activerecord", "~> 1.2"
gem "metacrunch-marcxml", "~> 3.1.0" # , github: "ubpb/metacrunch-marcxml", branch: "master"
gem "mysql2", ">= 0.5.3"
gem "parallel", "~> 1.19"
gem "puma", ">= 5.2"
gem "rack-attack", "~> 6.6"
gem "rails", "~> 7.2.0"
gem "rails-i18n", "~> 7.0"
gem "rss", "~> 0.2"
gem "rubyzip", "~> 2.4"
gem "simple_form", "~> 5.1"
gem "slim", ">= 5.0"
gem "sprockets-rails", "~> 3.5"
gem "strip_attributes", "~> 1.13"
gem "turbo-rails", "~> 2.0"
gem "view_component", "~> 3.0"

group :production do
  gem "newrelic_rpm", ">= 8.9.0"
end

group :development, :test do
  gem "debug", platforms: [:mri, :mingw, :x64_mingw]
end

group :development do
  gem "capistrano", "~> 3.11"
  gem "capistrano-bundler", "~> 2.0"
  gem "capistrano-passenger", "~> 0.2"
  gem "capistrano-rails", "~> 1.6"
  gem "capistrano-rvm", "~> 0.1"
  gem "i18n-debug", ">= 1.2"
  gem "i18n-tasks", ">= 1.0"
  gem "letter_opener_web", ">= 2.0"
  gem "rubocop-ubpb", github: "ubpb/rubocop-ubpb"
  gem "web-console", ">= 3.3"
end

group :test do
  gem "capybara", ">= 2.15"
  gem "selenium-webdriver", ">= 4.1"
  gem "webdrivers", ">= 4.3"
end
