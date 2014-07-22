class ListsController < ApplicationController
  before_filter :get_mailchimp
  before_filter :get_primary_list
  
  def segments
  end
  
  def update
    segment_count(params['query']).times do |index|
      query = Hash.new()
      set_query_status(query, params['status_' + index.to_s]) 
      set_query_gender(query, params['gender_' + index.to_s])
      set_query_coefficient(query, params['query']['coefficient_' + index.to_s])
      Segment.create(
        query: query,
        list_id: @primary_list.id,
        name: get_name(params['query'], index)
      )
    end
    
    render text: "OK"
  end

  private
  
  def set_query_gender (query, gender_hash)
    if gender_hash['only_man'] == '1'
      query['gender'] = true
    else
      query['gender'] = false
    end
  end
  
  def get_name (query_hash, index)
    query_hash['name_' + index.to_s]
  end

  def set_query_coefficient (query, coefficient)
    query['coefficient'] = coefficient 
  end
  
  def set_query_status (query, status_hash)
    a = []
    status_hash.each do |k, v|
      if v == "1"
        a.push(k)
      end
    end 
    query['status'] = a
  end
  
  def segment_count (query_hash)
    query_hash['count'].to_i
  end

  def get_mailchimp
    @mailchimp = current_user.current_account.mailchimp
  end
  
  def get_primary_list
    @primary_list = @mailchimp.primary_list
  end
end
