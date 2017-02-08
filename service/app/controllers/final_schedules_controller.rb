class FinalSchedulesController < AdminController
  def initialize
    super(FinalSchedule, false)
  end

  def index
    @channel_id = _getValue(:channel_id, :channel_id, 1)
    date = _getValue(:schedule_date, :schedule_date, "2017-02-01")
    @date = Time.parse(date)

    query = "final_schedules.id, hour * 3600 + minute * 60 + second as time, " +
        "video_id, program_id, final_schedules.remark, episode, programs.name as program, " + 
        "videos.name as video_name, duration"
    join = "LEFT JOIN programs on programs.id = final_schedules.program_id " +
        "JOIN videos on final_schedules.video_id = videos.id"

    @records = FinalSchedule.select(query).joins(join).
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

    @videos = {}
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
     
    @videos = {}
    ShortClip.where(program_id: @record["program_id"]).each do |v|
      @videos[v["episode"].to_s] = v["video_id"]
    end
    ProgramEpisode.where(program_id: @record["program_id"]).each do |v|
      @videos[v["episode"].to_s + " " + v["internal_episode"].to_s] = v["video_id"]
    end    
  end

  def import
    day = params[:day]
    start_hour = params[:start_hour]
    start_hour = 0 if start_hour.nil?
    end_hour = params[:end_hour]
    end_hour = 23 if end_hour.nil?
    FinalSchedule.delete_all("date = '#{day}' and hour >= #{start_hour} and hour <= #{end_hour}") 
    super
  end
end
