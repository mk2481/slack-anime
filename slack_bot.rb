require "http"
require "json"
require "eventmachine"
require "faye/websocket"
require "./anime.rb"

URL = {
  "api_test" => "https://slack.com/api/api.test",
  "auth_test" => "https://slack.com/api/auth.test",
  "chat_post" => "https://slack.com/api/chat.postMessage",
  "rtm_start" => "https://slack.com/api/rtm.start"
}

res = HTTP.post(URL["rtm_start"],params: {
  token: ENV['SLACK_API_TOKEN']
})

rc = JSON.parse(res.body)

URL["ws"] = rc["url"]

EM.run do
  ws = Faye::WebSocket::Client.new(URL["ws"])

  ws.on :open do
    p [:open]
  end

  ws.on :message do |event|
    anime = AnimeData.new
    data = JSON.parse(event.data)
    p [:message, data]

    if data["text"] == "こんにちは"
      ws.send({
        type: "message",
        text: "こんにちは、<@#{data['user']}>さん",
        channel: data["channel"]
      }.to_json)
    end

    mess = {
      type: "message",
      channel: data["channel"]
    }
    begin
      case data["text"]
      when "今期"
        mess[:text] = anime.now
        ws.send(mess.to_json)
      when "前期"
        mess[:text] = anime.before
        ws.send(mess.to_json)
      when "来期"
        mess[:text] = anime.next
        ws.send(mess.to_json)
      end
    rescue => e
      if e.class == AnimeData::NoDataError
        mess[:text] = "データが存在しないようです・・・。"
        ws.send(mess.to_json)
      else
        mess[:text] = "不明なエラーが発生しました・・・。"
        ws.send(mess.to_json)
      end
    end
  end

  ws.on :close do
    p [:close]
    ws = nil
    EM.stop
  end
  
end
