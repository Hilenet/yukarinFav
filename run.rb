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

# APIクライアントとパーサの設定
def setup
  File.open 'log/all', 'a' do |f|
    puts "========="
    puts "[#{Time.now}]: Process start running."
  end
  
  prof = YAML.load_file('prof.yaml')
  cred = prof['cred']
  @except = prof['except']
  @stream  = Twitter::Streaming::Client.new do |config|
    config.consumer_key        = cred['consumer']['key']
    config.consumer_secret     = cred['consumer']['secret']
    config.access_token        = cred['access_token']['key']
    config.access_token_secret = cred['access_token']['secret']
  end
  
  @rest = Twitter::REST::Client.new do |config|
    config.consumer_key        = cred['consumer']['key']
    config.consumer_secret     = cred['consumer']['secret']
    config.access_token        = cred['access_token']['key']
    config.access_token_secret = cred['access_token']['secret']
  end

  @dic = {}
  File.open 'dic/pn_ja.dic', 'r' do |f|
    f.each_line do |line|
     units = line.split ":"
     @dic[units[0]] = units[3].to_f
   end
  end
  @parser = Natto::MeCab.new 
end

# パースしてexcept系から判断
def filter event
  text = event.full_text
  @except['word'].each do |w|
    return false if text.include? w
  end
  
  user = event.user.screen_name
  @except['user'].each do |u|
    return false if user.include? u
  end
  
  score = 0
  @parser.parse(text).each_line do |node|
    w = node.split(",")[6]
    score += @dic[w] if @dic[w]
  end
  if score < 0
    File.open 'log/negatives', 'a' do |f|
      f.puts "#{Time.now}: #{event.user.name}/#{score}\n#{text}\n=====\n"
    end
    return false
  end

  return true
end

# favる
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
