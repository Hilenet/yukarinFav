require 'bundler'
Bundler.require

# ログはファイルに吐け
$stdin = File.open 'log/all', 'a'
$stderr = File.open 'log/all', 'a'

#終了したらエラー
at_exit { 
  raiseError 'daemon has stopped'
  File.open 'log/all', 'a' do |f|
    f.puts "[#{Time.now}]: Process has stopped."
    f.puts "========="
  end
}


def main
  setup
  
  @stream.user do |event|
    next unless event.is_a? Twitter::Tweet
    next if event.user_mentions?
    
    if event.full_text.include? 'ゆかり'
      next unless filter event
      send_fav event
    end
  end
end

def setup
  File.open 'log/all', 'a' do |f|
    puts "========="
    puts "[#{Time.now}]: Process start running."
  end
  
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

def filter event
  except_word = ['定期', '生放送']
  except_user = ['yandere_yuduki', 'yukaridyy_bot', 'yukari_new_bot']
  
  text = event.full_text
  except_word.each do |w|
    return false if text.include? w
  end
  
  user = event.user.screen_name
  except_user.each do |u|
    return false if user.include? u
  end
  
  return true
end

def send_fav event
  res = @rest.favorite! event
  
  raiseError 'auth error happend' if res.is_a? Twitter::Error::Unauthorized
end

def raiseError mes #エラー処理
  File.open 'log/err', 'a' do |f|
    f.puts "[#{Time.now}]: #{mes}"
  end
end

main