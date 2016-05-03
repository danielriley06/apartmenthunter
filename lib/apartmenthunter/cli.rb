require 'formatador'
require 'highline/import'
require 'colorize'

class Apartmenthunter::CLI
  attr_accessor :area, :min_price, :max_price, :bedrooms, :bathrooms, :zip, :miles, :results




  def call

    welcome
    area
    parameters
    results
    goodbye
  end

  def welcome
    puts %q[
    _                  _                 _     _  _          _
   /_\  _ __  __ _ _ _| |_ _ __  ___ _ _| |_  | || |_  _ _ _| |_ ___ _ _
  / _ \| '_ \/ _` | '_|  _| '  \/ -_) ' \  _| | __ | || | ' \  _/ -_) '_|
 /_/ \_\ .__/\__,_|_|  \__|_|_|_\___|_||_\__| |_||_|\_,_|_||_\__\___|_|
       |_|                                                               ].green.bold
    puts "\nThis handy gem will help you find apartments availible for rent on Craigslist in the Greater New York area.\n".green.bold
  end

  def area
    loop do
      choose do |menu|
        menu.layout = :list
        menu.prompt = "\nPlease enter your the specific area you would like to search : ".green

        menu.choice("All of the Greater New York area") do |command|
          say("Great! You will search all areas.")
          @area = ""
          next
        end
        menu.choice("Bronx") do |command|
          say("Great! We will only search the Bronx")
          @area = "/brx"
          next
        end
        menu.choice("Brooklyn") do |command|
          say("Great! We will only search Brooklyn")
          @area = "/brk"
          next
        end
        menu.choice("Fairfield") do |command|
          say("Great! We will only search Fairfield")
          @area = "/fct"
          next
        end
        menu.choice("Long Island") do |command|
          say("Great! We will only search Long Island")
          @area = "/lgi"
          next
        end
        menu.choice("Manhattan") do |command|
          say("Great! We will only search Manhattan")
          @area = "/mnh"
          next
        end
        menu.choice("New Jersey") do |command|
          say("Great! We will only search New Jersey")
          @area = "/jsy"
          next
        end
        menu.choice("Queens") do |command|
          say("Great! We will only search Queens")
          @area = "/que"
          next
        end
        menu.choice("Staten Island") do |command|
          say("Great! We will only search Staten Island")
          @area = "/stn"
          next
        end
        menu.choice("Westchester") do |command|
          say("Great! We will only search Westche")
          @area = "/wch"
          next
        end
        menu.choice("Quit") { exit }
      end
      break
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
    #dummy data to test search results
    #search_results = [{:name => "Highling Apartments", :url => "http://www.randomshit.com", :price => "$1,500", :location => "Millburn, NJ"},{:name => "Highling Apartments", :url => "http://www.randomshit.com", :price => "$1,500", :location => "Millburn, NJ"},{:name => "Highling Apartments", :url => "http://www.randomshit.com", :price => "$1,500", :location => "Millburn, NJ"},{:name => "Highling Apartments", :url => "http://www.randomshit.com", :price => "$1,500", :location => "Millburn, NJ"}]
    @apt_results = Apartmenthunter::Scraper.scrape_craig(@area, @min_price, @max_price, @bedrooms, @bathrooms, @zip, @miles)

    Formatador.display_table(@apt_results)
    say("\nPlease select wether you would like to export these results, restart your search, or quit : \n".green)
    loop do
      choose do |menu|
        menu.layout = :list
        menu.choice("Export") do |command|
          export_search
          goodbye
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

  def goodbye
    puts "Happy apartment hunting!"
    exit
  end


end
