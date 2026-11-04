# frozen_string_literal: true

require "laiss_cms/tasks/reorient_pictures"

namespace :laiss_cms do
  namespace :pictures do
    # Limit any of the tasks below to a subset of pictures:
    #   rake laiss_cms:pictures:report PICTURE_IDS=1,2,3
    def laiss_cms_picture_ids
      ENV["PICTURE_IDS"]&.split(",")&.map(&:strip).presence
    end

    desc "Reports picture masters that still carry a non upright EXIF orientation (Dragonfly only)."
    task report: [:environment] do
      LaissCms::ReorientPictures.report(picture_ids: laiss_cms_picture_ids)
    end

    desc "Bakes the EXIF orientation into existing picture masters (Dragonfly only)."
    task reorient: [:environment] do
      LaissCms::ReorientPictures.call(picture_ids: laiss_cms_picture_ids)
    end
  end
end
