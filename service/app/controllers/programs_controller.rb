class ProgramsController < AdminController
  def initialize
    super(Program)
  end

  def index
    @provider_id = _isAll?(:provider_id, :all_providers) ? 0 :
        _getValue(:provider_id, :provider_id, 9)
    @category_id = _isAll?(:category_id, :all_categories) ? 0 :
        _getValue(:category_id, :category_id, 1)
    @status = _isAllStatus?(:program_all_status) ? "all" :
        _getValue(:status, :program_status, "active")
    @limit = _getValue(:limit, :program_limit, 1000)

    @records = Program._find(@provider_id, @category_id, @status, @limit).
        collect {|x| convert(x)}
    @categories, @categoryOptions = ModelHandler.idMap(Category, "name", {"全部" => 0})
    @providers, @providerOptions = ModelHandler.idMap(Provider, "name", {"全部" => 0})
    @statuses = Utility.statuses
  end

  def new
    super
    @record["provider_id"] = session[:provider_id]
    @record["category_id"] = session[:category_id]
    @record["language"] = session[:language]
  end

  def create 
    session[:category_id] = params["category_id"]
    session[:provider_id] = params["provider_id"]
    session[:language] = params["language"]
    super
  end

  def update
    session[:category_id] = params["category_id"]
    session[:provider_id] = params["provider_id"]
    session[:language] = params["language"]
    super
  end
end
