require_relative './http_util'
require_relative './import'
require_relative './video_import'
require_relative './telvue_parser'
require 'hpricot'

class FinalScheduleImporter
  def initialize(host)
    @host = host
    @vi = VideoImport.new(host)
  end

  def import(channel_id, date)
    puts date
    videos = TelVueParser.new.getSchedule(channel_id, Date.parse(date))
    vids = @vi.importScheduledVideo(videos)

    videos.each do |video|
      video.delete("name")
      video["video_id"] = vids[video["telvue_id"]]
    end

    header = {'Content-Type' => 'application/json'}
    res = HttpUtil.post(@host + "/schedule/final_schedules/import", header,
        {"entities" => videos, "day" => date}.to_json)

    puts res.body
    puts "Import scheduled videos on #{date}"
  end

  def readCsv(filename, channel_id, date)
    data = []
    count = 0
    File.open(filename).each do |line|
      count += 1
      next if count <= 1
      info = line.strip.split(",")
      t = getTime(info[2])
      data << {
        "channel_id" => channel_id, "date" => date,
        "hour" => t[0], "minute" => t[1], "second" => t[2],
        "telvue_id" => info[4].to_i, "name" => info[5],
        "time" => t[0] * 3600 + t[1] * 60 + t[2]}
    end
    sortVideos(data)
  end

  def readHtml(filename, channel_id, date)
    f = File.open(filename)
    body = f.read
    f.close
    
    sortVideos(TelVueParser.new.getScheduleVideo(body, channel_id, date)) 
  end

  def sortVideos(videos)
    videos = videos.sort{|a, b| a["time"] <=> b["time"]}
    nLen = videos.length
    0.upto(nLen - 2) do |n|
      videos[n]["duration"] = videos[n+1]["time"] - videos[n]["time"]
    end
    videos[nLen - 1]["duration"] = 86400 - videos[nLen - 1]["time"]
    videos
  end

  def getTime(date)
    date =~ /(\d+):(\d+):(\d+)/
    [$1.to_i, $2.to_i, $3.to_i]
  end 
end
