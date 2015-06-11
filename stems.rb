#!/usr/bin/env ruby

require 'optparse'
require 'yaml'
require 'ruby-progressbar'
require 'pry-byebug'

Stem = Struct.new(:word, :sevens) do
  def initialize(word, sevens={})
    super
  end

  def combinations
    sevens.values.flatten.size
  end

  def sevens_to_hash
    sevens.each do |k,v|
      sevens[k] = v.map(&:word)
    end
  end
end
Seven = Struct.new(:word) do
  # inspired by http://stackoverflow.com/questions/3852755/ruby-array-subtraction-without-removing-items-more-than-once
  def subtract_each_char_once(stem_word)
    counts = stem_word.downcase.chars.inject(Hash.new(0)) { |h, v| h[v] += 1; h }
    self.word.downcase.chars.reject { |c| counts[c] -= 1 unless counts[c].zero? }
  end
end

# expected syntax: ./stems.rb -n 4 wordlist.txt
# parsing command line input
$cutoff = 0
OptionParser.new do |o|
  o.on('-n INT', 'Size of LCD digits') { |b| $cutoff = b.to_i }
  o.on('-h', 'Help') { puts o; exit }
  o.parse!
end

unless ARGV.size == 2 && test(?e, ARGV[0])
  puts "Usage: #{$PROGRAM_NAME} -n 4 wordlist.txt output"
  exit
end

$output = ARGV[1]

puts "Finding all six letter words that combine with #{$cutoff} or more distinct letters."

# find all six and seven letter words.
stems = []
sevens = []

File.foreach(ARGV[0]) do |line|
  line.chomp!
  if line.size == 6
    stems << Stem.new(line)
  elsif line.size == 7
    sevens << Seven.new(line)
  end
end

# for each stem, find all sevens, grouped by the distinct letter.
progress = ProgressBar.create(title: "Evaluating strings...", total: stems.size)
stems.each do |stem|
  progress.title = stem.word
  progress.increment
  sevens.each do |seven|
    # binding.pry
    odd_letter = seven.subtract_each_char_once(stem.word)
    # find sevens with exactly one extra letter
    next if odd_letter.size > 1
    stem.sevens[odd_letter.first] ||= []
    stem.sevens[odd_letter.first] << seven 
  end
  # puts "#{stem.word}: #{stem.sevens}"
end

# keep stems that have n or more letters
stems.select! { |stem| stem.sevens.keys.size >= $cutoff }

# sort stems by number of combinations
stems.sort_by! { |stem| stem.combinations }.reverse!

output = {}
stems.each do |stem|
  output[stem.word] = {
    'combinations': stem.combinations,
    'words': stem.sevens_to_hash
  }
end

File.write("#{$output}.yml", output.to_yaml)