class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :user_org
  validates_presence_of :user_org
  # attr_accessible :title, :body
  has_many :useradmin, :class_name => "Useradmin", :primary_key => "asset_id"
  
  
  def user_org
    @userorg
  end
  
  def user_org= (val)
    @userorg = val
  end
end
