class CreatePageMutexes < ActiveRecord::Migration[7.2]
  def change
    create_table :laiss_cms_page_mutexes do |t|
      t.references :page, null: false, index: {unique: true}, foreign_key: {to_table: :laiss_cms_pages}
      t.datetime :created_at
    end
  end
end
