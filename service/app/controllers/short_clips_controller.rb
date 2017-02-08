class ShortClipsController < AdminController
  def initialize
    super(ShortClip)
    @statuses = Utility.statuses
  end

  def index
    @provider_id = _isAll?(:provider_id, :all_providers) ? 0 :
        _getValue(:provider_id, :provider_id, 9)
    @category_id = _isAll?(:category_id, :all_categories) ? 0 :
        _getValue(:category_id, :category_id, 1)
    @status = _isAllStatus?(:short_clip_all_status) ? "all" :
        _getValue(:status, :short_clip_status, "active")
    @limit = _getValue(:limit, :short_clip_limit, 1000)

    query = "short_clips.id as id, program_id, episode, video_id, is_special, " + 
        "short_clips.duration as duration, short_clips.status as status, " +
        "short_clips.remark as remark, programs.category_id as category_id, " +
        "programs.name as program, provider_id, videos.name as video"
    join = "LEFT JOIN programs on short_clips.program_id = programs.id " +
        "LEFT JOIN videos on short_clips.video_id = videos.id"

    conditions = []
    conditions << "provider_id = #{@provider_id}" if @provider_id.to_i > 0
    conditions << "programs.category_id = #{@category_id}" if @category_id.to_i > 0
    conditions << "short_clips.status = '#{@status}'" if @status != "all"

    if conditions.size == 0 
      @records = ShortClip.select(query).joins(join).order(id: :desc).limit(@limit)
    else
      @records = ShortClip.select(query).joins(join).where(conditions.join(" AND ")).order(id: :desc).limit(@limit)
    end

    @categories, @categoryOptions = ModelHandler.idMap(Category, "name", {"全部" => 0})
    @providers, @providerOptions = ModelHandler.idMap(Provider, "name", {"全部" => 0})
    @statuses = Utility.statuses
  end 

  def new
    video, msg, code = ModelHandler.new(Video).find(params[:video_id].to_i)
    render :file => 'public/400.html', :status => :invalid_request, :layout => false if video.nil?
    super
    session[:video_id] = video["id"] 
    @record["video_id"] = video["id"]
    @record["video"] = video["name"]
    @record["duration"] = video["duration"]
    
    @refresh_action = "new"
    @provider_id = _getValue(:provider_id, :provider_id, 9)
    puts @provider_id
  end

  def edit
    super
    video = ModelHandler.new(Video).find(@record["video_id"])[0]
    @record["video"] = video["name"] if !video.nil?
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
end
