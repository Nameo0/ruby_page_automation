# http://www.fec.gov/finance/disclosure/norindsea.shtml

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
  via_exist = false # Used to determine the proper numbers for the donation part
  if html_doc.xpath('//tr/td')[0].children.to_s.include? '<b>via</b>'
    temporary_hash[:via] = html_doc.xpath('//tr/td/a/text()')[1].to_s
    via_exist = true
  else
    temporary_hash[:via] = 'NO VIA'
    via_exist = false
  end

  # Retrieves the donation date, amount, and id
  transaction_array = Array.new
  transaction_hash = Hash.new
  if via_exist == true
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