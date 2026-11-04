class ConvertSelectValueForMultiple < ActiveRecord::Migration[7.1]
  def up
    say_with_time "Converting LaissCms::Ingredients::Select values to multiple" do
      LaissCms::Ingredients::Select
        .where.not("value LIKE ?", '["%')
        .update_all(
          Arel.sql(
            case ActiveRecord::Base.connection.adapter_name
            when /mysql|mariadb/i
              "value = CONCAT('[\"', value, '\"]')"
            else
              "value = '[\"' || value || '\"]'"
            end
          )
        )
    end
  end
end
