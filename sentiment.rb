def load_senti_file (filename)
  sentihash = {}
  # load the word file
  file = File.new(filename)
  while (line = file.gets)
    parsedline = line.chomp.split("\t")
    sentiscore = parsedline[0]
    text = parsedline[1]
    sentihash[text] = sentiscore.to_f
  end
  file.close

  return sentihash
end

def analyze_sentiment(text)
  puts @corpus.size
  
  # tokenize the text
  tokens = text.split

  # Check the sentiment value of each token against the sentihash.
  # Since each word has a positive or negative numeric sentiment value
  # we can just sum the values of all the sentimental words. If it is
  # positive then we say the tweet is positive. If it is negative we 
  # say the tweet is negative.
  sentiment_total = 0.0

  for token in tokens do
    sentiment_value = @corpus[token]
    if sentiment_value
      sentiment_total += sentiment_value
    end
  end
  
  return sentiment_total
end


# - Main Code - #
# @corpus = load_senti_file("sentiwords.txt")
# @corpus.merge!(load_senti_file("sentislang.txt"))
# file = File.open("positive.txt", "r")
# text = file.read
# file.close
# 
# sentiment = analyze_sentiment(text)
# puts sentiment

# Read urls
url_array = []
file = File.open("sample_urls.txt", "r+")
file.each do |line|
  url_array << line.strip
end
file.close

# Read content
file = File.open("content.txt", "r")
content = file.read
file.close

content_blocks = []
#url_array.shuffle!
url_array.each do |url|
  clean_url = Regexp.escape(url)
  clean_url = clean_url.gsub(/\//, "\\/")

  content.scan(/^{clean_url}\s*\n([\s\S]*?)http/)
  content_blocks.push($1)
end

content_blocks.flatten!

puts content_blocks.size
puts content_blocks[2]
puts content =~ /http:\/\/perezhilton\.com\/page\/3\/\n/
  