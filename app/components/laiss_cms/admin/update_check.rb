module LaissCms
  module Admin
    class UpdateCheck < ViewComponent::Base
      erb_template <<-ERB
        <laiss-cms-update-check url="<%= laiss_cms.update_check_path %>">
          <span class="update_available hidden">
            <%= render_icon(:exclamation) %>
            <%= LaissCms.t('Update available') %>
          </span>
          <span class="up_to_date hidden">
            <%= render_icon(:check) %>
            <%= LaissCms.t('LaissCms is up to date') %>
          </span>
          <span class="error hidden">
            <%= render_icon(:exclamation) %>
            <%= LaissCms.t('Update status unavailable') %>
          </span>
        </laiss-cms-update-check>
      ERB

      delegate :laiss_cms, :can?, :render_icon, to: :helpers

      def render?
        !Rails.env.local? && can?(:update_check, :laiss_cms_admin_dashboard) &&
          LaissCms.config.update_check_service != :none
      end
    end
  end
end
