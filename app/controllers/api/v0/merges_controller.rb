require 'merge'

class Api::V0::MergesController < Api::V0::ApiController

  respond_to :json

  # @url [POST] /api/v0/merges
  # @argument merge [Hash]
  # @key_for merge [String] son_id
  # @key_for merge [String] parent_id
  # @example_response 'OK' -- status: 201
  # @response_code 201
  def create
    son_id = params[:merge]['son_id']
    parent_id = params[:merge]['parent_id']

    m = Merge.new(son_id, parent_id)
    m.merge

    render json: "OK", status: 201
  end

end
