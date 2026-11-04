module LaissCms
  module Admin
    module Dashboard
      module Widgets
        class PictureCounts < StatWidget
          private

          def title = LaissCms::Picture.model_name.human(count: :many)
          def link = laiss_cms.admin_pictures_path
          def icon = "multi-image"
          def count = LaissCms::Picture.count
          def infos = number_to_human_size(LaissCms::Picture.sum(&:image_file_size))
        end
      end
    end
  end
end
