# frozen_string_literal: true

Rails.application.config.to_prepare do
  LaissCms.config.abilities.add("LaissCms::Devise::Ability")

  LaissCms::Modules.register_module({
    name: "users",
    engine_name: "laiss_cms",
    position: 4.1,
    navigation: {
      name: "modules.users",
      controller: "/laiss_cms/admin/users",
      action: "index",
      icon: "group"
    }
  })

  LaissCms.config.signup_path = "/admin/signup"
  LaissCms.config.login_path = "/admin/login"
  LaissCms.config.logout_path = "/admin/logout"
  LaissCms.config.logout_method = Devise.sign_out_via.to_s
  LaissCms.config.edit_user_path = "/admin/users/:id/edit"
  LaissCms.config.admin_users_path = "/admin/users"
end
