require "HTTParty"
require "Nokogiri"
require "JSON"
require "Pry"
require "csv"
require "uri"

class Hero
	attr_reader :name
	attr_reader :link
	attr_reader :r_class
	def initialize(namestr, r_class)
		@name = namestr
		@r_class = r_class
	end
end

# Function works. Don't touch this unless wiki changes format.
def determine_r_class(r_class_element)
	r_link = r_class_element.at_css("a")
	r_text = r_class_element.xpath("text()").to_a.join
	r_link_text = ""
	if r_link.nil?
		# No link, simple summon unit.
		if r_text == "3-4"
			return :r_34
		elsif r_text == "4-5"
			return :r_45
		elsif r_text == "5"
			return :r_5
		else
			raise ArgumentError, "Unclear what rarity class is meant by " + r_text
		end
	else
		r_link_text = r_link.xpath("text()").to_a.join
		if r_link_text.start_with? "Story"
			if r_text.start_with? "2"
				return :r_unique
			elsif r_text.start_with? "N/A"
				return :r_unobtainable
			end
		elsif r_link_text.start_with? "Grand Hero Battle"
			return :r_ghb
		elsif r_link_text.start_with? "Tempest Trial"
			return :r_tt
		elsif r_link_text.start_with? "Legendary"
			return :r_legendary
		elsif r_link_text.start_with? "Special"
			return :r_special
		end
	end
end

page = HTTParty.get('https://feheroes.gamepedia.com/Hero_List')

parse_page = Nokogiri::HTML(page)

# css search using css selectors.
# #at_css returns first occurrence of thing.
# #css returns list of all matches.
table = parse_page.at_css(".cargoTable.sortable")
heros = table.css("tr")

# shift removes first row, which is just header info.
heros.shift

heros.each do |table_row|
	name_element = table_row.at_css(".field_Name")
	name_link = name_element.at_css("a")
	name_link_text = "https://feheroes.gamepedia.com" + name_link.xpath("@href").to_s
	name_text = URI.unescape(name_link.xpath("text()").to_s)

	r_class_element = table_row.at_css(".field_Rarity")
	puts name_text + " " + determine_r_class(r_class_element).to_s

	# r_class_element_link = r_class_element.at_css("a")
	# if r_class_element_link
	# 	puts r_class_element_link.xpath("text()").to_a.join("")
	# end
	# puts r_class_element.xpath("text()").to_a.join("")
	# r_class = determine_r_class(r_class_element)
end

# puts heros[0]

# puts table.inspect -> prints the table containing all the heros.
