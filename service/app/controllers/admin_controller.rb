require 'model_handler'

class AdminController < ApplicationController
  def initialize(model, withStatus = true, modelSerializer = nil)
    @model = model
    @modelSerializer = modelSerializer
    @withStatus = withStatus
    super()
  end

  def index(column = :id, order = :desc)
    flash[:notice] = nil
    @limit = params[:limit].to_i
    @limit = 1000 if @limit <= 0
    @records = @model.order(column => order).limit(@limit).collect {|x| convert(x)}
  end

  def new
    flash[:notice] = nil
    @record, @url, @method = convert(@model.new), url_for(action: 'create'), :POST
    @status_list = (@withStatus) ? @model::STATUS_OPTION : nil
  end

  def create
    record, msg, code = ModelHandler.new(@model).create(params)

    flash[:notice] = (msg.nil?) ? nil : msg.to_json
    if code == 201
      @record = convert(record)
      render 'show'
    else
      @record = params.as_json
      @url = url_for(action: 'create')
      @status_list = (@withStatus) ? @model::STATUS_OPTION : nil
      render 'new'
    end
  end

  def show
    record, msg, code = ModelHandler.new(@model).find(params[:id])
    render :file => 'public/400.html', :status => :invalid_request, :layout => false if record.nil?
    
    @record = convert(record)
    flash[:notice] = (msg.nil?) ? nil : msg.to_json
  end

  def edit
    @url, @method = url_for(action: 'update', id: params[:id]), :PUT
    record, msg, code = ModelHandler.new(@model).find(params[:id])
    render :file => 'public/400.html', :status => :invalid_request, :layout => false if record.nil?
    
    @record = convert(record)
    @status_list = (@withStatus) ? @model::STATUS_OPTION : nil
    flash[:notice] = (msg.nil?) ? nil : msg.to_json
  end

  def update
    record, msg, code = ModelHandler.new(@model).update(params[:id], params)
    @record = convert(record)
    flash[:notice] = (msg.nil?) ? nil : msg.to_json

    if code == 200
      render 'show'
    else
      @url = url_for(action: 'update', id: params[:id])
      @status_list = (@withStatus) ? @model::STATUS_OPTION : nil
      @method = :PUT
      render 'edit'
    end
  end

  def destroy
    msg, code = ModelHandler.new(@model).destroy(params[:id])
    flash[:notice] = (msg.nil?) ? nil : msg.to_json
    redirect_to action: 'index'
  end

  def convert(record)
    return nil if record.nil?
    (@modelSerializer.nil?) ? record.as_json : @modelSerializer.new(record).as_json
  end

  def import
    model = ModelHandler.new(@model)
    status, message = [], []
    params[:entities].each do |entity|
      record, msg, code = (entity["id"].nil?) ? model.create(entity) : model.update(entity["id"], entity)
      if code == 201
        message << msg["info"]
      else
        message << msg["error"]
      end
      status << code
    end

    render json: {"status" => status, "message" => message}, statud:200
  end

  def dump
    render :json => @model.order(id: :desc)
  end

  def _isAll?(param_name, session_name)
    retVal = 1
    if params[param_name].nil?
      retVal = session[session_name].to_i if !session[session_name].nil?
    else
      retVal = params[param_name].to_i
    end
    
    session[session_name] = retVal
    return retVal == 0
  end

  def _isAllStatus?(session_name)
    retVal = 1
    if params[:status].nil?
      retVal = session[session_name].to_i if !session[session_name].nil?
    else
      retVal = (params[:status] == "all") ? 0 : 1
    end

    session[session_name] = retVal
    return retVal == 0
  end

  def _getValue(param_name, session_name, default_value)
    retVal = params[param_name]
    retVal = session[session_name] if retVal.nil?
    retVal = default_value if retVal.nil?
    session[session_name] = retVal
    retVal
  end
end
