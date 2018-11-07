require "rails_helper"

RSpec.describe HeartbeatsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/heartbeats").to route_to("heartbeats#index")
    end


    it "routes to #show" do
      expect(:get => "/heartbeats/1").to route_to("heartbeats#show", :id => "1")
    end


    it "routes to #create" do
      expect(:post => "/heartbeats").to route_to("heartbeats#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/heartbeats/1").to route_to("heartbeats#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/heartbeats/1").to route_to("heartbeats#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/heartbeats/1").to route_to("heartbeats#destroy", :id => "1")
    end

  end
end
