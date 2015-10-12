require 'nokogiri'
require 'open-uri'
require 'csv'

# Store URL to be scraped
url = 'https://www.airbnb.com/s/Brooklyn--NY--United-States'

# Parse the page with Nokogiri
page = Nokogiri::HTML(open(url))

# Store date in arrays
name = []
page.css('h3.h5.listing-name a').each do |line|
  name << line.text.strip
end

price = []
page.css('span.h3.price-amount').each do |line|
  price << line.text
end

details = []
page.css('div.text-muted.listing-location.text-truncate').each do |line|
  details << line.text.strip.split(/ · /)
end

# Write data to CSV file
CSV.open('airbnb_listings.csv', 'w') do |file|
  file << ['Listing Name', 'Price', 'Room Type', 'Reviews', 'Location']

  name.length.times do |i|
    file << [name[i], price[i], details[i][0], details[i][1], details[i][2]]
  end
end