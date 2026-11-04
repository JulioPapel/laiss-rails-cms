class CreateLaissCmsPictureDescriptions < ActiveRecord::Migration[7.2]
  def change
    create_table :laiss_cms_picture_descriptions do |t|
      t.belongs_to :picture, null: false, foreign_key: {to_table: :laiss_cms_pictures}
      t.belongs_to :language, null: false, foreign_key: {to_table: :laiss_cms_languages}
      t.text :text

      t.timestamps
    end
  end
end
