require 'rubygems'
require 'mechanize'

agent = Mechanize.new

page = agent.get("http://www.kclsu.org/joiningagroup/")

File.open("csv/kcl_assoce.csv", "w+") do |f|
  nodes = page.search('.msl-listingitem-link')
  nodes.each do |node|
    assoce_page = agent.click(node)
    email = assoce_page.search(".msl_email").inner_text
    unless email.length == 0
      f.write("#{assoce_page.search("#organisation h3").inner_text.strip}, #{email}\n")
    end
  end
end
