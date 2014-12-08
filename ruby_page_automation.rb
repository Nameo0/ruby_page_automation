# http://www.fec.gov/finance/disclosure/norindsea.shtml

gem 'mechanize',  '2.7.3'
gem 'nokogiri',   '1.6.5'

require 'mechanize'
require 'nokogiri'
require 'open-uri'

fname = "John"
lname = "Smith"
non_federal_receipts = Array.new
contributions_to_political_committees = Array.new

agent = Mechanize.new
page  = agent.get("http://www.fec.gov/finance/disclosure/norindsea.shtml")

# Searches for a form based on action. Fills in the appropriate fields of the form.
search_form = page.form_with :action => "http://docquery.fec.gov/cgi-bin/qind/"
search_form.field_with(:name => "lname").value = "#{lname}"
search_form.field_with(:name => "fname").value = "#{fname}"

# Submits form
search_results = agent.submit search_form

# Outputs results of the page that is generated after form submission. (tester)
#puts search_results.body

# Sets the search results page and gets the html code and saves it to a variable as a string
search_results_body = search_results.body.downcase

puts search_results_body.index('<b>#{lname}, #{fname}</b>')

#puts search_results_body#.length#.index("15256.00")
puts search_results_body.index("<font")

#while a=0 < search_results_body.length
  temporary = Hash.new
#----type than name
  if search_results_body.index("<font") == 386 # Checks if "Contributions to Political Committees" is first
    temporary[:type] = "Contributions to Political Committees"
    search_results_body = search_results_body.slice!((search_results_body.index("</font>") + 18)..search_results_body.length)
  elsif search_results_body.index("<font") == 389 # Checks if "Non-Federal Receipts 'Exempt From Limits'" is first
    temporary[:type] = "Non-Federal Receipts 'Exempt From Limits'"
    search_results_body = search_results_body.slice!((search_results_body.index("</font>") + 22)..search_results_body.length)
  else puts "New Category"
  end
  temporary[:name] = search_results_body.slice!(0..search_results_body.index("</b>") - 1)
#----to
  #puts search_results_body.index("<a")
  search_results_body = search_results_body.slice!(search_results_body.index("<a")..search_results_body.length)
  search_results_body = search_results_body.slice!((search_results_body.index(">") + 1)..search_results_body.length)
  temporary[:to] = search_results_body.slice!(0..(search_results_body.index("</a>") - 1))
#----via
  if search_results_body.index("via") < search_results_body.index("<a")
    search_results_body = search_results_body.slice!(search_results_body.index("<a")..search_results_body.length)
    search_results_body = search_results_body.slice!((search_results_body.index(">") + 1)..search_results_body.length)
    temporary[:via] = search_results_body.slice!(0..(search_results_body.index("</a>") - 1))
  end
# I might have to loop the following three
#----date
  search_results_body = search_results_body.slice!((search_results_body.index("</td><td") + 8)..search_results_body.length)
  temporary[:date] = search_results_body.slice!((search_results_body.index(">") + 1)..(search_results_body.index("</td>") - 1))
#----amount
  search_results_body = search_results_body.slice!((search_results_body.index("<td") + 3)..search_results_body.length)
  temporary[:amount] = search_results_body.slice!((search_results_body.index(">") + 1)..(search_results_body.index("</td>") - 1))
#----contribute_num (double check what this number means)
  search_results_body = search_results_body.slice!(search_results_body.index("<a")..search_results_body.length)
  search_results_body = search_results_body.slice!((search_results_body.index(">") + 1)..search_results_body.length)
  temporary[:contribute_num] = search_results_body.slice!(0..(search_results_body.index("</a>") - 1))
  #puts search_results_body.index("via")
  #puts search_results_body
  puts temporary
#end