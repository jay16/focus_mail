require "spec_helper"

describe UseradminsController do
  describe "routing" do

    it "routes to #index" do
      get("/useradmins").should route_to("useradmins#index")
    end

    it "routes to #new" do
      get("/useradmins/new").should route_to("useradmins#new")
    end

    it "routes to #show" do
      get("/useradmins/1").should route_to("useradmins#show", :id => "1")
    end

    it "routes to #edit" do
      get("/useradmins/1/edit").should route_to("useradmins#edit", :id => "1")
    end

    it "routes to #create" do
      post("/useradmins").should route_to("useradmins#create")
    end

    it "routes to #update" do
      put("/useradmins/1").should route_to("useradmins#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/useradmins/1").should route_to("useradmins#destroy", :id => "1")
    end

  end
end
