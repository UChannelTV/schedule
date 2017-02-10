module Utility
  def self.weekOptions
    {"單周" => 1, "雙周" => 2, "每周" => 0}
  end

  def self.weekOption(index)
    ["每周", "單周", "雙周"][index]
  end

  def self.days
    {"Sunday" => 0, "Monday" => 1, "Tuesday" => 2, "Wednesday" => 3,
        "Thursday" => 4, "Friday" => 5, "Saturday" => 6}
  end

  def self.day(index)
    ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"][index]
  end
  
  def self.statuses
    ["all", "active", "expired"]
  end

  def self.durationStr(duration)
    "%02d:%02d:%02d" % [duration.to_i / 3600, duration.to_i / 60 % 60, duration.to_i % 60]
  end

  def self.scheduleOptions(dateStr)
    date = Date.parse(dateStr)
    [date.wday, date.cweek % 2]
  end

  def self.verifySchedule(scheduled)
    st, retVal = 0, []
    scheduled.each do |item|
      origin = item["origin"].to_i
      if origin == 0
        item["color"] = "green"
      elsif origin == 1
        item["color"] = "blue"
      end
      if item["time"] > st
        retVal << {"color" => "yellow", "time" => st, "program" => "Missing", "duration" => item["time"] - st} 
      elsif item["time"] < st
        retVal << {"color" => "red", "time" => item["time"], "program" => "Overlap", "duration" => st - item["time"]}
      end
      retVal << item
      st = item["time"] + item["duration"].to_i
    end
    
    if st < 86400
      retVal << {"bg" => "yellow", "time" => st, "program" => "Missing", "duration" => 86400 - st}
    elsif st > 86400
      retVal << {"bg" => "red", "time" => 86400, "program" => "Overlap", "duration" => st - 86400}
    end
    retVal
  end
end    
