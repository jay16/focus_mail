# Focus_mail

By IntFocus

## Dependency

* Ruby 1.9.2+
* Rails ~> 3.2.0
* Mysql
* Bootstrap 2.0.1
* Resque

## Setup Guide

First you need to install redis and start redis server and then clone the repo start Rails server and start resque workers

    git clone git@github.com:lihaoalbert/focus_mail.git
    cd focus_mail
    cp config/database.yml.sample config/database.yml
    bundle install
    rake db:create
    rake db:migrate
    rake db:seed
    rails s
    COUNT=4 QUEUE=* VERBOSE=1 rake resque:workers

Done, fire up your browser and browse to `http://localhost:3000/` :)

Go to `http://localhost:3000/resque/` to see Resque status.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request


    					<%#= high_chart("chart" + @c_summery[:id].to_s , @c_summery[:pie]) %>
		      					<%#= image_tag("/images/2nd/pix01.gif",:style=>"width:90%;height:90%;",:alt => "Chart") %>
		      					 <div class="top" style="width:100px;height:100px;background:url(/images/2nd/loudou.png);background-position: -13px -9px;">
                <div class="logo" style="padding:2px 0 0 10px;">总数: <%=h @c_summery[:isGetData] ? @c_summery[:send_totle] : "" %></div>
                <div class="logo" style="padding:8px 0 0 20px;">送达: <%=h @c_summery[:isGetData] ? @c_summery[:send_reach] : "" %></div>
                <div class="logo" style="padding:8px 0 0 30px;">打开: <%=h @c_summery[:isGetData] ? @c_summery[:open_num] : "" %></div>
                <div class="logo" style="padding:8px 0 0 35px;">点击: <%=h @c_summery[:isGetData] ? @c_summery[:click_num] : "" %></div>     
              </div>
