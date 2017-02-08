require 'json'
require_relative './http_util'
require_relative './import'

def readClips(filename)
  retVal = []
  File.open(filename).each do |line|
    info = line.strip.split(",")
    retVal << [info[0], info[4], info[6]]
  end
  retVal
end

def readProgram(host)
  retVal = {}
  res = HttpUtil.get(host + "/schedule/programs/dump", {})
  JSON.parse(res.body).each do |row|
    retVal[row["code"]] = [row["id"], row["category_id"]]
  end
  retVal
end

def readVideo(host)
  retVal = {}
  res = HttpUtil.get(host + "/schedule/videos/dump", {})
  JSON.parse(res.body).each do |row|
    retVal[row["name"]] = [row["id"], row["status"]]
  end
  retVal
end

def getProgram(name, programs)
  retVal = []
  programs.each do |key, val|
    retVal << key if name.include?(key + "_") || name.include?("_" + key)
  end
  retVal
end

def import(host, programs, videos, clips)
  data = []
  clips.each do |clip|
    name = clip[0]
    val = getProgram(name, programs)
    if val.size != 1
      puts clip.join("\t")
    elsif !videos.include?(name)
      puts clip.join("\t")
    else
      clip[1] =~ /(\d+):(\d{2,}):(\d{2,})/
      data << {
        "program_id" => programs[val[0]][0],
        "episode" => name,
        "category_id" => programs[val[0]][1],
        "duration" => $1.to_i * 3600 + $2.to_i * 60 + $3.to_i,
        "video_id" => videos[name][0],
        "status" => videos[name][1]}
    end
  end
  Import.import(host, "short_clips", data) 
end

clips = readClips(ARGV[1])
programs = readProgram(ARGV[0])
videos = readVideo(ARGV[0])

import(ARGV[0], programs, videos, clips)

