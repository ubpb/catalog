source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby IO.read(".ruby-version").strip

gem "bcrypt",      "~> 3.1.7"
gem "bootsnap",    ">= 1.4.2", require: false
gem "cancancan",   "~> 3.2.0"
gem "dry-struct",  "~> 1.4.0"
gem "jbuilder",    "~> 2.7"
gem "kaminari",    "~> 1.2.0"
gem "mysql2",      ">= 0.5.3"
gem "parallel",    "~> 1.19"
gem "puma",        ">= 5.2"
gem "rails",       "~> 6.1.0"
gem "rails-i18n",  "~> 6.0.0"
gem "sass-rails",  ">= 6"
gem "simple_form", "~> 5.0.2"
gem "slim",        "~> 4.0"
gem "turbolinks",  "~> 5"
gem "webpacker",   "~> 5.0"

gem "alma_api", "~> 1.0.0", path: "vendor/gems/alma_api"

group :development, :test do
  gem "pry-byebug", ">= 3.9", platform: :mri
  gem "pry-rails",  ">= 0.3", platform: :mri
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
