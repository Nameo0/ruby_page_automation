# http://www.fec.gov/finance/disclosure/norindsea.shtml

gem 'mechanize',  '2.7.3'

require 'mechanize'

fname = 'Hillary'
lname = 'Clinton'
contribution_type = 'New Category'
file_out = '../../Documents/fec_dot_gov.txt' # Route from the script folder
hash_array = Array.new

agent = Mechanize.new
page  = agent.get('http://www.fec.gov/finance/disclosure/norindsea.shtml')

# Searches for a form based on action. Fills in the appropriate fields of the form.
search_form = page.form_with :action => 'http://docquery.fec.gov/cgi-bin/qind/'
search_form.field_with(:name => 'lname').value = "#{lname}"
search_form.field_with(:name => 'fname').value = "#{fname}"

# Submits form
search_results = agent.submit search_form

# Sets the search results page and gets the html code and saves it as a string
search_results_body = search_results.body.downcase

a = 0
while a < 3
  temporary = Hash.new
#----type than name
  if a == 0
    if search_results_body.index('<font') == 386 # Checks if "Contributions to Political Committees" is first
      contribution_type = 'Contributions to Political Committees'
      temporary[:type] = contribution_type
      puts 'Contributions to Political Committees'
      search_results_body = search_results_body.slice!((search_results_body.index('</font>') + 18)..search_results_body.length)
    elsif search_results_body.index('<font') == 389 # Checks if "Non-Federal Receipts 'Exempt From Limits'" is first
      contribution_type = "Non-Federal Receipts 'Exempt From Limits'"
      temporary[:type] = contribution_type
      puts "Non-Federal Receipts 'Exempt From Limits'"
      search_results_body = search_results_body.slice!((search_results_body.index('</font>') + 22)..search_results_body.length)
    else
      puts 'New Category'
      temporary[:type] = 'New Category'
    end
  elsif a > 0
    temporary[:type] = contribution_type
    puts contribution_type
    search_results_body = search_results_body.slice!((search_results_body.index('</table>') + 16)..search_results_body.length)
  else
    puts "Fucked up ln 50"
  end
  temporary[:name] = search_results_body.slice!(0..search_results_body.index('</b>') - 1)
#----address
  search_results_body = search_results_body.slice!((search_results_body.index('<br>') + 5)..search_results_body.length)
  temporary[:address] = search_results_body.slice!(0..(search_results_body.index('<br>') - 1))
#----address_name
  if search_results_body.index("<br>\n<br>") < 10
    puts 'Not found'
    temporary[:address_name] = 'Not Found' # Website has nothing
  else
    search_results_body = search_results_body.slice!(5..search_results_body.length)
    temporary[:address_name] = search_results_body.slice!(0..(search_results_body.index('<br>') - 1))
    #puts temporary[:address_name]
  end
#----to
  search_results_body = search_results_body.slice!(search_results_body.index('<a')..search_results_body.length)
  search_results_body = search_results_body.slice!((search_results_body.index('>') + 1)..search_results_body.length)
  temporary[:to] = search_results_body.slice!(0..(search_results_body.index('</a>') - 1))
#----via
  if search_results_body.index('via') < search_results_body.index('<a')
    search_results_body = search_results_body.slice!(search_results_body.index('<a')..search_results_body.length)
    search_results_body = search_results_body.slice!((search_results_body.index('>') + 1)..search_results_body.length)
    temporary[:via] = search_results_body.slice!(0..(search_results_body.index('</a>') - 1))
  end
# I might have to loop the following three
#----date
  search_results_body = search_results_body.slice!((search_results_body.index('</td><td') + 8)..search_results_body.length)
  temporary[:date] = search_results_body.slice!((search_results_body.index('>') + 1)..(search_results_body.index('</td>') - 1))
#----amount
  search_results_body = search_results_body.slice!((search_results_body.index('<td') + 3)..search_results_body.length)
  temporary[:amount] = search_results_body.slice!((search_results_body.index('>') + 1)..(search_results_body.index('</td>') - 1))
#----contribute_num (double check what this number means)
  search_results_body = search_results_body.slice!(search_results_body.index('<a')..search_results_body.length)
  search_results_body = search_results_body.slice!((search_results_body.index('>') + 1)..search_results_body.length)
  temporary[:contribute_num] = search_results_body.slice!(0..(search_results_body.index('</a>') - 1))
  #puts search_results_body
  #puts temporary
#----Creates output to array
  hash_array.push(temporary)
  a = a + 1
end

#puts search_results_body
puts hash_array

# Outputs the result
output_file = File.new(file_out, 'w+')
output_file.puts(hash_array)
output_file.close