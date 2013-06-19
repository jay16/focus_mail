#encoding:utf-8
class CategoriesController < ApplicationController
  # GET /categories
  # GET /categories.json
  def index
    @l_id = params[:lists_all]
    if @l_id != nil && @l_id != "" then
      lwhere = "id = #{@l_id} and is_used != false"
    else
      lwhere = ""
    end
    user_id = current_user.id
    @category = List.new
    @category.org_id = FocusMail::ListUserorg::userorg_id(user_id)
    #userids = [6,7,8,9,10,12,13]
    puts "#"*40+user_action_org.to_s
    if user_action_org then
      @lists = List.paginate(:page => params[:page], :per_page => 5, :conditions => lwhere =="" ? "is_used != false" : lwhere, :order => "updated_at desc")
      @lists_all = List.where([lwhere =="" ? "is_used != false" : lwhere]).order("created_at desc")
      @list = List.new
      @category = List.new
      @category.org_id = FocusMail::ListUserorg::userorg_id(user_id)
    else
      controller = "List"
      orglist = FocusMail::ListUserorg::userorg_list(user_id, controller).join(",")
       puts "#"*40+orglist.to_json
      if orglist.length == 0 then
        @lists = List.paginate(:page => params[:page], :per_page => 5, :conditions => "1=2 and is_used != false", :order => "updated_at desc")
        @lists_all = List.where(["1=2 and is_used != false"])
      else
        @lists = List.paginate(:page => params[:page], :per_page => 5, :conditions => lwhere == "" ? "id in (#{orglist}) and is_used != false" : "is_used != false", :order => "created_at desc")
        @lists_all = List.where(["id in (#{orglist}) and is_used != false"])
      end
      @category = List.new
      @category.org_id = FocusMail::ListUserorg::userorg_id(user_id)
    end
    @memberorg = MemberOrg.paginate(:page => params[:page], :per_page => 20)
    user_action_log(0,params[:controller],"index")
    WillPaginate::ViewHelpers.pagination_options[:previous_label] = '上一页'
    WillPaginate::ViewHelpers.pagination_options[:next_label] = '下一页' 

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @memberorg }
    end
  end
  
  def new
    #@list = List.new
    user_id = current_user.id
    @category = List.new
    @category.org_id = FocusMail::ListUserorg::userorg_id(user_id)
    user_action_log(0,params[:controller],"new")

    respond_to do |format|
      format.html # new.html.erb
      format.js
    end
  end
  
  def edit
    @category = List.find(params[:id])
    user_action_log(params[:id],params[:controller],"edit")

    respond_to do |format|
      format.html
      format.js
    end
  end
  
  def create
    puts "#"*50
    List.create({
      :name => params[:name],
      :org_id => params[:org_id],
      :is_used => true
    })
    respond_to do |format|
      format.js
    end
  end
  
  def update
    @lupdate = List.update(params[:id],{
      :name => params[:name]
    })
    session[:list_id] = @lupdate.id
  end
  
  def destroy
    @list = List.find(params[:id])
    @list.update_attribute(:is_used,false)
    puts "*"*100
    puts "categories_controlle"
    #@list.destroy
    user_action_log(params[:id],params[:controller],"delete")
  end
  
  def update_member_count
    @list_id = params[:id]
    list = List.find(@list_id)
    @member_count = ListsMembers.where("list_id=?",@list_id).count
    if list.member_count.present? then
      if @member_count > list.member_count.to_i then
        list.update_attribute(:member_count, @member_count.to_s)
      end
    else
      list.update_attribute(:member_count, @member_count.to_s)
    end
  end
  
  def member_search
    list_id = params[:id]
    @keyword = params[:keyword]
    @list = List.find(list_id)
    params[:per_page] = 15
    @members = @list.members.where("email like '%#{@keyword}%'")
                    .paginate(:page => params[:page], :per_page => params[:per_page],:order => "updated_at desc")
    respond_to do |format|
      format.html { render :layout => false, :template => "/categories/member_search" }
    end
  end
  
  def list_split
    list_id   = params[:list_id].to_i
    split_num = params[:split_num].to_i
    
    list = List.find(list_id)
    lists_members = ListsMembers.where("list_id =#{list_id}")
    
    user_id = current_user.id
    org_id = FocusMail::ListUserorg::userorg_id(user_id)
    
    #存放批量list
    lists = Array.new()
    (1..split_num).each do |sn|
      ll =List.new({
        :name => "#{list.name}_#{sn}",
        :org_id => org_id,
        :is_used => true
      })
      if ll.save then 
        lists.push(ll)
        puts "-"*50
        puts ll.name
      else
        puts "*"*50
        puts "no"
      end
    end
    
    lists_members.each_with_index do |lm,ii|
      index = ii%split_num
      puts "*"*50
      puts index
      current_list = lists[index]
      
      if current_list then
        puts current_list.name
          listsmembers = ListsMembers.where(["list_id = :l and member_id = :m", { :l => current_list.id , :m => lm.member_id }])
          if listsmembers.count == 0 then
            ListsMembers.create({
              :list_id => current_list.id,
              :member_id => lm.member_id
            })
          end
      else
        puts lists.length
      end
    end
    
    render :text => "over"
  end
  
end
