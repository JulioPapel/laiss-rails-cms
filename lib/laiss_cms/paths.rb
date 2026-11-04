# frozen_string_literal: true

# Provides admin interface routing configuration accessors.
#
# LaissCms has some defaults for admin path and admin constraints:
#
# +LaissCms.admin_path defaults to +'admin'+
# +LaissCms.admin_constraints defaults to +{}+
#
# Anyway, you can tell LaissCms about your routing configuration:
#
#   1. The path to the admin panel - @see: LaissCms.admin_path
#   2. The constraints for the admin panel (like subdomain) - @see: LaissCms.admin_constraints
#
# A word of caution: you need to know what you are doing if you set admin_path to ''. This can cause
# routing name clashes, e.g. a page named 'dashboard' will clash with the LaissCms dashboard.
#
# == Example
#
# If you do not wish to use the default admin interface routing ('example.com/admin')
# and prefer e.g. 'hidden.example.com/backend', those are the settings you need:
#
#     # config/initializers/laiss_cms.rb
#     LaissCms.admin_path = 'backend'
#     LaissCms.admin_constraints = {subdomain: 'hidden'}
#
module LaissCms
  mattr_accessor :admin_path, :admin_constraints

  # Defaults
  #
  @@admin_path = "admin"
  @@admin_constraints = {}
end
