load_paths = Dir["/vendor/bundle/ruby/2.7.0/gems/**/lib"]
$LOAD_PATH.unshift(*load_paths)

require 'rss'
require 'date'
require 'line/bot'
require 'dotenv'

Dotenv.load

def lambda_handler(event:, context:)
    rss = RSS::Parser.parse("http://www.city.hamada.shimane.jp/www/rss/news.rdf", false)

    now = Time.now.to_s

    today = Date.parse(now)

    now = Time.now.to_s
    today = Date.parse(now)
    date_regexp = today.strftime("%m月%d日")

    if date_regexp.start_with?("0")
        date_regexp.delete_prefix!("0") 
    end

    client = Line::Bot::Client.new { |config|
        config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
        config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
    }

    rss.items.each{|item|
        if item.title =~ /新型コロナ|#{date_regexp}|#{date_regexp.tr('0-9', '０-９')}/ 
            message = {
                type: 'text',
                text: "件名: #{item.title}\n\nリンク: #{item.link}\n\n作成日時: #{date_regexp}"
            }
            client.broadcast(message)
        end
    }
end