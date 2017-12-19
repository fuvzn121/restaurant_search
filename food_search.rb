require 'json'
require 'twitter'
require 'open-uri'

CONSUMER = "050YbM66pRACoAC2CDrNu0Rfd"
CONSUMER_SECRET = "I4JySQbEwqFZYOqtOKlJKqEeqIPjjErx5iTGcyu7rT6PZ4klB8"
TOKEN = "2574348462-wNijnw0s8szzy6S90LW94QRSLoR9oT5RHRL5j6R"
TOKEN_SECRET = "P4Sz5dj32K0Rno5fwfYMwzxCS60CgK9ZNuUeAIIlAJeZt"

rest = Twitter::REST::Client.new do |config|
  config.consumer_key        = CONSUMER
  config.consumer_secret     = CONSUMER_SECRET
  config.access_token        = TOKEN
  config.access_token_secret = TOKEN_SECRET
end

stream = Twitter::Streaming::Client.new do |config|
  config.consumer_key        = CONSUMER
  config.consumer_secret     = CONSUMER_SECRET
  config.access_token        = TOKEN
  config.access_token_secret = TOKEN_SECRET
end

my_name = rest.user.screen_name
stream.user do |object|
  regex = /食べたい$|飲みたい$/
  if (object.is_a?(Twitter::Tweet) && object.text.match(regex)) \
    && (object.user.screen_name == my_name || object.in_reply_to_screen_name == my_name)
    id = object.id
    to_name = object.user.screen_name
    food = object.text.gsub(regex, "")
    food = food.gsub(/@.+\s/, "") if object.in_reply_to_screen_name == my_name
    url = "https://api.gnavi.co.jp/RestSearchAPI/20150630/?keyid=3387d22587c7f29f84cf490110541a26&format=json&areacode_s=AREAS2288&freeword=#{food}"
    hash =  JSON.parse(open(URI.escape url).read)
    hash_num = rand(hash["hit_per_page"].to_i)
    if hash['error']
      rest.update("@#{to_name} \"#{food}\"に関するお店が見つかりません", in_reply_to_status_id: id)
    else
      name =  hash['rest'][hash_num]['name']
      link = hash['rest'][hash_num]['url']
      rest.update("@#{to_name} このお店がおすすめです\n#{name}\n#{link}", in_reply_to_status_id: id)
    end
  end
end
