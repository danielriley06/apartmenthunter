require 'csv'
require 'apartmenthunter/cli'

module Apartmenthunter
  class Export
    def self.output(results)
      hashes = results
      column_names = hashes.first.keys
      s = CSV.generate do |csv|
        csv << column_names
        hashes.each do |x|
          csv << x.values
        end
      end
      File.write('aptsearchresults.csv', s)
    end
  end
end
