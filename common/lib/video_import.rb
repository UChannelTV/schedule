require_relative './import'
require_relative './http_util'
require_relative './telvue_parser'
require 'json'
require 'set'

class VideoImport
  def initialize(host)
    @host = host
    @url = host + "/schedule/videos"
    @header = {'Content-Type' => 'application/json'}
  end

  def importTelVueVideos(videos)
    activeVideos = getActiveVideos
    puts "#{activeVideos.size} active videos"

    updateExpired(activeVideos, videos)
    importNew(activeVideos, videos)
  end

  def importScheduledVideo(videos)
    ids = []
    videos.each { |video| ids << video["telvue_id"] }
    res = HttpUtil.post(@url + "/dump", @header, {"telvue_id" => ids}.to_json)
    existingVideos =  {}
    JSON.parse(res.body).each do |v|
      existingVideos[v["telvue_id"]] = v["name"]
    end
   
    newVideos = {}
    videos.each do |video|
      name = existingVideos[video["telvue_id"]]
      if name.nil?
        newVideos[video["telvue_id"]] = {"name" => video["name"], "duration" => video["duration"],
             "telvue_id" => video["telvue_id"], "status" => "expired"}
      else
        if name != video["name"]
          puts "TelVue #{video["telvue_id"]} has multiple names"
          puts video["name"]
        end
      end
    end
    
    puts "#{newVideos.size} videos in schedule missing from videos table"
    Import.import(@host, "videos", newVideos.values.to_a) if newVideos.size > 0
    
    res = HttpUtil.post(@url + "/dump", @header, {"telvue_id" => ids}.to_json)
    existingVideos =  {}
    JSON.parse(res.body).each do |v|
      existingVideos[v["telvue_id"]] = v["id"]
    end
    existingVideos
  end

  def updateExpired(activeVideos, videos)
    vids = Set.new 
    videos.each {|video| vids << video["telvue_id"]}
    
    expiredVideos = []
    activeVideos.each do |video|
      expiredVideos << {"id" => video["id"], "status" => "expired"} if !vids.include?(video["telvue_id"])
    end
    puts "#{expiredVideos.size} expired videos"

    Import.import(@host, "videos", expiredVideos) if expiredVideos.size > 0
  end

  def importNew(activeVideos, videos)
    avids = Set.new
    activeVideos.each {|video| avids << video["telvue_id"]}
    
    newVideos = []
    videos.each do |video|
      newVideos << video if !avids.include?(video["telvue_id"])
    end

    puts "#{newVideos.size} new videos"
    Import.import(@url.gsub("/schedule/videos", ""), "videos", newVideos) if newVideos.size > 0
  end

  def getActiveVideos
    res = HttpUtil.get(@url + "/dump?status=active", @header)
    JSON.parse(res.body)    
  end

  def checkVideos(videos)
    vids = []
    videos.each do |video|
      vids << "telvue_id[]=" + video["telvue_id"].to_s
    end
    return [] if vids.size == 0
    url = @url + "/dump?" + vids.join("&")
    res = HttpUtil.get(url, @header)
    JSON.parse(res.body)
  end
end

