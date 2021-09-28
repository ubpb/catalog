source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby IO.read(".ruby-version").strip

gem "addressable",    "~> 2.7"
gem "bcrypt",         "~> 3.1"
gem "bootsnap",       ">= 1.4.2", require: false
gem "cancancan",      "~> 3.2"
gem "dry-struct",     "~> 1.4"
gem "elasticsearch",  "~> 7.12"
gem "jbuilder",       "~> 2.7"
gem "mysql2",         ">= 0.5.3"
gem "parallel",       "~> 1.19"
gem "puma",           ">= 5.2"
gem "rails",          "~> 6.1.0"
gem "rails-i18n",     "~> 6.0"
gem "sass-rails",     ">= 6"
gem "simple_form",    "~> 5.1"
gem "slim",           "~> 4.0"
gem "turbo-rails",    "~> 0.5"
gem "view_component", "~> 2.31", require: "view_component/engine"
gem "webpacker",      "~> 6.0.0.rc.5"

gem "exl_api",  "~> 1.0.0", path: "vendor/gems/exl_api"

group :development, :test do
  gem "pry",       ">= 0.14.1", platform: :mri
  gem "pry-rails", ">= 0.3",    platform: :mri

  # Don't use byebug until https://github.com/deivid-rodriguez/byebug/issues/564
  # is fixed. We use a directory structure in app/integrations that uses
  # "explicit namespaces". When running byebug, Zeitwerk autoloading breaks.
  #gem "pry-byebug", ">= 3.9", platform: :mri
end

group :development do
  gem "capistrano",            "~> 3.11"
  gem "capistrano-bundler",    "~> 2.0"
  gem "capistrano-passenger",  "~> 0.2"
  gem "capistrano-rails",      "~> 1.6"
  gem "capistrano-rvm",        "~> 0.1"
  gem "listen",                "~> 3.2"
  gem "spring",                "~> 2.1"
  gem "spring-watcher-listen", "~> 2.0"
  gem "web-console",           ">= 3.3"
end

group :test do
  gem "capybara",           ">= 2.15"
  gem "selenium-webdriver", ">= 3.1"
  gem "webdrivers",         ">= 4.3"
end
