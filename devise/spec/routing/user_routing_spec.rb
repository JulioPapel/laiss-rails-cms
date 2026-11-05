require_relative "../rails_helper"

describe "User Routing" do
  routes { LaissCms::Engine.routes }

  it "routes to signup" do
    expect({
      get: "/admin/signup"
    }).to route_to(
      controller: "laiss_cms/admin/users",
      action: "signup"
    )
  end
end
