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

stream.user do |object|
  regex = /食べたい$/
  if object.is_a?(Twitter::Tweet)
    if object.user.screen_name == "hrys__" and object.text.match(regex)
      food = object.text.gsub(regex, "")
      url = "https://api.gnavi.co.jp/RestSearchAPI/20150630/?keyid=3387d22587c7f29f84cf490110541a26&format=json&areacode_s=AREAS2288&freeword=#{food}&hit_per_page=1"
      hash = JSON.parse(open(URI.escape url).read)
      hash =  JSON.parse(open(URI.escape url).read)
      if hash['rest'].empty?
        rest.update("@hrys__ \"#{food}\"に関するお店が見つかりません")
      else
        name =  hash['rest']['name']
        link = hash['rest']['url']
        rest.update("@hrys__ このお店がおすすめです\n#{name}\n#{link}")
      end
    end
  end

end
