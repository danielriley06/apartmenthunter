require 'apartmenthunter/scraper'
require 'apartmenthunter/area'
require 'apartmenthunter/export'
require 'apartmenthunter'
require 'formatador'
require 'highline/import'
require 'colorize'
require 'pry'

module Apartmenthunter
  class Apartmenthunter::CLI
    attr_accessor :area, :min_price, :max_price, :bedrooms, :bathrooms, :zip, :miles, :results



    def welcome
      puts %q[
      _                  _                 _     _  _          _
     /_\  _ __  __ _ _ _| |_ _ __  ___ _ _| |_  | || |_  _ _ _| |_ ___ _ _
    / _ \| '_ \/ _` | '_|  _| '  \/ -_) ' \  _| | __ | || | ' \  _/ -_) '_|
   /_/ \_\ .__/\__,_|_|  \__|_|_|_\___|_||_\__| |_||_|\_,_|_||_\__\___|_|
         |_|                                                               ].green.bold
      puts "\nThis handy gem will help you find apartments availible for rent on Craigslist in the Greater New York area.\n".green.bold
    end

    def locate
      @locations = ["All of the Greater New York area", "New Jersey", "Bronx", "Brooklyn", "Fairfield", "Long Island", "Manhattan", "Queens", "Staten Island", "Westchester", "Exit"]
      choose do |menu|
        menu.layout = :list
        menu.prompt = "\nPlease enter your the specific area you would like to search : ".green
        menu.choices(*@locations) {|command| command == "Exit" ? goodbye : @area = Area.set_area(command)}
        end
    end

    def parameters
      say("\nPlease begin by answering a few questions to narrow down your search.".red)
      @min_price = ask("What is the minimum amount of rent you would like to pay? ", lambda { |p| p.sub(/[^0-9A-Za-z]/, '')})
      @max_price = ask("What is the maximum amount of rent you would like to pay? ", lambda { |p| p.sub(/[^0-9A-Za-z]/, '')})
      @bedrooms = ask("Please enter the number of bedrooms : ", Integer)
      @bathrooms = ask("Please enter the number of bathrooms : ", Integer)
      @zip = ask("Please enter the zip code you would like to center your search around : ", String) do |q|
        q.validate = /\A\d{5}(?:-?\d{4})?\Z/
        q.responses[:not_valid] = "Please enter a 5 digit zip code."
      end
      @miles = ask("Finally, please enter the number of miles you would like to search from that zip code : ", Integer) { |q| q.in = 0..500 }

    end

    def results
      @apt_results = Scraper.scrape_craig(@area, @min_price, @max_price, @bedrooms, @bathrooms, @zip, @miles)
    end

    def display_results
      Formatador.display_compact_table(@apt_results)
    end

    def post_search_options
      say("\nPlease select wether you would like to export these results, restart your search, or quit : \n".green)
      loop do
        choose do |menu|
          menu.layout = :list
          menu.choice("Export Results") do |command|
            csv_export
          end
          menu.choice("Restart Search") do |command|
            area
          end
          menu.choice("Exit") do |command|
            goodbye
          end
        end
      end
    end

    def csv_export
      Export.output(@apt_results)
      say("\nYour results are located in the file aptsearchresults.csv your Documents folder")
      post_search_options
    end

    def goodbye
      puts "Happy apartment hunting!"
      exit
    end


  end
end
