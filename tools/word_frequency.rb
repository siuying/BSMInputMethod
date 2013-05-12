require 'pry'

class WordFrequency
  attr_reader :frequency

  DEFAULT_FREQUENCY = 6000

  def initialize(file)
    data = open(file, 'r:BIG5').read
    ec = Encoding::Converter.new("BIG5", "UTF-8", :invalid => :replace, :undef => :replace )
    
    @frequency = {}
    data = ec.convert(data)
    data.split("\r\n").each do |line|
      process_line(line)
    end
  end

  def [](word)
    frequency[word] || DEFAULT_FREQUENCY
  end

  private
  def process_line(line)
    index = line[7, 7].strip.to_i rescue 0
    word  = line[16]
    if word && index && word.length > 0 && index > 0
      @frequency[word] = index
    end
  end
end