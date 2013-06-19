module AnalyzerHelper
  def pie(apie,type)
    if type == "origin"
     data = apie.collect{|h| [h[:type].to_s,h[:num].to_i]}
    elsif type == "analyzer"
     data = apie.collect{|h| [h[:type].to_s,h[:all_per]]}
    end

    pie = LazyHighCharts::HighChart.new('graph') do |f|
      f.chart({:plotBackgroundColor=> '#E4E4E4', 
        :backgroundColor=> '#E4E4E4',
        :height => 100,
        :width => 100,
        :plotShadow => false})
      f.title({:text=> ''})
      f.plotOptions({:pie=>{
          :allowPointSelect=> true , 
          :cursor=> 'pointer' , 
          :dataLabels=>{
            :enabled=> false , 
            :color=> '#FFFFFF' , 
            :connectorColor=> '#FFFFFF'}}})
      f.series({:type=>'pie' , :name=> 'Browser share' , :data=> data})
      f.tooltip({:enabled => false })
    end
    return pie
  end
  
  def getEmailCount(atype)
    atype.inject(0){|sum, h| sum += h[:num].to_i }
  end
end