require 'will_paginate/array'
class MembersController < ApplicationController
  layout "appmembers"
  def index
    @list = List.find(params[:list_id])
    params[:per_page] = 19
    @members = @list.members.paginate(:page => params[:page], :per_page => params[:per_page])
    user_action_log(0,params[:controller],"index")
    
    respond_to do |format|
      format.html { render :layout => false }
    end
  end

  def show
    @list = List.find(params[:list_id])
    @member = Member.find(params[:id])
    user_action_log(params[:id],params[:controller],"show")

    respond_to do |format|
      format.html { render  :index }
      format.json { render json: @member }
    end
  end

  def new
    @list = List.find(params[:list_id])
    @member = @list.members.build
    user_action_log(0,params[:controller],"new")

    respond_to do |format|
      format.html { render :layout => false }
      format.json { render json: @member }
      format.js
    end
  end

  def edit
    @list = List.find(params[:list_id])
    @member = @list.members.find(params[:id])
    user_action_log(params[:id],params[:controller],"edit")
    
    respond_to do |format|
      format.html { render :layout => false }
      format.json { render json: @member }
      format.js
    end
  end

  def create
    @list = List.find(params[:list_id])
    member = Member.where(["email = :e", { :e =>params[:member][:email] }])
    @save_state = false
    if member.count <= 0 then
      @member = @list.members.create(params[:member])
      respond_to do |format|
        @member.listid = @list.id
        if @member.save
          user_action_log(@member.id,params[:controller],"create")
          @save_state = true
          format.html { redirect_to list_members_path(@list.id), notice: 'Member was successfully created.' }
          format.json { render json: @member, status: :created, location: @member }
          format.js
        else
          @save_state = false
          format.js
          format.html { render action: "new" }
          format.json { render json: @member.errors, status: :unprocessable_entity }
        end
      end
    else
      user_action_log(member.first.id,params[:controller],"create")
      num = ListsMembers.where(["list_id = :l and member_id = :m", { :l => @list.id, :m => member.first.id }]).count
      if num <= 0 then
        ListsMembers.create({
          :list_id => @list.id, 
          :member_id => member.first.id,
          :week_number => params[:member][:weeknumber]
        })
      end
      @list.update_attribute(:member_count,(@list.member_count.to_i+1).to_s)
      respond_to do |format|
        @save_state = true
        format.html { redirect_to list_members_path(@list.id), notice: 'Member was successfully created.' }
        format.json { render json: member, status: :created, location: member }
        format.js
      end
    end
  end

  def update
    @list = List.find(params[:list_id])
    @member = @list.members.find(params[:id])
    
    #去除前后空格
    email = params[:member][:email].to_s.strip
    #正则匹配邮箱格式
    ret = /\w+([-+.]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*/.match(email)
    if ret.to_s == email then
      @is_valid = true
    else
      @is_valid = false
    end

    respond_to do |format|
      @member.listid = @list.id
      if @is_valid == true then
        @member.update_attributes(params[:member])
        user_action_log(params[:id],params[:controller],"update")
        format.html { redirect_to list_members_path(@list.id), notice: 'Member was successfully updated.' }
        format.json { head :no_content }
        format.js
      else
        format.html { render action: "edit" }
        format.json { render json: @member.errors, status: :unprocessable_entity }
        format.js
      end
    end
    
  end

  def destroy
    @listsmembers = ListsMembers.where(["list_id = :l and member_id = :m", { :l => params[:list_id], :m => params[:id] }])
    ListsMembers.delete(@listsmembers.first.id)
    @list = List.find(params[:list_id])
    user_action_log(@listsmembers.first.id,params[:controller],"delete")
    #@member = @list.members.find(params[:id])
    #@member.destroy

    respond_to do |format|
      format.html { redirect_to list_members_path(@list.id) }
      format.json { head :no_content }
    end
  end

  def export
    @members = List.find(params[:list_id]).members

    respond_to do |format|
      format.xls {
        send_data(xls_content_for(@members),
                  :type => "text/excel;charset=utf-8; header=present",
                  :filename => "Report_Members_#{Time.now.strftime("%Y%m%d%H%M")}.xls")
      }
      format.csv {
        send_data(csv_content_for(@members),
                  :type => "text/csv;charset=utf-8; header=present",
                  :filename => "Report_Members_#{Time.now.strftime("%Y%m%d%H%M")}.csv")
      }
    end
  end

  def imexport
    @list_id = params[:list_id]
    @list = List .find( @list_id)
    
    respond_to do |format|
      format.html { render :layout => false }
      format.js
    end
  end

  def import
    require 'csv'
    @list = List.find(params[:list_id])
    file = MemberUploader.new
    file.store!(params[:file])
    @members = []
    @errors = Hash.new
    @counter = 0

    if params[:type] == 'xls'
      # import from excel
      book = Spreadsheet.open "#{file.store_path}"
      sheet1 = book.worksheet 0

      sheet1.each 1 do |row|
        @counter+=1
        p = Member.new
        member = Member.where(["email = :e", { :e => row[1] }])
        if member.count <= 0 then
          Member.get_field_array.each_with_index do |field, i|
            p.send("#{field[0]}=", row[i])
          end
          if p.valid?
            p.listid = @list.id
            p.save!
            @members << p
          else
            @errors["#{@counter+1}"] = p.errors
          end
        else
          num = ListsMembers.where(["list_id = :l and member_id = :m", { :l => @list.id, :m => member.first.id }]).count
          if num <= 0 then
            ListsMembers.create({
              :list_id => @list.id, 
              :member_id => member.first.id,
              :domain => member.first.email.split("@")[1]
            })
          end
          #重复名单显示
          Member.get_field_array.each_with_index do |field, i|
            p.send("#{field[0]}=", row[i])
          end
          p.listid = @list.id
          p.id = member.first.id
          p.created_at = member.first.created_at
          @members << p
        end
      end
    else
      # import from csv
      CSV.foreach(file.store_path, :headers => true) do |row|
        p = Member.new
        member = Member.where(["email = :e", { :e => row[1] }])
        if member.count <= 0 then
          Member.get_field_array.each_with_index do |field, i|
            p.send("#{field[0]}=", row[i])
          end
          if p.valid?
            p.listid = @list.id
            p.save!
            @members << p
          else
            @errors["#{@counter+1}"] = p.errors
          end
        else
          num = ListsMembers.where(["list_id = :l and member_id = :m", { :l => @list.id, :m => member.first.id }]).count
          if num <= 0 then
            ListsMembers.create({
              :list_id => @list.id, 
              :member_id => member.first.id,
              :domain => member.first.email.split("@")[1]
            })
          end
          #重复名单显示
          Member.get_field_array.each_with_index do |field, i|
            p.send("#{field[0]}=", row[i])
          end
          p.listid = @list.id
          p.id = member.first.id
          p.created_at = member.first.created_at
          @members << p
        end
      end
    end
    file.remove!
    
    
    redirect_to :controller=>"categories", :action => "index",:list_id => @list.id 
  end

  def import_template
    respond_to do |format|
      format.xls {
        send_data(xls_content_for(nil),
                  :type => "text/excel;charset=utf-8; header=present",
                  :filename => "Template_Members_#{Time.now.strftime("%Y%m%d%H%M")}.xls")
      }
      format.csv {
        send_data(csv_content_for(nil),
                  :type => "text/excel;charset=utf-8; header=present",
                  :filename => "Template_Members_#{Time.now.strftime("%Y%m%d%H%M")}.csv")
      }
    end
  end

  private
  def xls_content_for(objs)
    xls_report = StringIO.new
    book = Spreadsheet::Workbook.new
    sheet1 = book.create_worksheet :name => "Members"

    blue = Spreadsheet::Format.new :color => :blue, :weight => :bold, :size => 10
    sheet1.row(0).default_format = blue

    sheet1.row(0).concat Member.get_field_array.collect{|arr| arr[1] }
    count_row = 1
    if objs
      columns = Member.get_field_array.collect{|arr| arr[0] }
      objs.each do |obj|
        columns.each_with_index do |column_name, i|
          sheet1[count_row, i] = obj.send(column_name)
        end
        count_row += 1
      end
    end

    book.write xls_report
    xls_report.string
  end

  def csv_content_for(objs)
    require 'csv'
    csv = CSV.generate(:force_quotes => true) do |line|
      column_labels = Member.get_field_array.collect{|arr| arr[1] }
      line << column_labels
      if objs
        columns = Member.get_field_array.collect{|arr| arr[0] }
        arr = []
        objs.each do |obj|
          columns.each do |column_name|
            arr << obj.send(column_name)
          end
          line << arr
          arr = []
        end
      end
    end
    csv
  end

end
