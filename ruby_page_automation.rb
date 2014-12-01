# http://www.fec.gov/finance/disclosure/norindsea.shtml

gem 'mechanize',  '2.7.3'
gem 'nokogiri',   '1.6.5'

require 'mechanize'
require 'nokogiri'
require 'open-uri'

agent = Mechanize.new
page  = agent.get("http://www.fec.gov/finance/disclosure/norindsea.shtml")

# Searches for a form based on action. Fills in the appropriate fields of the form.
search_form = page.form_with :action => "http://docquery.fec.gov/cgi-bin/qind/"
search_form.field_with(:name => "lname").value = "Obama"
search_form.field_with(:name => "fname").value = "Barack"

# Submits form
search_results = agent.submit search_form

# Outputs results of the page that is generated after form submission. (tester)
puts search_results.body

if search_results.body.include? "60615"
  puts "lol"
end

=begin
# Converts the search results page to a string
search_results_page = search_results.uri.to_s
# puts search_results.at('b').text.strip


# doc = Nokogiri::HTML(open(search_results))
# puts search_results.respond_to?(:to_uri)
# puts doc

open(search_results_page) do |f|
  doc = Nokogiri::HTML(f.read)
  doc.css('b')[1].content
end
=end