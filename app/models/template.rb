# encoding: utf-8
class Template < ActiveRecord::Base
  attr_accessible :file_name, :name, :source
  has_many :entries, :dependent => :destroy
  has_many :campaigns

  def source
    if self.file_name
      @source = IO.readlines(Rails.root.join('lib/emails', "#{self.file_name}.html.erb")).join("").strip
    else
      str = "Markaby::Builder.new.html do\n"
	     str << "  head do\n"
	     str << '    title "$|Title|$"'
	     str << "\n  end\n"
	     str << "  body do\n"
	     str << '    p "Hello $|NAME|$, Your Email is $|EMAIL|$, Subject is $|SUBJECT|$"'
	     str << "\n    ul do\n"
      str << '      li "当有entry添加后点击update，代码自动更新"'
      str << "\n"
					 str << "    end\n"
					 str << "  end\n"
					 str << "end\n"
      @source = str
    end
  end

  def source= (val)
    #p Rails.configuration.splitor_start
    #p Rails.configuration.splitor_end
    File.open(Rails.root.join("lib/emails", "#{self.file_name}.html.erb"), 'wb'){ |f| f.write(val) }
  end
end
