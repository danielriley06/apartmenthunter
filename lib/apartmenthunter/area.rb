require 'apartmenthunter/cli'
require 'apartmenthunter/scraper'

module Apartmenthunter
  class Area
    attr_reader :area

    def self.set_area(area)
      areas = {"All of the Greater New York area" => "", "New Jersey" => "/jsy", "Bronx" => "/brx", "Brooklyn" => "/brk", "Fairfield" => "/fct", "Long Island" => "/lgi", "Manhattan" => "/mnh", "Queens" => "/que", "Staten Island" =>"/stn", "Westchester" => "/wch"}
      return areas[area]
    end

  end
end
