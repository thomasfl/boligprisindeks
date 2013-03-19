require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'pry'

doc = Nokogiri::HTML(open('http://www.ssb.no/a/kortnavn/bpi/tab-2013-01-16-01.html'))
table = doc.css('table')[2]
tr = table.css('tr')
tr.css('tr').each do |row|
  ## [0..12].each do |columnIndex|
  [0..1].each do |columnIndex|
    if(row.css('td')[columnIndex])
      print row.css('td')[columnIndex].text
    end
  end
  puts
end

# binding.pry
