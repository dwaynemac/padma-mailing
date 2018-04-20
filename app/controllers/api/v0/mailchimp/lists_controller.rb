class Api::V0::Mailchimp::ListsController < Api::V0::ApiController
  before_filter :require_app_key, :except => :webhooks
 
 def webhooks
  list = Mailchimp::List.find(params[:id])
  list.create_activity(params)
  
  render json: {status: "ok"}.to_json, status: 200 
 end
end
