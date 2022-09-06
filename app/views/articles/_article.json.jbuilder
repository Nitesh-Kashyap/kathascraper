json.extract! article, :id, :title, :image_link, :news_page_link, :created_at, :updated_at
json.url article_url(article, format: :json)
