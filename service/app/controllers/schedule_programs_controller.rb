class ScheduleProgramsController < AdminController
  def initialize
    super(ScheduleProgram, false)
    @days = Utility.days
    @weekOptions = Utility.weekOptions
  end

  def index
    @channel_id = _getValue(:channel_id, :channel_id, 1)
    @version = _getValue(:version, :schedule_version, 1)
    @day = _getValue(:day, :schedule_day, 0)
   
    query = "schedule_programs.id as id, program_id, week_option, episode_option, " + 
        "hour * 3600 + minute * 60 + second as time, name, expected_duration"
    join = "JOIN programs on schedule_programs.program_id = programs.id "

    @oddWeek, @evenWeek, @weekDiff = [], [], false
    ScheduleProgram.select(query).joins(join).
        where(channel_id: @channel_id, version: @version, day: @day).
        collect{|x| convert(x)}.sort{|a, b| a["time"] <=> b["time"]}.each do |program|
      if program["week_option"] == 0
        @oddWeek << program
        @evenWeek << program
      else
        @weekDiff = true
        if program["week_option"] == 1
          @oddWeek << program
        else
          @evenWeek << program
        end
      end
    end

    verifySchedule(@oddWeek)
    verifySchedule(@evenWeek) if @weekDiff
  end

  def new
    super
    @refresh_action = "new"
    @record["channel_id"] = session[:channel_id]
    @record["version"] = session[:schedule_version]
    @record["day"] = session[:schedule_day]
    @record["week_option"] = 0
    @provider_id = _getValue(:provider_id, :provider_id, 9)
  end

  def show
    super
    getInfo
  end

  def edit
    super
    @refresh_action = "edit"
    @provider_id = (!params[:provider_id].nil?) ? params[:provider_id] :
        ModelHandler.getField(Program, @record["program_id"], "provider_id")
    @provider_id = _getValue(:provider_id, :provider_id, 9) if @provider_id.nil?
    session[:provider_id] = @provider_id
  end

  def create
    @provider_id = _getValue(:provider_id, :provider_id, 9)
    super
  end

  def update
    @provider_id = _getValue(:provider_id, :provider_id, 9)
    super
  end

  def dump
    @channel_id, @version = params[:channel_id], params[:version]
    if @channel_id.nil?
      render json: {"msg" => "Please set channel_id"}, status: 400
    elsif @version.nil?
      render json: {"msg" => "Please set version"}, status: 400
    else
      render json: ScheduleProgram._find(@channel_id, @version, nil), status: 200
    end 
  end

  private
  def verifySchedule(videos)
    end_time = 0
    videos.each do |video|
      gap = video["time"] - end_time
      if gap < 0 || gap > 3600
        video["bg"] = "red"
      elsif gap > 1800
        video["bg"] = "yellow"
      end
      
      end_time = video["time"] + video["expected_duration"] * 60
    end
    gap = 86400 - end_time
    if gap < -600 || gap > 3600
      videos << ({"bg" => "red", "time" => 86399})
    elsif gap < 0 || gap > 1800
      videos << ({"bg" => "yellow", "time" => 86399})
    end
  end

  def getInfo
    @program_name, @provider_id, @provider_name = nil, nil, ""
    begin
      program = Program.find(@record["program_id"])
      @program_name, @provider_id = program["name"], program["provider_id"]
      provider = Provider.find(@provider_id)
      @provider_name = provider["name"]
    rescue ActiveRecord::RecordNotFound
    end
  end
end
