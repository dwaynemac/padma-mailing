require 'typhoeus_fix/array_decoder'

class Api::V0::ApiController < ActionController::Base

  protect_from_forgery

  include TyphoeusFix
  before_filter :decode_typhoeus_arrays

  APP_KEY = ENV['app_key']

  before_filter :require_app_key

  private

  def require_app_key
    unless params[:app_key] == APP_KEY
      render :plain => "wrong app key", :status => 401
    end
  end

end