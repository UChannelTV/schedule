module ShortClipTool
  class Selector
    @@min_short, @@max_short, @@max_medium = 5, 20, 60
    @@max_candidates, @@max_trials = 10, 100

    def initialize(short_clips)
      @shorts, @medium, @long = [], [], []
      @@min_short.upto(@@max_short) {|n| @shorts << [] } 
      short_clips.each do |clip|
        if clip["duration"] > @@max_medium
          @long << clip
        elsif clip["duration"] > @@max_short
          @medium << clip
        elsif clip["duration"] >= @@min_short
          @shorts[clip["duration"] - @@min_short] << clip
        end
      end

      @rand = Random.new
    end

    def find(duration)
      alternatives = []
      0.upto(@@max_trials) do |n|
        vids = findOne(duration)
        if vids.size > 0
          alternatives << vids
          break if alternatives.size >= @@max_candidates
        end
      end
      return [] if alternatives.size == 0
      return alternatives[@rand.rand(alternatives.size)]
    end

    def findOne(duration)
      return [] if duration < @@min_short
      selected, retVal = Set.new, []
      
      while duration > @@max_medium
        vid = selectOne(@long, duration, selected)
        return [] if vid.nil?
        
        retVal << vid
        selected << vid["video_id"]
        duration -= vid["duration"]
      end
        
      while duration > @@max_short
        vid = selectOne(@medium, duration, selected)
        return [] if vid.nil?
        
        retVal << vid
        selected << vid["video_id"]
        duration -= vid["duration"]
      end
      
      vids = @shorts[duration - 5]
      retVal << vids[@rand.rand(vids.size)]
      puts retVal.to_json
      return retVal
    end
       
    def selectOne(videos, duration, selected)
      vids = []
      videos.each do |vid|
        next if vid["duration"] > (duration - @@min_short)
        next if selected.include?(vid["video_id"])
        vids << vid
      end
      return nil if vids.size == 0
      return vids[@rand.rand(vids.size)]
    end
  end

  def self.find(short_clips, durations)
    retVal = []
    selector = Selector.new(short_clips)
    durations.each do |dur|
      retVal << selector.find(dur)
    end
    retVal
  end
end
