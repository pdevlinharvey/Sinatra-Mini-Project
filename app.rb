require "sinatra"
require "sinatra/reloader"
require "http"
require "json"


def fetch_icon(query)
  url = "https://api.iconfinder.com/v4/icons/search?query=#{query}&count=1"
  response = HTTP.headers(Authorization: "Bearer #{ENV.fetch('ICON_FINDER_KEY')}").get(url)
  data = JSON.parse(response.body.to_s)
  @icon_url = data['icons'][0]['raster_sizes'][0]['formats'][0]['preview_url']
end

def get_icon_based_on_similarity(similarity_score)
  if similarity_score >= 0.75
    fetch_icon("smiley")
  elsif similarity_score >= 0.5
    fetch_icon("neutral face")
  else
    fetch_icon("sad face")
  end
end

english_bigram_probs = {
  "th" => 0.03882543,
  "he" => 0.03681391,
  "in" => 0.02283899,
  "er" => 0.02178042,
  "an" => 0.02140460,
  "re" => 0.01749394,
  "nd" => 0.01571977,
  "on" => 0.01418244,
  "en" => 0.01383239,
  "at" => 0.01335523,
  "ou" => 0.01285484,
  "ed" => 0.01275779,
  "ha" => 0.01274742,
  "to" => 0.01169655,
  "or" => 0.01151094,
  "it" => 0.01134891,
  "is" => 0.01109877,
  "hi" => 0.01092302,
  "es" => 0.01092301,
  "ng" => 0.01053385
}

def cosine_similarity(input_frequencies, english_frequencies)
  common_bigrams = input_frequencies.keys & english_frequencies.keys
  dot_product = common_bigrams.reduce(0) { |sum, bigram| sum + input_frequencies[bigram] * english_frequencies[bigram] }
  input_magnitude = Math.sqrt(input_frequencies.values.reduce(0) { |sum, value| sum + value**2 })
  english_magnitude = Math.sqrt(english_frequencies.values.reduce(0) { |sum, value| sum + value**2 })
  return 0 if input_magnitude == 0 || english_magnitude == 0
  dot_product / (input_magnitude * english_magnitude)
end

get("/") do
  erb(:homepage)
end

get("/results") do
  user_input_raw = params.fetch("user_input")
  
  user_input_clean = user_input_raw.gsub(/\W/, "")

  bigrams = []
  
  i = 0

  while i < user_input_clean.length - 1
    bigrams << user_input_clean[i..i+1]
    i += 2
  end

  frequency = bigrams.each_with_object(Hash.new(0)) { |bigram, counts| counts[bigram] += 1 }
  
  total_bigrams = bigrams.length.to_f
  
  normalized_input_frequencies = frequency.transform_values { |count| count / total_bigrams }
  
  @similarity_score = cosine_similarity(normalized_input_frequencies, english_bigram_probs)
  
  @sorted_frequency = frequency.sort_by { |bigram, count| -count }

  @icon_url = get_icon_based_on_similarity(@similarity_score)

  erb(:results)
end
