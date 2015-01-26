# http://www.fec.gov/finance/disclosure/norindsea.shtml

=begin
gem 'mechanize',  '2.7.3'

require 'mechanize'

fname = 'John'
lname = 'Smith'
contribution_type = 'New Category'
total_found = false
file_out = '../../Documents/fec_dot_gov.txt' # Route from the script folder
test_file_out = '../..//Documents/test.txt' # Used for testing
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

run = 0 # Test variable

a = 0
while total_found == false
#while a < 6
  temporary = Hash.new # Used to store each cycle of info and gets saved to an array
#----type than name
  if a == 0
    if search_results_body.index('<font') == 386 # Checks if "Contributions to Political Committees" is first
      contribution_type = 'Contributions to Political Committees'
      temporary[:type] = contribution_type
      puts 'Contributions to Political Committees'
      search_results_body = search_results_body.slice((search_results_body.index('</font>') + 18)..search_results_body.length)
    elsif search_results_body.index('<font') == 389 # Checks if "Non-Federal Receipts 'Exempt From Limits'" is first
      contribution_type = "Non-Federal Receipts 'Exempt From Limits'"
      temporary[:type] = contribution_type
      puts "Non-Federal Receipts 'Exempt From Limits'"
      search_results_body = search_results_body.slice((search_results_body.index('</font>') + 22)..search_results_body.length)
    else
      puts 'New Category'
      temporary[:type] = 'New Category'
    end
  elsif a > 0
    temporary[:type] = contribution_type
    puts contribution_type
    search_results_body = search_results_body.slice((search_results_body.index('</table>') + 16)..search_results_body.length)
  else
    puts "Fucked up ln #{__LINE__}"
  end
  temporary[:name] = search_results_body.slice(0..search_results_body.index('</b>') - 1)
#----address
  search_results_body = search_results_body.slice((search_results_body.index('<br>') + 5)..search_results_body.length)
  temporary[:address] = search_results_body.slice(0..(search_results_body.index('<br>') - 1))
#----address_name
  if search_results_body.index("<br>\n<br>") < 10
    #puts 'Not found'
    temporary[:address_name] = 'Not Found' # Website has nothing
  else
    search_results_body = search_results_body.slice(5..search_results_body.length)
    temporary[:address_name] = search_results_body.slice(0..(search_results_body.index('<br>') - 1))
  end
#----to
  search_results_body = search_results_body.slice(search_results_body.index('<a')..search_results_body.length)
  search_results_body = search_results_body.slice((search_results_body.index('>') + 1)..search_results_body.length)
  temporary[:to] = search_results_body.slice(0..(search_results_body.index('</a>') - 1))
#----via
  if search_results_body.index('via') < search_results_body.index('<a')
    search_results_body = search_results_body.slice(search_results_body.index('<a')..search_results_body.length)
    search_results_body = search_results_body.slice((search_results_body.index('>') + 1)..search_results_body.length)
    temporary[:via] = search_results_body.slice(0..(search_results_body.index('</a>') - 1))
  end
  transaction_hash = Hash.new   # Used to store date, amount, and contribute_num
  transaction_array = Array.new # Used to store transaction_hash
  b = 0
  #c = search_results_body.slice!(0..(search_results_body.index('</table>'))).scan(/<td/).count
  #puts "C #{c}"
  #while b < c
  #puts search_results_body.slice!(0..(search_results_body.index('</table>'))).scan(/<td/).count()
  #while search_results_body.index("</td></tr>\n</table>") > 225 # 225 was based off of tests as a "safe" variable
  #while b != 2
    #----date
    search_results_body = search_results_body.slice((search_results_body.index('</td><td') + 8)..search_results_body.length)
    transaction_hash[:date] = search_results_body.slice((search_results_body.index('>') + 1)..(search_results_body.index('</td>') - 1))
    #----amount
    search_results_body = search_results_body.slice((search_results_body.index('<td') + 3)..search_results_body.length)
    transaction_hash[:amount] = search_results_body.slice((search_results_body.index('>') + 1)..(search_results_body.index('</td>') - 1))
    #----contribute_num (double check what this number means)
    search_results_body = search_results_body.slice(search_results_body.index('<a')..search_results_body.length)
    search_results_body = search_results_body.slice((search_results_body.index('>') + 1)..search_results_body.length)
    transaction_hash[:contribute_num] = search_results_body.slice!(0..(search_results_body.index('</a>') - 1))
    transaction_array.push(transaction_hash)

    if run == 4
      puts "Did things"
      if run == 4
        search_results_body_test = transaction_hash[:amount]
      end
      #----date
      search_results_body = search_results_body.slice((search_results_body.index('</td><td') + 8)..search_results_body.length)
      transaction_hash[:date] = search_results_body.slice((search_results_body.index('>') + 1)..(search_results_body.index('</td>') - 1))
      #----amount
      search_results_body = search_results_body.slice((search_results_body.index('<td') + 3)..search_results_body.length)
      transaction_hash[:amount] = search_results_body.slice((search_results_body.index('>') + 1)..(search_results_body.index('</td>') - 1))
      #----contribute_num (double check what this number means)
      search_results_body = search_results_body.slice(search_results_body.index('<a')..search_results_body.length)
      search_results_body = search_results_body.slice((search_results_body.index('>') + 1)..search_results_body.length)
      transaction_hash[:contribute_num] = search_results_body.slice!(0..(search_results_body.index('</a>') - 1))
      transaction_array.push(transaction_hash)
    end
    b += 1
  #end
  run += 1
  temporary[:transaction] = transaction_array
  puts transaction_array
  puts "Run #{run}"

