# frozen_string_literal: true

class ScraperService < ApplicationService
  def self.process(url)
    pages_count = 1
    loop do
      agent = Mechanize.new
      page = agent.get(url + "?paging=#{pages_count}")
      articles = page.xpath("//div[@class='flex flex-row loop-item']")
      break if articles.blank?
      if articles.present?
        articles.each do |article|
          item = {}

          item[:title] = article.css('div.flex-grow').text.squish rescue ""
          item[:image_link] = article.css('a.loop-item__thumbnail-link img')[0]['src'] rescue ""
          item[:news_page_link] = article.css('div.loop-item__content a')[0]['href'] rescue ""

          Article.where(item).first_or_create
          pages_count = pages_count + 1
        end
      end
    end
  end
end
