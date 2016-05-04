require 'mechanize'
require 'ruby-progressbar'
require 'apartmenthunter/cli'
require 'apartmenthunter/area'
require 'pry'

module Apartmenthunter
  class Scraper
      attr_accessor :area, :min_price, :max_price, :bedrooms, :bathrooms, :miles, :zip, :results, :page, :result_page, :scraper, :set_address, :scrape, :form_mechanize, :get_results



      def initialize(min_price, max_price, bedrooms, bathrooms, zip, miles)
        @area = Area.set_area
        @min_price = min_price
        @max_price = max_price
        @bedrooms = bedrooms
        @bathrooms = bathrooms
        @zip = zip
        @miles = miles
        @results = []
      end

      def run
        # Instantiate a new web scraper with Mechanize
        @scraper = Mechanize.new

        # Mechanize setup to rate limit your scraping
        # to prevent IP ban.
        @scraper.history_added = Proc.new { sleep 0.5 }
        set_address
        scrape
        form_mechanize
        get_results
        return @results
      end

      def self.set_address
        # Set the address for the area to be searched set by area method in CLI
        #@area = "/jsy"
        area = @area
        @address = "http://newyork.craigslist.org/search"+"#{area}"+"/aap"
      end

      def self.scrape
        #Let us scrape.
        @page = @scraper.get(@address)
      end

      def self.form_mechanize
        # Use Mechanize to enter search terms into the form fields desired. (Second form on page)
        form = @page.forms[1]

          form['min_price'] = @min_price
          form['max_price'] = @max_price
          form['bedrooms'] = @bedrooms
          form['bathrooms'] = @bathrooms
          form['search_distance'] = @miles
          form['postal'] = @zip

        @result_page = form.submit
      end

      def self.get_results
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

        progress = ProgressBar.create(:title => "Downloading", :total => 20, :length => 40)
        20.times do
          sleep 0.1
          progress.increment
        end
        puts @results
        binding.pry
      end
    end
  end
