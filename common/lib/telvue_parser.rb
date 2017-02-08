require 'hpricot'
require_relative 'import'

class TelVueParser
  def getContentFromFiles(files)
    videos = []
    files.each do |file|
      tv, nv = getContentVideos(readBody(file))
      videos |= tv
    end
    videos  
  end

  def readBody(file)
    f = File.open(file)
    body = f.read
    f.close
    body
  end

  def getContentVideos(body)
    doc = Hpricot.parse(body)
  
    txt = doc.search("//div[@class='pagination-text']")[0].inner_text
    txt=~/\d+ of (\d+)/
    numVideos = $1.to_i

    videos = []
    content = doc.search("//table[@class='contentResultsList inner-content-results']/tbody/tr")
    content.each do |elem|
      info = elem.search("//td")
      next if info.size < 5
      vid = (info[0]/:a)
      next if (vid).first["title"].nil?
      (vid).first["rel"] =~ /content\/tooltip\/(\d+)/ 
      videos << convertVideo([(vid).first["title"].strip, info[4].inner_text.strip, info[7].inner_text.strip, $1.to_i])
    end
    [videos, numVideos]
  end
  
  def convertVideo(video)
    video[1] =~ /(\d{2,}):(\d{2,}):(\d{2,})/
    dur = $1.to_i * 3600 + $2.to_i * 60 + $3.to_i
    video[2] =~ /(\d{2,}).(\d{2,}).(\d{4,}) (\d+:\d+:\d+)/
    time = $3 + "-" + $1 + "-" + $2 + " " + $4
    {"name" => video[0], "duration" => dur, "status" => "active", "created_at" => time, "telvue_id" => video[3]}
  end

  def getScheduleVideo(body, channel_id, date)
    data = []
    doc = Hpricot.parse(body)
    doc.search("//div[@id='results']/table[@class='bigtable']/tbody/tr").each do |elem|
      tds = elem.search("//td")
      next if tds.size < 9
      t = getTime(tds[6].inner_text)

      telvue_id = 1
      title = tds[8].inner_text
      vid = (tds[8]/:a)
      if !(vid).first.nil?
        telvue_id = 0
        (vid).first["rel"] =~ /content\/tooltip\/(\d+)/
        telvue_id = $1.to_i
        if telvue_id == 0
          (vid).first["rel"] =~ /schedule\/.*\/tooltip_info\/(\d+)/
          telvue_id = $1.to_i
        end
        title = (vid).first["title"].strip
      end

      data << {
        "channel_id" => channel_id, "date" => date,
        "hour" => t[0], "minute" => t[1], "second" => t[2],
        "telvue_id" => telvue_id, "name" => title,
        "time" => t[0] * 3600 + t[1] * 60 + t[2]}
    end
    data
  end

  def getTime(date)
    date =~ /(\d+):(\d+):(\d+)/
    [$1.to_i, $2.to_i, $3.to_i]
  end
end

