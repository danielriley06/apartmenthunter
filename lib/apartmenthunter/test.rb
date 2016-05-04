require 'highline/import'

def test
  @allArchiveDirs = ["deletemetest", "old2", "old3", "old4", "TestData", "testy123", "tsty"]
  choose do |menu|
    menu.prompt = 'Please choose a project to access:'
     menu.choices(*@allArchiveDirs) do |chosen|
      puts "Item chosen: #{chosen}"
    end
  end
end

test
