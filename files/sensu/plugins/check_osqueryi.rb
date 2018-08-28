#!/usr/bin/env ruby
require  ‘json’

query = ARGV[0]
field = ARGV[1]
match = ARGV[2]

# Execute query via osqueryi
query  =  JSON.parse(`osqueryi "#{query}" --json`).first
result = query[field]
if  match  == result
 puts "Match found"
exit 0
else
 puts "No Match Found"
exit 1
end