#----Creates output to array
  hash_array.push(temporary)
#----Checks if Total amount came and adds to output array
  if search_results_body.index('><b>total ') == 60
    temporary = Hash.new
    temporary[:total_type] = contribution_type
    temporary[:total_amt] = search_results_body.slice((search_results_body.index('&nbsp') + 13)..(search_results_body.index('</b>') - 1))
    hash_array.push(temporary)
    total_found = true
  end
  a += 1
end

# Outputs the result
output_file = File.new(file_out, 'w+')
output_file.puts(hash_array)
output_file.close

# Outputs test result
output_file = File.new(test_file_out, 'w+')
output_file.puts(search_results_body_test)
output_file.close
=end

gem 'mechanize',  '2.7.3'
gem 'nokogiri',   '1.6.5'

require 'mechanize'
require 'nokogiri'

numberey = 0
if numberey == 0
  FNAME = 'hillary'
  LNAME = 'clinton'
elsif numberey == 1
  FNAME = 'john'
  LNAME = 'smith'
end
PAGE_FILE_OUT = '../../Documents/page_file_out.html' # Used for outputting the submitted form page
FILE_OUT = '../../Documents/fec_dot_gov.txt' # Route from the script folder
TEST_FILE_OUT = '../../Documents/test.txt' # Used for testing

$contribution_type = 'No Contribution Yet'
$hash_array = Array.new

agent = Mechanize.new
page  = agent.get('http://www.fec.gov/finance/disclosure/norindsea.shtml')

# Searches for a form based on action. Fills in the appropriate fields of the form.
search_form = page.form_with :action => 'http://docquery.fec.gov/cgi-bin/qind/'
search_form.field_with(:name => 'lname').value = "#{LNAME}"
search_form.field_with(:name => 'fname').value = "#{FNAME}"

# Submits form
search_results = agent.submit search_form

# Converts the Mechanize::Page object into a Nokogiri::HTML::Document
html_doc = Nokogiri::HTML(search_results.body.downcase)

temporary_hash = Hash.new # Used to store each cycle of info and gets saved to an array

# Grabs the contribution type.
# NOTE: //text() will grab the text between the tags.
if html_doc.css('b/text()')[1].to_s == 'contributions to political committees'
  contribution_type = html_doc.css('b/text()')[1].to_s
  temporary_hash[:type] = contribution_type
elsif html_doc.css('font/text()')[0].to_s == 'non-federal receipts "exempt from limits"'
  contribution_type = html_doc.css('font/text()')[0].to_s
  temporary_hash[:type] = contribution_type
end
#puts html_doc.css('font')

a = 0
# Do while the first or last name is present in the selected link area
while (html_doc.xpath('//body/b/text()')[a].to_s.include? "#{FNAME}") || (html_doc.xpath('/body/b/text()')[a].to_s.include? "#{LNAME}")
  if a != 0
    temporary_hash = Hash.new
    temporary_hash[:type] = contribution_type
  end
  # Grabs the name
  if (html_doc.xpath('//body/b/text()')[a].to_s.include? "#{FNAME}") || (html_doc.xpath('/body/b/text()')[a].to_s.include? "#{LNAME}")
    temporary_hash[:name] = html_doc.xpath('//body/b/text()')[a].to_s
  end

  # Grabs the address
  # EX: CITY, ST #####
  address = html_doc.xpath('//body/b')[a].next.next.text.strip
  temporary_hash[:address] = address

  # Grabs address name
  if (html_doc.xpath('//body/b')[a].next.next.next.next.text.strip == '') == false
    address_name = html_doc.xpath('//body/b')[a].next.next.next.next.text.strip
    temporary_hash[:address_name] = address_name
  else
    temporary_hash[:address_name] = 'NO ADDRESS NAME'
  end

  # Grabs to who donation and via who (if applicable)
  temporary_hash[:to] = html_doc.xpath('//tr/td')[0].children[1].text.strip
  # The via part
  via = false # Used to determine the proper numbers for the donation part
  if html_doc.xpath('//tr/td')[0].children.to_s.include? '<b>via</b>'
    temporary_hash[:via] = html_doc.xpath('//tr/td/a/text()')[1].to_s
    via = true
  else
    temporary_hash[:via] = 'NO VIA'
    via = false
  end

  # Retrieves the donation date, amount, and id
  transaction_array = Array.new
  transaction_hash = Hash.new
  if via == true
    transaction_hash[:date] = html_doc.xpath('//tr/td/text()')[3].to_s
    transaction_hash[:amount] = html_doc.xpath('//tr/td/text()')[4].to_s
    transaction_hash[:donate_id] = html_doc.xpath('//tr/td/a/text()')[2].to_s
  else
    transaction_hash[:date] = html_doc.xpath('//tr/td/text()')[1].to_s
    transaction_hash[:amount] = html_doc.xpath('//tr/td/text()')[2].to_s
    transaction_hash[:donate_id] = html_doc.xpath('//tr/td/a/text()')[1].to_s
  end
  transaction_array.push(transaction_hash)
  temporary_hash[:donation] = transaction_array

  # Removes the unneeded code in order to make the :to and :via part easier to extract
  5.times do
    html_doc.xpath('//tr/td')[0].remove
  end

  a += 1
  $hash_array.push(temporary_hash)

end

#puts temporary

=begin
output_file = File.new(page_file_out, 'w+')
output_file.puts(html_doc)
output_file.close
=end

# Outputs the result
output_file = File.new(FILE_OUT, 'w+')
output_file.puts($hash_array)
output_file.close

# Outputs test result
output_file = File.new(TEST_FILE_OUT, 'w+')
output_file.puts(html_doc)
output_file.close