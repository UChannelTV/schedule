require 'json'
require 'set'
require_relative './http_util'
require_relative './import'

class VideoProgram
  def initialize(host)
    @host = host
    @header = {'Content-Type' => 'application/json'}
    readProgram
  end

  def popEpisodes
    unlinked = getUnlinked
    unlinked.each do |key, val|
      next if key == "0"
      
      program_id = @programs[key][0]
      episodes = getEpisodes(program_id, val)
      episodes = sortEpisodes(episodes)
      0.upto(4) do |n|
        step = 5 - n
        if setEpisodeNumber(episodes, step)    
          episodes.each do |episode|
            puts episode.to_json
          end
          break
        end
      end

      import(episodes, program_id)
    end

    unlinked["0"].each do |video|
      puts "No program for " + video.to_json
    end
    res = HttpUtil.get(@host + "/schedule/videos/sync", @header)    
    puts res.body
  end

  def getEpisodes(program_id, new_episodes)
    episodes = []
    new_episodes.each do |episode|
      episodes << {"name" => episode["name"], "id" => episode["id"]}
    end
    getProgramEpisodes(program_id).each do |v|
      episodes << v
    end
    episodes
  end

  def sortEpisodes(episodes)
    v1, v2 = [], []
    episodes.each do |v|
      if v["name"] =~ /^201/
        v2 << v
      else
        v1 << v
      end
    end

    retVal = []
    v1.sort{|a, b| a["name"] <=> b["name"] }.each do |v|
      retVal << v
    end
    v2.sort{|a, b| a["name"] <=> b["name"] }.each do |v|
      retVal << v
    end
    
    retVal
  end

  def setEpisodeNumber(episodes, step)
    nextNumber = nil
    index = episodes.size - 1
    while (index >= 0)
      episode = episodes[index]
      if episode["program_id"].nil?
        if nextNumber.nil?
          episode["internal_episode"] = (index + 1) * 10
        else
          nextNumber -= step
          return false if nextNumber <= 0
          episode["internal_episode"] = nextNumber
        end
      else
        if nextNumber.nil?
          nextNumber = episode["internal_episode"]
        else
          return false if nextNumber <= episode["internal_episode"]
          nextNumber = episode["internal_episode"]
        end
      end
      index -= 1
    end

    true
  end

  def import(episodes, program_id)
    data = []
    episodes.each do |x|
      data << {"program_id" => program_id, "episode" => x["name"], "status" => "active",
        "internal_episode" => x["internal_episode"], "video_id" => x["id"]} if x["program_id"].nil?
    end
    data.each do |video|
      puts "Import " + video.to_json
    end
    res = Import.import(@host, "program_episodes", data)
    puts res.body
  end

  def getUnlinked
    episodes = {}
    JSON.parse(HttpUtil.get(@host + "/schedule/videos/dump?unlinked=1", @header).body).each do |video|
      code = getProgram(video["name"])
      episodes[code] = [] if episodes[code].nil?
      episodes[code] << video
    end
    episodes 
  end

  def readProgram
    @programs = {}
    res = HttpUtil.get(@host + "/schedule/programs/dump", @header)
    JSON.parse(res.body).each do |row|
      @programs[row["code"]] = [row["id"], row["category_id"]]
    end
  end

  def getProgram(name)
    retVal = []
    @programs.each do |key, val|
      retVal << key if name.include?(key + "_") || name.include?("_" + key)
    end
    return "0" if retVal.size == 0
    if retVal.size > 1
      puts name + "\t" + retVal.join(",") + " choose first as the program"
      return retVal[0]
    end
    return retVal[0]
  end

  def getProgramEpisodes(program_id)
    episodes = []
    JSON.parse(HttpUtil.get(@host + "/schedule/videos/dump?program_id=#{program_id}", @header).body).each do |video|
      episodes << [video["name"], video["id"], video["internal_episode"]]
    end
  end
end


