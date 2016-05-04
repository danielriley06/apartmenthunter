require 'apartmenthunter/cli'
require 'apartmenthunter/scraper'

module Apartmenthunter
  class Run
    attr_reader :cli

    def initialize
      @cli = CLI.new
    end

    def call
      cli.welcome
      cli.locate
      cli.parameters
      cli.results
      cli.display_results
      cli.post_search_options
      cli.goodbye
    end
  end
end
