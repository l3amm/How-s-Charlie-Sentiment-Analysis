require 'distillery'
require 'sanitize'
require 'indextank'
require 'date'

@months = Date::MONTHNAMES.collect { |mon|
  if !mon.nil?
    mon.downcase
  end
}

@months_abbr = Date::ABBR_MONTHNAMES.collect { |mon|
  if !mon.nil?
    mon.downcase
  end
}

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

def init_indextank
  api_url = "http://:0gV8oFvfEuktVu@defgo.api.indextank.com"
  api = IndexTank::Client.new api_url
  @index = api.indexes "howscharlie_all"
end

def time_rand from = Time.utc(2010,"jan",1,20,15,1), to = Time.now
    Time.at(from + rand * (to.to_f - from.to_f))
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

def perez_date(date_string)
  date_string =~ /(\D{3})\s*(\d+),\s*(\d+).*?(\d+\:\d+)/
  t = Time.new($3.to_i, @months_abbr.index($1.downcase), $2.to_i)
  return t.to_f
end

def superficial_date(day, month_name, year)
  t = Time.new(year.to_i, @months.index(month_name.downcase), day.to_i)
  return t.to_f
end

def parse_80legs_file(file)
  content = File.read(file)
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

    date_string = nil
    
    another_date = nil

    if url =~ /perezhilton\.com/
      html_string.scan(/Posted:.*?\<\/span\>(.*?)\<a/m)
      if !($1.nil?) 
        date_string = perez_date($1)
      end
      #puts date_string
    elsif (url =~ /thesuperficial\.com/) && !(url =~ /\/(tag|page)\//)
      html_string.scan(/class\=\"date\-text\"\>.*?(\w+)\s+(\d+).*?(\d+)/)
      if !($1.nil?)
        date_string = superficial_date($2, $1, $3)
      end
    end

    # Get sanitized content
    content = get_content(html_string) if html_string != nil

    # Get sentiment of content
    sentiment = analyze_sentiment(content)
    if (!url.empty?) && (!date_string.nil?)
      puts url
      puts sentiment
      puts date_string
      
      #puts content
      puts @index.document(url).add({:text => content, :date => date_string, :sentiment => sentiment, :url => url}, :variables => {0 => date_string, 1 => sentiment})
    end
  end
end

# - Main Code - #
@corpus = load_senti_file("sentiwords.txt")
@corpus.merge!(load_senti_file("sentislang.txt"))

init_indextank
Dir.glob('./perez_extended/*txt') {|file| 
  parse_80legs_file(file)
}

# Read content

