class ScheduleProgramEpisodesController < AdminController
  def initialize
    super(ScheduleProgramEpisode, false)
  end

  def index
    @channel_id = _getValue(:channel_id, :channel_id, 1)
    date = _getValue(:schedule_date, :schedule_date, "2017-02-01")
    @date = Time.parse(date)

    query = "schedule_program_episodes.id, hour * 3600 + minute * 60 + second as time, " +
        "video_id, program_id, schedule_program_episodes.remark, schedule_program_episodes.episode, " +
        "programs.name as program, videos.name as video_name, " +
        "if (videos.id is null, schedule_program_episodes.expected_duration, duration) as duration"
    join = "LEFT JOIN programs on programs.id = schedule_program_episodes.program_id " +
        "LEFT JOIN videos on schedule_program_episodes.video_id = videos.id"

    @manual_records = ScheduleProgramEpisode.select(query).joins(join).
        where(channel_id: @channel_id, date: date).collect{|x| convert(x)}.sort{|a, b| a["time"] <=> b["time"]}
    
    if !params[:generate].nil?
      generate(date)
    end
    
    query = "generated_episode_schedules.id, hour * 3600 + minute * 60 + second as time, " +
        "video_id, program_id, generated_episode_schedules.remark, generated_episode_schedules.episode, " +
        "programs.name as program, videos.name as video_name, generated_episode_schedules.duration"
    join = "LEFT JOIN programs on programs.id = generated_episode_schedules.program_id " +
        "LEFT JOIN videos on generated_episode_schedules.video_id = videos.id"

    @auto_records = GeneratedEpisodeSchedule.select(query).joins(join).
        where(channel_id: @channel_id, date: date).collect{|x| convert(x)}.sort{|a, b| a["time"] <=> b["time"]}
  end

  def new
    super
    @refresh_action = "new"
    @record["channel_id"] = session[:channel_id]
    @record["date"] = session[:schedule_date]
    @provider_id = _getValue(:provider_id, :provider_id, 9)

    @programs = Program.where(provider_id: @provider_id)
    program_id = @programs[0]["id"]

    pids = Set.new
    @programs.each do |program|
      pids << program["id"]
    end

    session_key = @provider_id.to_s + "_program"
    pid = session[session_key].to_i
    program_id = pid if pids.include?(pid)

    pid = params[:program_id].to_i
    if pids.include?(pid)
      program_id = pid
      session[session_key] = pid
    end
    @record["program_id"] = program_id

    @videos = {"無" => -1}
    ShortClip.where(program_id: @record["program_id"]).each do |v|
      @videos[v["episode"].to_s] = v["video_id"]
    end
    ProgramEpisode.where(program_id: @record["program_id"]).each do |v|
      @videos[v["episode"].to_s + " " + v["internal_episode"].to_s] = v["video_id"]
    end
  end

  def edit
    super
    @refresh_action = "edit"

    session[:channel_id] = @record["channel_id"]
    session[:schedule_date] = @record["date"]

    @provider_id = (!params[:provider_id].nil?) ? params[:provider_id] :
        ModelHandler.getField(Program, @record["program_id"], "provider_id")
    @provider_id = _getValue(:provider_id, :provider_id, 9) if @provider_id.nil?
    @programs = Program.where(provider_id: @provider_id)
    program_id = @programs[0]["id"]

    pids = Set.new
    @programs.each do |program|
      pids << program["id"]
    end

    session_key = @provider_id.to_s + "_program"
    pid = session[session_key].to_i
    program_id = pid if pids.include?(pid)

    pid = @record["program_id"].to_i
    if pids.include?(pid)
      program_id = pid
      session[session_key] = pid
    end

    pid = params[:program_id].to_i
    if pids.include?(pid)
      program_id = pid
      session[session_key] = pid
    end
    @record["program_id"] = program_id

    @videos = {"無" => -1}
    ShortClip.where(program_id: @record["program_id"]).each do |v|
      @videos[v["episode"].to_s] = v["video_id"]
    end
    ProgramEpisode.where(program_id: @record["program_id"]).each do |v|
      @videos[v["episode"].to_s + " " + v["internal_episode"].to_s] = v["video_id"]
    end
  end

  private
  def generate(date)
    GeneratedEpisodeSchedule.delete_all("date = '#{date}' and channel_id = #{@channel_id}")

    version = ChannelScheduleVersion.get_version(@channel_id, date)
    return if version.nil?
   
    wday, week_opt = Utility.scheduleOptions(date)
    programs = ScheduleProgram.where("channel_id = #{@channel_id} and version = #{version} " +
        "and day = #{wday} and week_option in (0, #{2 - week_opt})").collect{|x| convert(x)}
    
    pe = {}
    programs.each do |program|
      program_id = program["program_id"]
      pe[program_id] = 0 if pe[program_id].nil?
      pe[program_id] = program["episode_option"] if program["episode_option"] > pe[program_id]
    end

    program_episodes = {}
    pe.each do |key, val|
      program_episodes[key] = ScheduleProgramEpisode.nextEpisodes(date, key, val).collect{|x| convert(x)}
    end

    @manual_records.each do |program|
      record = {"channel_id" => @channel_id, "date" => date, "program_id" => program["program_id"],
        "episode" => program["episode"], "video_id" => program["video_id"], "hour" => program["time"] / 3600,
        "minute" => program["time"] / 60 % 60, "second" => program["time"] % 60, "duration" => program["duration"]}
      ModelHandler.new(GeneratedEpisodeSchedule).internal_create(record)
    end

    programs.each do |program|
      ep = program["episode_option"]
      episodes = program_episodes[program["program_id"]]
      puts episodes.to_json
      next if episodes.size == 0
      episode = (ep < episodes.size) ? episodes[ep] : episodes.last
      time = program["hour"] * 3600 + program["minute"] * 60 + program["second"]      
      if !is_conflict(time, episode["duration"])
        record = {"channel_id" => @channel_id, "date" => date, "program_id" => program["program_id"],
          "episode" => episode["internal_episode"], "video_id" => episode["video_id"],
          "hour" => program["hour"], "minute" => program["minute"], "second" => program["second"],
          "duration" => episode["duration"]}
        ModelHandler.new(GeneratedEpisodeSchedule).internal_create(record)
      end
    end
  end

  def is_conflict(time, duration)
    @manual_records.each do |record|
      st = record["time"]
      et = st + record["duration"]
      return false if st >= (time + duration) || et <= time
    end
    true
  end
end
