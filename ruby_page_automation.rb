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
search_form.field_with(:name => "lname").value = "Barack"
search_form.field_with(:name => "fname").value = "Obama"

# Submits form
search_results = agent.submit search_form

# Outputs results of the page that is generated after form submission. (tester)
#puts search_results.body

# Sets the search results page and gets the html code and saves it to a variable as a string
search_results_body = search_results.body.downcase

# Cuts out the unneeded junk html code
search_results_body = search_results_body.slice!(479..(search_results_body.length-212))

puts search_results_body.index('<b>obama, barack</b>')

puts search_results_body#.length#.index("15256.00")
=begin
b_count = 0
iteration_counter = 0
0.step(search_results_body.length, 1) do |a|
  if search_results_body[a] == "b"
    b_count = b_count + 1
  end
  iteration_counter = iteration_counter + 1
end
=end