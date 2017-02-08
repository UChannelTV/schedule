class VideosController < AdminController
  def initialize
    super(Video)
  end

  def index
    @status = _isAllStatus?(:video_all_status) ? "all" :
        _getValue(:status, :video_status, "active")
    @limit = _getValue(:limit, :video_limit, 1000)

    query = "videos.id as id, videos.name as name, videos.created_at as created_at, " +
        "videos.status as status, videos.remark as remark, program_episodes.id as program_id, " +
        "short_clips.id as short_clip_id, telvue_id"
    join = "LEFT JOIN program_episodes on videos.id = program_episodes.video_id " +
        "LEFT JOIN short_clips on videos.id = short_clips.video_id"

    if @status == "all"
      @records = Video.select(query).joins(join).order(id: :desc).limit(@limit).collect{|x| convert(x)}
    else
      @records = Video.select(query).joins(join).where(status: @status).order(id: :desc).limit(@limit).collect{|x| convert(x)}
    end
    @statuses = Utility.statuses
  end

  def dump
     if params[:unlinked].to_i > 0
       join = "LEFT JOIN program_episodes on videos.id = program_episodes.video_id " +
           "LEFT JOIN short_clips on videos.id = short_clips.video_id"
       render :json => Video.select("videos.id, videos.name").joins(join).
           where("program_episodes.program_id is null and short_clips.program_id is null")
     elsif params[:program_id].to_i > 0
       join = "JOIN program_episodes on videos.id = program_episodes.video_id"
       render :json => Video.select("videos.id, videos.name, program_id, internal_episode").
           joins(join).where("program_id = #{params[:program_id]}")
     else
       conditions = []
       conditions << "status = '#{params[:status]}'"  if !params[:status].nil?
       if !params[:telvue_id].nil?
         ids = []
         params[:telvue_id].each {|x| ids << x.to_i}
         conditions << "telvue_id in (#{ids.join(",")})"
       end
     
       if conditions.size == 0
         super
       else
         render :json => Video.where(conditions.join(" AND "))
       end
    end
  end

  def sync
    n1 = FinalSchedule.joins("JOIN short_clips on final_schedules.video_id = short_clips.video_id and final_schedules.program_id is null").
        update_all("final_schedules.program_id = short_clips.program_id")
    n2 = FinalSchedule.joins("JOIN program_episodes on final_schedules.video_id = program_episodes.video_id and final_schedules.program_id is null").
        update_all("final_schedules.program_id = program_episodes.program_id, final_schedules.episode = program_episodes.internal_episode ")
    render :json => {"Short Clips" => n1, "Program Episodes" => n2}
  end
end
