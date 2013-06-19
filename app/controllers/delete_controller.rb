require 'will_paginate/array'
class DeleteController < ApplicationController
  
  def index
    @dlists = List.where("is_used = false")
  end
  
  def delete_list
    list_id = params[:list_id]
    @list = List.find(list_id)
    if @list.is_used == false
      @list.destroy
    end
  end
  
  def delete_all_lists
    @lists = List.where("is_used = false")
    @list.each do |list|
      list.destroy
    end
  end
end