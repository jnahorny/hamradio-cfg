#!/usr/bin/env ruby

require 'csv'
require 'optparse'

options = { :input => nil, :output => nil, :verbose => false }

parser = OptionParser.new do |opts|
  opts.banner = "Usage: #{$0} -i input -o output [-v]"
  opts.separator ""
  opts.separator "Options"
  opts.on('-i', '--input file', 'input file path') do |input|
    options[:input] = input
  end
  opts.on('-o', '--output file', 'output file path') do |output|
    options[:output] = output
  end
  opts.on('-v', '--verbose', 'verbose output to STDOUT') do |verbose|
    options[:verbose] = true
  end
  opts.on('-h', '--help', 'display usage') do |help|
    puts opts
    exit
  end
end

parser.parse!

if (options[:input] == nil) || (options[:output] == nil)
  puts parser
  exit
end

output_headers = ['id', 'comment', 'freq', 'name', 'mode']

# custom converter based on http://technicalpickles.com/posts/parsing-csv-with-ruby/
CSV::Converters[:blank_to_nil] = lambda do |field|
  field && !field.empty? ? field : nil
end

CSV.open(options[:output], 'w',
         {
           :force_quotes => false,
           :write_headers => true,
           :headers => output_headers,
           :converters => [:all, :blank_to_nil]
         }) do |csv|
  CSV.foreach(options[:input],
              {
                :headers => true,
                :header_converters => :symbol,
                :skip_blanks => true,
                :skip_lines => '^#.*'
              }) do |row|
    csv << [row[:id], row[:comment], row[:freq], row[:name], row[:mode]]
  end
end
