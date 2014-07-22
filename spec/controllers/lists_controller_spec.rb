require 'rails_helper'

RSpec.describe ListsController, :type => :controller do

  describe "GET 'segments'" do
    it "returns http success" do
      get 'segments'
      expect(response).to be_success
    end
  end

end
