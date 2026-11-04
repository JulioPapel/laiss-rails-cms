# This migration comes from laiss_cms (originally 20251106150010)
class ConvertSelectValueForMultiple < ActiveRecord::Migration[7.1]
  def up
    say_with_time "Converting LaissCms::Ingredients::Select values to multiple" do
      update <<-SQL.squish
        UPDATE laiss_cms_ingredients
        SET value = '["' || value || '"]'
        WHERE type = 'LaissCms::Ingredients::Select' AND value NOT LIKE '["%"]';
      SQL
    end
  end
end
