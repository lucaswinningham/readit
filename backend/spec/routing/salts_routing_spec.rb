require "rails_helper"

RSpec.describe SaltsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/salts").to route_to("salts#index")
    end


    it "routes to #show" do
      expect(:get => "/salts/1").to route_to("salts#show", :id => "1")
    end


    it "routes to #create" do
      expect(:post => "/salts").to route_to("salts#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/salts/1").to route_to("salts#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/salts/1").to route_to("salts#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/salts/1").to route_to("salts#destroy", :id => "1")
    end

  end
end
