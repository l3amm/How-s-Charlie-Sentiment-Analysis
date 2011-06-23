require 'distillery'
require 'sanitize'

def get_content(html_string)
  return Sanitize.clean(Distillery.distill(html_string))
end

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
  # tokenize the text
  tokens = text.split

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
@corpus = load_senti_file("sentiwords.txt")
@corpus.merge!(load_senti_file("sentislang.txt"))

# Read content
content = File.read("content.txt")
content_blocks = []

clean_url = Regexp.new("(^http.*?)^(http|\Z)", Regexp::MULTILINE)
content_blocks = content.scan(clean_url)
content_blocks.collect! { |b| b[0] }
content_blocks.each do |b| 
  b.gsub!(/[\n\t\r]|( {2,})/, "") if b != nil
end

content_blocks.each_with_index do |html_string, i|
  # TO DO: GET DATE
  
  #Get URL
  url = html_string.match(/^.*?</).to_s.chop
  
  # Get sanitized content
  content = get_content(html_string) if html_string != nil
  
  # Get sentiment of content
  sentiment = analyze_sentiment(content)
end