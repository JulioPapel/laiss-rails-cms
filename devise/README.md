## Devise based authentication for LaissCMS

[![Gem Version](https://badge.fury.io/rb/laiss-cms-devise.svg)](http://badge.fury.io/rb/laiss-cms-devise)

LaissCMS has no authentication in its core. So it is possible to bring your own authentication and use it to authorize users in LaissCMS. If you don't have your own authentication, you can use this gem.

Since LaissCms CMS 9.0, `laiss-cms-devise` is developed inside the [LaissCms CMS repository](https://github.com/LaissCMS/laiss_cms/tree/main/devise)
and released together with `laiss_cms` using the same version.
Older versions are maintained in the [`laiss-cms-devise` repository](https://github.com/LaissCMS/laiss-cms-devise).

## Install

Just put the gem into your projects `Gemfile`.

```ruby
# Gemfile
gem 'laiss-cms-devise'
```

and run `bundle install`.

Then run the installer:

```bash
$ bin/rails g laiss_cms:devise:install
```

## Upgrading

After updating the gem, please run the installer again.

```bash
$ bundle update laiss-cms-devise
$ bin/rails g laiss_cms:devise:install
```

## Devise modules

Default Devise modules included in `LaissCms::User` model

- `:database_authenticatable`
- `:trackable`
- `:validatable`
- `:timeoutable`
- `:recoverable`
- `:rememberable`

If you want to add additional modules into the LaissCms user class append them to `LaissCms::Devise.config.devise_modules` in an initializer in your app.

### Register additional modules example

```ruby
# config/initializers/laiss_cms.rb
LaissCms::Devise.config.devise_modules << :registerable
```

### Using old encryption

If your app uses an old encryption that needs the +devise-encryptable+ gem you also need to load the devise module.

```ruby
# config/initializers/laiss_cms.rb
LaissCms::Devise.config.devise_modules << :encryptable
```

## Role changes

Granting or revoking the `admin` role asks the admin performing the change to
confirm their own password, both when creating a user and when editing one.
Since `admin` is the only role that can manage users, every other role and
every other user attribute can be edited with a valid session alone.

Roles that need a password are configurable:

```ruby
# config/initializers/laiss_cms.rb
LaissCms::Devise.config.privileged_user_roles << "editor"
```

Set this to `false` to grant roles with a valid session alone:

```ruby
# config/initializers/laiss_cms.rb
LaissCms::Devise.config.require_password_for_role_change = false
```

## Testing

If you want to contribute (and you should ^_^), you need to run the tests locally on your machine.

The gem shares the bundle and the dummy app of the LaissCms CMS repository, so prepare the test database from the repository root.
The dummy app only loads `laiss-cms-devise` for these specs, because the LaissCms CMS specs use a stub user instead,
so `bin/rspec` runs them from the `devise` directory, separately from the LaissCms CMS specs.

### 1. Once to prepare the test suite:

```bash
$ bundle install
$ bundle exec rake laiss_cms:test:prepare
```

### 2. Run the tests with:

```bash
$ bin/rspec devise/spec
```

Getting Help
------------

This is a private, in-house gem. It has no public issue tracker, demo site or
chat channel. Raise problems with the Laiss Labs team directly.

Resources
---------

* Sourcecode: `devise/` in the laiss-rails-cms repository
* Documentation: the `guides/` directory in the same repository

License
-------

* BSD: [LICENSE](LICENSE)
