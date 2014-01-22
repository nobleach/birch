require 'csv'

class RequestsController < ApplicationController

  before_filter :confirm_logged_in,
    :except => [:index, :list, :show, :requested, :sort_by_status]

  require 'net/http'

  # caches_page :index
  # caches_action :index
  # caches_page :list
  # caches_action :list

  def index

  end

  def list
    current_year = Time.now.year.to_i
    @requests_scope = Request.scoped
    unless params['year'].present?
      @requests = @requests_scope.where("requested_date BETWEEN ? AND ?", "#{current_year}-01-01", "#{current_year}-12-31")
    else
      @requests = @requests_scope.where("requested_date BETWEEN ? AND ?", "#{params['year']}-01-01", "#{params['year']}-12-31")
    end

    unless params['status'].nil?
      @requests = @requests.where("status = ?", params['status']) if params['status'] != 'all'
    end

    respond_to  do |format|
      format.html
      format.csv do
        export(@requests) #method is defined in lib/export.rb
      end
      format.json do
        render :json => @requests
      end
    end
  end

  def show
    @request = Request.find(params[:id])
  end

  def requested
    @requests = Request.select(:incident_name).select(:incident_id).select(:lat).select(:lng).select(:status).where(:status => 'Requested')
    render :json => @requests
  end

  def new
    @request = Request.new
    unless params['incident_id'].nil?
      @existing_request = Request.where("incident_id = ?", params['incident_id'])
      unless @existing_request.empty?
        flash[:notice] = "<strong>Warning: </strong>This incident has already been requested. You may still request it.".html_safe
      end
      #code to query JSON endpoint for values THIS NEEDS TO BE REFACTORED INTO A METHOD!!!
      url_string = "http://svinetfc6.fs.fed.us/rsacfod/fires/get_incident/#{params['incident_id']}.json"
      url = URI.parse(url_string)

      response = Net::HTTP.get_response(url)
      unless response.body == 'false' or response.body == 'null'
        json = ActiveSupport::JSON.decode(response.body)
        logger.debug "!!!!!!!!!!!!!!!!!!!!from the ETD !!!!!!!!!!!!!!!!!!!!!!: #{response.body}\n FROM #{url_string}"
        @request.incident_name = json['incident_name']
        @request.incident_id = json['incident_id']
        @request.forest_name = json['ig_usfs_region']
        @request.acres = json['area_burned']
        @request.ignition_date = json['ig_date']
        @request.percent_contained = json['percent_contained']
        @request.expected_containment_date = json['expected_containment_date']
        @request.lat = json['ig_lat']
        @request.lng = json['ig_long']
        @request.status = json['baer_status']
      else
        url = URI.parse("http://activefiremaps.fs.fed.us/m/get_fire.php?incident_id=#{params['incident_id']}")
        response = Net::HTTP.get_response(url)
        clean_response = response.body.gsub(/[()]/, "")
        json = ActiveSupport::JSON.decode(clean_response)
        @request.incident_name = json['incident_name']
        @request.incident_id = json['incident_id']
        @request.acres = json['area_burned']
        @request.ignition_date = json['ig_date']
        @request.percent_contained = json['percent_contained']
        @request.expected_containment_date = json['expected_containment_date']
        @request.lat = json['ig_lat']
        @request.lng = json['ig_long']
      end
    end
    unless session[:username] == 'admin'
      @request.username = session[:username]
      @request.requestor_name = session[:fullname]
      @request.requestor_email = session[:email]
      @request.requestor_phone = session[:phone]
    end
  end

  def create
    @request = Request.new(params[:request])
    @request.requested_date = Time.now.strftime("%Y-%m-%d")
    unless @request.status == 'Processing'
      # @brafta_url = URI.parse('http://svinetfc6.fs.fed.us/brafta/save_incident.php')
      # @brafta_response = Net::HTTP.post_form(@brafta_url,{'incident_id' => @request.incident_id, 'baer_status' => @request.status})
      # let's take care of the coordinates if they're not in decimal degrees:
      # if params[:request]['lat'].to_s.include?('d')
      #    params[:request]['lat'] = Request.convert_to_decimal_degrees(params[:request]['lat'].to_s)
      # end
      # if params[:request]['lng'].to_s.include?('d')
      #    params[:request]['lng'] = Request.convert_to_decimal_degrees(params[:request]['lng'].to_s)
      # end
    end
    @request.status = 'Requested'
    # flash[:notice] = @brafta_response.body.html_safe
    if @request.save
      # expire_page :action => 'list'
      RequestConfirmation::send_confirmation(@request).deliver
      RequestVtexts::send_confirmation(@request).deliver
      redirect_to(:controller => 'requests', :action => 'list')
      flash[:notice] = "Your Request has been saved."
    else
      render('new')
      flash[:error] = "Your request could NOT be added"
    end
  end

  def edit
    @request = Request.find(params[:id])
    unless @request.username == session[:username] or session[:username] == 'admin'
      redirect_to(:controller => 'requests', :action => 'list')
      flash[:error] = "<strong>Error: </strong>You may not edit requests that you didn't make".html_safe
    end
  end

  def update
    @request = Request.find(params[:id])
    # if params[:request]['status'] == 'Complete'
    #   MailCompleted::completed_request(@request).deliver
    # end
    if @request.update_attributes(params[:request])
      # expire_page :action => 'list'
      #send mail if request completed
      redirect_to(:controller => 'requests', :action => 'list')
      flash[:notice] = "Request Updated"
    else
      render('edit')
    end
  end

  def delete
    @request = Request.find(params[:id])
    #pass some info about request into a partial which will be loaded via jQuery
    render(:partial => 'common/requestconfirmation' )
  end

  def destroy
    Request.find(params[:id]).destroy
    @requests = Request.all
    # expire_page :action => 'list'
    redirect_to(:controller => 'requests', :action => 'list')
  end

  def brafta_update
    # @request = Request.find(params[:id])
    # @brafta_url = URI.parse('http://svinetfc6.fs.fed.us/brafta/save_incident.php')
    # # @brafta_response = Net::HTTP.post_form(@brafta_url,{'incident_id' => @request.incident_id, 'baer_status' => @request.status})
    # @brafta_response = Net::HTTP.post_form(@brafta_url,{
    #   'incident_id' => @request.incident_id,
    #   'incident_name' => @request.incident_name,
    #   'ignition_date' => @request.ignition_date,
    #   'forest_name' => @request.forest_name,
    #   'lat' => @request.lat,
    #   'lng' => @request.lng,
    #   'acres' => @request.acres,
    #   'percent_contained' => @request.percent_contained,
    #   'expected_containment_date' => @request.expected_containment_date,
    #   'requestor_name' => @request.requestor_name,
    #   'requestor_email' => @request.requestor_email,
    #   'requestor_phone' => @request.requestor_phone,
    #   'status' => @request.status
    #   })
    # logger.info "BRAFTA says: " + @brafta_response.body
    # @requests = Request.all
    # redirect_to(:controller => 'requests', :action => 'list')
    # flash[:notice] = "BRAFTA Information has been Updated."
  end

end