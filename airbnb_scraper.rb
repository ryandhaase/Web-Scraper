require 'nokogiri'
require 'open-uri'
require 'csv'

# Scrape the max numbers of pages and store in max_page variable
url = 'https://www.airbnb.com/s/Brooklyn--NY--United-States?'
page = Nokogiri::HTML(open(url))

page_numbers = []
page.css('div.pagination ul li a[target]').each do |line|
  page_numbers << line.text
end

max_page = page_numbers[0...-1].map(&:to_i).max

# Initialize empty arrays
name = []
price = []
details = []

max_page.times do |i|

  # Open search results page
  url = "https://www.airbnb.com/s/Brooklyn--NY--United-States?page=#{i+1}"

  # Parse the page with Nokogiri
  page = Nokogiri::HTML(open(url))

  # Store date in arrays
  page.css('h3.h5.listing-name a').each do |line|
    name << line.text.strip
  end

  page.css('span.h3.price-amount').each do |line|
    price << line.text
  end

  page.css('div.text-muted.listing-location.text-truncate').each do |line|
    details << line.text.strip.split(/·/).map(&:strip)
  end
end

# Write data to CSV file
CSV.open('airbnb_listings.csv', 'w') do |file|
  file << ['Listing Name', 'Price', 'Room Type', 'Reviews']

  name.length.times do |i|
    if details[i].length == 1
      file << [name[i], price[i], details[i][0], "N/A"] 
    elsif details[i].length == 2
      file << [name[i], price[i], details[i][0], details[i][1]] 
    elsif details[i].length == 3
      file << [name[i], price[i], details[i][0], details[i][1], details[i][2]]
    end
  end
end