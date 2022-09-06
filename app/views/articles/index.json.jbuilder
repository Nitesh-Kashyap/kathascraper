json.array! @articles, partial: "articles/article" do |article|
  json.title article.title
  json.image_link article.image_link
  json.news_page_link article.news_page_link
end