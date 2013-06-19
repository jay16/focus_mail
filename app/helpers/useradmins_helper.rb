module UseradminsHelper
  def user_permission(userid)
    @permissions = Useradmin.where("asset_id = #{userid}")
  end

  def get_user_org(userid)
    userorg = UserOrg.find_by_sql("select name from user_orgs as T1 inner join user_org_objects as T2 on T1.id=T2.user_org_id where T2.asset_id=#{userid}")
    if userorg.length > 0
      return userorg[0].name
    else
      return 'null'
    end
  end
end
