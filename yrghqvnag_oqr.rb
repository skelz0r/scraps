require 'rubygems'
require 'csv'
require 'pry'
require 'mechanize'

agent = Mechanize.new

CSV.open('csv/bde_letudiant.csv', 'wb') do |csv|
  csv << [
    "Ecole",
    "Departement",
    "Type assoce",
    "Nom assoce",
    "Adresse",
    "Telephone",
    "Site internet"
  ]

  (1..34).each do |i|
    page = agent.get("http://www.letudiant.fr/association-etudiante/type-bde-bureau-des-etudiants/region-ile-de-france/page-#{i}.html")
    nodes = page.search('table tbody tr')

    nodes.each do |node|
      begin
        # Table line
        cells = node.search('td')
        type_assoce = cells[1].inner_text.strip
        departement = cells[2].inner_text.strip
        etablissement = cells[3].inner_text.strip

        # Page
        bde_page = agent.click(node.search('a').first)
        fiche_bde = bde_page.search('#article').first

        # Name
        nom_assoce = fiche_bde.search('.coords h2.red').inner_text.strip

        # Info
        info_bde = fiche_bde.search('.info_contact').first.parent

        site  = info_bde.search('a').last[:href]

        address = ""
        tel = ""
        info_bde.inner_text.gsub(/\r/, '').gsub(/ {2,}/, '').strip.split("\n").each do |elt|
          if elt =~ /Tél/
            tel = elt
            break
          else
            address += "#{elt}\n"
          end
        end

        # Write in csv
        row = [
          etablissement,
          departement,
          type_assoce,
          nom_assoce,
          address,
          tel,
          site
        ]
        csv << row
      rescue => e
        p "FAIL for page #{i}, line #{nodes.index(node)} : #{e}"
      end
    end
  end
end
