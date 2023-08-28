class DashboardsController < ApplicationController
  
  def index 
   
end

def show 
    @dashboard = Dashboard.find(params[:id])
end
end