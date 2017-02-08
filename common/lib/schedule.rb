require 'set'
require_relative './dump'
require_relative './import'

class ProgramId
  def initialize(host)
    @nameMap, @codeMap = Dump.nameCodeProgramId(host)
  end

  def isLive(name)
    return name.include?("直 播")
  end

  def getId(name)
    isLive = isLive(name)
    name = name.gsub("直 播", "")
    retVal = checkId(name)
    return [isLive, retVal] if !retVal.nil?

    name = name.gsub(" ", "")
    retVal = checkId(name)
    return [isLive, retVal] if !retVal.nil?

    if name.length >3
      return [isLive, checkId(name[0..2])]
    end
    return [isLive, retVal]
  end

  def checkId(name)
    retVal = @nameMap[name]
    retVal = @codeMap[name] if retVal.nil?
    return retVal
  end
end

def readProgram(file, skipLines)
  time, programs = [], []
  File.open(file).each do |line|
    if skipLines > 0
      skipLines -= 1
      next
    end
    
    info = line.split("\t")
    time << info[0]
    programs << [info[2].strip, info[5].strip, info[7].strip,
        info[9].strip, info[11].strip, info[13].strip, info[16].strip] 
  end

  [time, programs]
end

def readData(program_tool, channel_id, version, file, skipLines)
  time, programs = readProgram(file, skipLines)
  tp = []
  0.upto(6) do |day|
    pid = nil
    0.upto(time.length - 1) do |n|
      cisLive, cpid = program_tool.getId(programs[n][day].to_s)
      if !cpid.nil? && cpid != pid
        time[n] =~ /(\d{1,2}):(\d{2,}):(\d{2,})/
        hour, min, sec = $1.to_i, $2.to_i, $3.to_i
      	tp << {"channel_id" => channel_id,
               "version" => version,
               "program_id" => cpid,
               "week_option" => 0,
               "day" => day,
               "hour" => hour,
               "minute" => min,
               "second" => sec}
        pid = cpid
      end
    end
  end
  return tp
end

def readExistingData(host, channel_id, version, week_option)
  res = HttpUtil.get(host + "/schedule/schedule_programs/dump?channel_id=#{channel_id}&version=#{version}", {})
  retVal = {}
  JSON.parse(res.body).each do |record|
    next if ![0, week_option].include?(record["week_option"])
    key = "%02d:%02d:%02d" % [record["hour"], record["minute"], record["second"]]
    day = record["day"].to_s
    retVal[day + " " + key] = record["program_id"]
  end

  retVal
end

def compare(existingData, data)
  data.each do |record|
    key = "%02d:%02d:%02d" % [record["hour"], record["minute"], record["second"]]
    day = record["day"].to_s
    next if record["program_id"].to_i == existingData[day + " " + key].to_i
    puts day + " " + key + " " + record["program_id"].to_s + " " + existingData[day + " " + key].to_s
  end 
end

existingData = readExistingData(ARGV[0], 1, 1, 1)
pid = ProgramId.new(ARGV[0])
data = readData(pid, 1, 1, "29-04.tsv", 2)
compare(existingData, data)

#Import.import(ARGV[0], "schedule_programs", data)

#["01-07.tsv", "08-14.tsv", "15-21.tsv", "22-28.tsv", "29-04.tsv", "05-11.tsv", "12-18.tsv", "19-25.tsv", "26-04.tsv"].each do |file|






