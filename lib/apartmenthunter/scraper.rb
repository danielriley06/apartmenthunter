require 'mechanize'
require 'ruby-progressbar'
require 'apartmenthunter/cli'
require 'apartmenthunter/area'


module Apartmenthunter
  class Scraper
    attr_accessor :results
    attr_reader :area, :min_price, :max_price, :bedrooms, :bathrooms, :zip, :miles

    @@all = []

    def initialize(min_price, max_price, bedrooms, bathrooms, zip, miles)
      @area = Area.set_area
      @min_price = min_price
      @max_price = max_price
      @bedrooms = bedrooms
      @bathrooms = bathrooms
      @zip = zip
      @miles = miles
      @results = []
      @@all << self
      self.mechanize
    end

    def mechanize
      # Instantiate a new web scraper with Mechanize
      @scraper = Mechanize.new

      # Mechanize setup to rate limit your scraping
      # to prevent IP ban.
      @scraper.history_added = Proc.new { sleep 0.5 }
      self.set_address
    end

    def set_address
      # Set the address for the area to be searched set by area method in CLI
      #@area = "/jsy"
      area = @area
      @address = "http://newyork.craigslist.org/search"+"#{area}"+"/aap"
      self.scrape_craig
    end

    def scrape_craig
      #Let us scrape.
      @page = @scraper.get(@address)

      # Use Mechanize to enter search terms into the form fields desired. (Second form on page)
      form = @page.forms[1]

        form['min_price'] = @min_price
        form['max_price'] = @max_price
        form['bedrooms'] = @bedrooms
        form['bathrooms'] = @bathrooms
        form['search_distance'] = @miles
        form['postal'] = @zip

      @result_page = form.submit
      self.parse_results
    end

    def parse_results
      raw_results = @result_page.search('p.row')

      raw_results.each do |result|
        apt_hash = {:location => "", :name => "", :price => "", :url => ""}
        link = result.css('a')[1]
        apt_hash[:name] = link.text.strip
        apt_hash[:url] = "http://newyork.craigslist.org" + link.attributes["href"].value
        apt_hash[:price] = result.search('span.price').text
        apt_hash[:location] = result.search('span.pnr').text[3..-13]



        # Save results
        @results << apt_hash
      end
      self.progress
    end

    def progress
      progress = ProgressBar.create(:title => "Downloading", :total => 20, :length => 40)
      20.times do
        sleep 0.1
        progress.increment
      end

      return @results
    end
  end
end
