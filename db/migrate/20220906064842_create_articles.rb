class CreateArticles < ActiveRecord::Migration[7.0]
  def change
    create_table :articles do |t|
      t.string :title
      t.string :image_link
      t.string :news_page_link

      t.timestamps
    end
  end
end
