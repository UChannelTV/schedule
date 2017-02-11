require 'hpricot'
require_relative 'import'
require_relative './http_util'

class TelVueParser
  @@content_url = "http://192.168.2.22/all_content_metadata"
  @@schedule_url = "http://192.168.2.22/xml/program_schedule_feed?channel_id="
  def getContent
    url = @@content_url + "?api_key=" + ENV.to_h["TELVUE_KEY"]
    body = HttpUtil.get(url, {}).body
    getContentVideos(body)
  end 

  def getContentVideos(body)
    doc = Hpricot.parse(body)
 
    videos, telvue_ids = [], []
    doc.search("//content-file").each do |elem|
      video = {"is_short_clip" => false, "status" => "active"}
      elem.search("//id").each {|item|
        video["telvue_id"] = item.inner_text.to_i
        break
      }
      elem.search("//duration").each {|item| video["duration"] = item.inner_text.to_i}
      elem.search("//created-at").each {|item| video["created_at"] = item.inner_text}
      elem.search("//name").each {|item| video["name"] = item.inner_text}
      elem.search("//categories/category/name").each do |item|
        video["is_short_clip"] = true if item.inner_text == "ShortClip"
      end
       
      telvue_ids << video["telvue_id"] if video["is_short_clip"]
      videos << video
    end
    puts telvue_ids.join(",")
    videos
  end

  def getSchedule(channel_id, date)
    startDay = dateString(date)
    endDay = dateString(date + 1)
    url = @@schedule_url + channel_id.to_s + "&start=#{startDay}&end=#{endDay}&api_key=" + ENV.to_h["TELVUE_KEY"]
    puts url

    body = HttpUtil.get(url, {}).body
    getScheduledVideos(channel_id, date, body)
  end 

  def getScheduledVideos(channel_id, date, body)
    doc = Hpricot.parse(body)
    schedules = []
    doc.search("//rss/channel/item").each do |elem|
      video = {"telvue_id" => 1, "channel_id" => channel_id, "date" => date}
      schedules << video
      
      elem.search("//title").each {|item| video["name"] = item.inner_text}
      elem.search("//pubdate").each {|item| 
        pub_date = DateTime.parse(item.inner_text)
        video["hour"], video["minute"], video["second"] = pub_date.hour, pub_date.minute, pub_date.second
      }
      elem.search("//psg:duration").each {|item| video["duration"] = item.inner_text.to_i}
      elem.search("//psg:thumbnail").each {|item| 
        video["telvue_id"] = $1.to_i if (item.inner_text =~ /thumbnails\/(\d+)\.jpg/)
      }
    end
    return schedules
  end

  def dateString(date)
    "%4d%02d%02d" % [date.year, date.month, date.day]
  end
end

