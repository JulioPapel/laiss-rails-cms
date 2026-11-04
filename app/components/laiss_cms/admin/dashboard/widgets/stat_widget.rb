module LaissCms
  module Admin
    module Dashboard
      module Widgets
        class StatWidget < ViewComponent::Base
          delegate :laiss_cms, to: :helpers

          private

          def title = raise(NotImplementedError)
          def count = raise(NotImplementedError)
          def icon = nil
          def link = nil
          def infos = nil
        end
      end
    end
  end
end
