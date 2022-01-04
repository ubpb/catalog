source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby IO.read(".ruby-version").strip

gem "addressable",        "~> 2.7"
gem "bcrypt",             "~> 3.1"
gem "bootsnap",           ">= 1.4.2", require: false
gem "cancancan",          "~> 3.2"
gem "dry-struct",         "~> 1.4"
gem "elasticsearch",      "~> 7.12"
gem "jbuilder",           "~> 2.7"
gem "metacrunch-marcxml", "~> 3.1.0" #, github: "ubpb/metacrunch-marcxml", branch: "master"
gem "mysql2",             ">= 0.5.3"
gem "parallel",           "~> 1.19"
gem "puma",               ">= 5.2"
gem "rails",              "~> 7.0.0"
gem "simple_form",        "~> 5.1"
gem "slim",               "~> 4.0"
gem "sprockets-rails",    "~> 3.4.2"
gem "stimulus-rails",     "~> 1.0.2"
gem "view_component",     "~> 2.31"

gem "exl_api",  "~> 1.0.0", path: "vendor/gems/exl_api"

group :development, :test do
  gem "debug", platforms: %i[ mri mingw x64_mingw ]
end

group :development do
  gem "capistrano",            "~> 3.11"
  gem "capistrano-bundler",    "~> 2.0"
  gem "capistrano-passenger",  "~> 0.2"
  gem "capistrano-rails",      "~> 1.6"
  gem "capistrano-rvm",        "~> 0.1"
  gem "web-console",           ">= 3.3"
  gem "foreman",               ">= 0.87"
end

group :test do
  gem "capybara",           ">= 2.15"
  gem "selenium-webdriver", ">= 3.1"
  gem "webdrivers",         ">= 4.3"
end
