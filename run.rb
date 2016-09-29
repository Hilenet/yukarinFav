require 'bundler'
Bundler.require

$stdin = File.open 'log/all', 'a'
$stderr = File.open 'log/all', 'a'

at_exit { #終了したらエラー
  raiseError 'daemon has stopped'
  File.open 'log/all', 'a' do |f|
    puts "[#{Time.now}]: Process has stopped."
    puts "========="
  end
}


def main
  @stream.user({}) do |event|
    next unless event.is_a? Twitter::Tweet
    next if event.user_mentions?
    
    send_fav event if event.full_text.include? 'ゆかり'
  end
end

def setup
  prof = YAML.load_file 'prof.yaml'
  @stream  = Twitter::Streaming::Client.new do |config|
    config.consumer_key        = prof['cred']['consumer']['key']
    config.consumer_secret     = prof['cred']['consumer']['secret']
    config.access_token        = prof['cred']['access_token']['key']
    config.access_token_secret = prof['cred']['access_token']['secret']
  end
  
  @rest = Twitter::REST::Client.new do |config|
    config.consumer_key        = prof['cred']['consumer']['key']
    config.consumer_secret     = prof['cred']['consumer']['secret']
    config.access_token        = prof['cred']['access_token']['key']
    config.access_token_secret = prof['cred']['access_token']['secret']
  end
end

def send_fav
  res = @rest.favorite!
  
  raiseError 'auth error happend' if res.is_a? Twitter::Error::Unauthorized
end

def raiseError mes #エラー処理
  File.open 'log/err', 'a' do |f|
    puts "[#{Time.now}]: #{mes}"
  end
end