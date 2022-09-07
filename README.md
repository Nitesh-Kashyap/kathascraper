# kathascraper

Web Scraping is used to extract useful data from websites. This extracted data can be used in many applications. Web Scraping is mainly useful in gathering data while there is no other means to collect data — eg API or feeds.

Creating a Web Scraping Application using Ruby on Rails is pretty easy. Here, I will explain how I created a simple Scraper application using
1.gem "mechanize"
2.gem 'will_paginate', '~> 3.3'

The application is complete, it will pull data from Freethink. For our application, we will use this url ('https://www.freethink.com/articles/'). If you check the link, you will see the page  title, image_link and news_page_link from different articles. We will try to grab all the articles which are currently available on Freethink in that page.

I am assuming you have setup ruby and rails in your machine. If not, I would request to setup your computer first for Ruby on Rails environment and come back here. A quick side note: I am using rails 7.0.3 and ruby 3.0.0, however it should work with other versions.

So, without delay, let’s start by creating a new Rails application.

# step - 1

Go to terminal and type following commands:

$> rails new kathascraper
$> cd kathascraper

Now open the Gemfile in your editor and add this at the bottom.

gem "mechanize"
gem 'will_paginate', '~> 3.3'

then run following commands in your terminal:

$> bundle install
$> rails db:create
$> rails server

This will setup mechanize gem, create database and start the rails application. At this point, if you open browser and go to http://localhost:3000, you should see the default rails running page.

# step - 2

Now let’s create a scaffold to add interface and store scraped data in to the database. In your terminal, type following commands:

$> rails g scaffold article title image_link news_feed_link
$> rails db:migrate

This generates necessary model, controller and view files to display and process vehicles data.

Above code also adds articles resource routes to config/routes.rb file. We will update the file to include two more route entries. First — A post request to scrape url action. Second — a default route to application index page.

# step - 3

The config/routes.rb file should look like this:

Rails.application.routes.draw do
  resources :articles do
    match '/scrape', to: 'articles#scrape', via: :post, on: :collection
  end

  root to: 'articles#index'
end

This adds a new routes helper — scrape_articles_path which we can use to add a Scrape link in next step

# step - 4

Now let’s add a button in the index page to start scraping. Open app/views/articles/index.html.erb and add following code at the top of the page:

<%= button_to 'Scrape', scrape_articles_path %>

Now refreshing the browser should display vehicles index page:

Clicking the Scrape button should redirect to scrape action of articles controller. However we haven’t created the controller action. So let’s add that code now.

# step - 5

Open app/controllers/articles_controller.rb file to add scrape action as shown below:

def scrape
    url = 'https://www.freethink.com/articles/'
    response = ScraperService.process(url)
    respond_to do |format|
      format.html { redirect_to articles_url, notice: "Articles scraping Done." }
      format.json { head :no_content }
    end
  rescue StandardError => e
    flash.now[:alert] = "Error: #{e}"
  end
  
  At the same time, let’s also add a view file for scrape action. Create a new file as app/views/articles/scrape.html.erb and add the following code.

<p style="color: green"><%= notice %></p>
  <p style="color: red"><%= alert %></p>
  <%= link_to "Back", root_path %>
  
  Now let’s add ScraperService code that does the magic of scraping, by creating a new file as app/services/scraper_service.rb

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
                                         

# step - 6
                                         
If you go to our scrape url, you will see how the data is structured inside html tags.
Looking at the screen above, we can see that each article information is wrapped inside tags. So, using our mechanize xpath data attributes, we will loop through this tag to grab each article.

Then inside each vehicle block, we will go through each tag to find required information. For eg. Price of the vehicle is structured inside a tag. To grab this information, again we will use mechanize css data attributes
That’s it. The basic scraping application is done!

Let’s test the application.

Clicking the scrape button scraper_service.rb file which actually uses ‘mechanize’ fake http browser and starts scraping data. It grabs all vehicles (based on mechanize data attribute) available in the page and loops through each vehicle record.

For each vehicle, it grabs title, price, stock_type, miles, color information, transmission and drivetrain. Then it inserts the record to vehicles table if the record is not already in that table.
Once the scraping is done, you will see green color successful message and can check into your terminal.
also you can check it into json formet data.

Thank You.
Happy Coding.


