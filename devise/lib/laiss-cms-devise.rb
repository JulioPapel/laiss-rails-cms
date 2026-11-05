# Bundler entry point for laiss-cms-devise.
#
# Bundler calls `require "laiss-cms-devise"` (the gem name, with hyphens
# translated to the file it looks for). Without this file the gem still installs
# and `bundle install` reports success, but the engine is never loaded: no
# LaissCms::User model, no devise controllers, no admin sign-in. That failure was
# silent because nothing raises — the host app merely gets
# NoCurrentUserFoundError, or NameError: uninitialized constant LaissCms::User,
# on its first admin request.
#
# The path and the underscore form are both provided so either
# `require "laiss-cms-devise"` (what Bundler does) or
# `require "laiss_cms/devise"` (what the demo app did by hand) works.
require "laiss_cms/devise"
