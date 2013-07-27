require 'resque/server'
FocusMail::Application.routes.draw do
  get "campaigns/test_job"
  get "user/edit"
  post "user/update_password"

  devise_for :users

  root :to => 'home#index'
  match 'open/getstate' => 'open#getstate'
  match 'open/sendmail' => 'open#sendmail'
  match 'track.gif' => 'respond#track'
  match 'click' => 'respond#click'
  match 'testcode' => 'testcode#index'
  post 'testcode/save'
  post 'campaigns/mailtest'
  post 'useradmins/saveupdate'
  match 'send_email' => 'home#send_email', via: 'post'
  match 'generate_email' => 'home#generate_email', via: 'get'
  match 'preview/:campaign_id' => "home#preview", :as => :preview
  get 'report/export'

  resources :links
  resources :campaigns
  resources :campaign_members
  resources :categories do
    get 'update_member_count', :on => :member
    get 'member_search', :on => :member
  end
  resources :templates do
    resources :entries
    get "download", :on => :collection
  end
  resources :lists do
    resources :members
  end
  resources :useradmins

 
  match 'templates/saveimgurl', via: 'post'
  match 'campaigns/template_entries/:c_id/:t_id' => 'campaigns#template_entries'
  match 'campaigns/:id/deliver/', controller: 'campaigns', action: 'deliver', as: 'deliver_campaign'
  match 'campaigns/:id/copies/', controller: 'campaigns', action: 'copies', as: 'copies_campaign'
  #match 'campaigns/:id/mailtest/', controller: 'campaigns', action: 'mailtest', as: 'mailtest_campaign'

  match 'campaigns/:campaign_id/record' => 'campaigns#record', :as => :campaigns_record
  match 'members/export/:list_id' => 'members#export', :as => :members_export
  get 'members/import_template'
  
  match 'members/imexport/:list_id' => 'members#imexport', :as => :members_imexport
  match 'members/import' => 'members#import', :via => :post
  match 'templates/grade/:template_id' => 'templates#grade', :as => :templates_grade
  match 'templates/preview/:template_id' => 'templates#preview', :as => :templates_preview
  
  match ':controller(/:action(/:id(.:format)))'
  
  mount Resque::Server.new, :at => '/resque'
end
