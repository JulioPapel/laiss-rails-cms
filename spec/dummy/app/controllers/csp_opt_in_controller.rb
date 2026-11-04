# frozen_string_literal: true

# Stands in for an engine that opts into LaissCms's admin policy without
# inheriting from LaissCms::Admin::BaseController, the way laiss-cms-devise does.
class CspOptInController < ApplicationController
  include LaissCms::Admin::CspProtection

  def index
    render plain: "ok"
  end
end
