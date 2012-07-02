## first step
#dim_dates
@start_date = Date.parse('2001-01-01')
@end_date = Date.parse('2015-12-31')
@week = @start_date.strftime("%V")
@quarter = @start_date.month/4 +1
while @start_date <= @end_date do
		date = DimDate.create(
				date_m: @start_date.month,
				date_wn: @start_date.strftime("%V"),
		  date_y: @start_date.year,
				date_d: @start_date,
				date_q: @start_date.month/4 +1,
				date_s: @start_date.strftime("%Y-%m-%d"),
				date_w: @start_date.wday)
		@start_date += 1
end
#lists,members,templates,entries
(1..3).each do |i|
  List.create(name: "list#{i}")
  @member = rand(50..300)
  (1..@member).each do |l|
    Member.create(email: "intfocus#{l}@mail.com" , list_id: i, name: "intfocus#{l}")
  end
  
  Template.create(file_name: "template#{i}", name: "name#{i}", source: "")
  (1..@member%3+1).each do |t|
    Entry.create(default_value: "www.intfoccus#{t}.com", name: "entry#{t}", template_id: i)
  end
end
(0..50).each do |i|
  @rand = rand(i..50+i)
  Link.create(url: "www.intfocus#{@rand}.com")
  Link.create(url: "www.google#{@rand}.com")
end

##second step
#tracks,clicks
Member.all.each do |m|
  @campaign_id = CampaignList.find_by_list_id(m.list_id).campaign_id
  @created_at = m.created_at+rand(10000..1000000)

  #open between 0 and  3
  @count = rand(1..99)%4
  if @count>0
				(@count).times {
				  Track.create(member_id: m.id, campaign_id: @campaign_id, created_at: @created_at, 
				    updated_at: DateTime.now())
				  #open the mail but not click
				  if(rand(1..100)%2==1)
								Click.create(campaign_id: @campaign_id, link_id: rand(1..99), member_id: m.id, 
								  created_at: @created_at+rand(10000..100000), updated_at: DateTime.now())
						end
				}
		end
		@count = rand(1..99)%3
  if @count>0 and m.id%11==1
				(@count).times {
								Click.create(campaign_id: @campaign_id, link_id: rand(1..99), member_id: m.id, 
								  created_at: @created_at+rand(10000..100000), updated_at: DateTime.now())
				}
		end
end

