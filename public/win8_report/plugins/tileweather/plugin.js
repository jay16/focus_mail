/*
 * Get woeid from here:  http://woeid.rosselliot.co.nz/
 * Get weather code for use in zipcode variable from http://edg3.co.uk/snippets/weather-location-codes/
*/
function tileWeatherInit(id,zipcode,location,woeid,unit){
		    	$.simpleWeather({
				zipcode: zipcode,
				location: location,
				woeid: woeid,
				unit: unit,
				success: function(weather) {
					today = '<div class="weatherwrapper">';
					today += '<div class="img"><img src="'+weather.image+'" style="width:220px;"></div>';
					today += '<div class="weathercontent">';
					today += '<div class="temp">'+weather.temp+'&deg;'+weather.units.temp+'</div>';
					today += '<a class="location" href="'+weather.link+'">'+weather.city+', '+weather.region+' '+weather.country+'</a>';
					today += '<div class="wind">'+weather.wind.direction+' '+weather.wind.speed+' '+weather.units.speed+'</div>'; 
					today += '<div class="humid">'+weather.humidity+'% Humidity</div>'; 
						
					today += '</div></div>';
					today += '<div class="forecast">'+weather.forecast+'</div>';
					///////////-end today html
					tomorrow = '<div style="position: relative;">';
					tomorrow += '<div class="img"><img src="'+weather.tomorrow.image+'" style="width:220px;"></div>';
					tomorrow += '<div style="position: absolute; top: 0; left: 150px;">';
					tomorrow += '<div class="for_title">Tomorrow</div>';		
					tomorrow += '<a class="location" href="'+weather.link+'">'+weather.city+', '+weather.region+' '+weather.country+'</a>';
						
					tomorrow += '<div class="for_temp">'+weather.tomorrow.high+'&deg; '+weather.units.temp+' / '+weather.tomorrow.low+'&deg; '+weather.units.temp+'</div>';
					tomorrow += '</div></div>';
					tomorrow += '<div class="forecast">'+weather.tomorrow.forecast+'</div>';
					///////////-end tomorrow html
					weatherArray = new Array(today,tomorrow);
					$("#tileWeather"+id).children("#weather").html(weatherArray[0])
					setTimeout(function(){weatherUpdater(id,weatherArray,0)},5000); // init this tile
					},
				});		
	}
function weatherUpdater(id,texts,n){
	if($page.current == "home" && !scrolling){
		var $id = $("#tileWeather"+id).children("#weather")
		$id.stop().animate({opacity: 0,'margin-top': '+=15'},250,function(){
			$id.css("margin-top",-15).css("opacity",0)
			.html(texts[n])
			.animate({opacity: 1,'margin-top': '+=15'},250,function(){
				$id.css("margin-top",0).css("opacity",1);
			})
		});	
		n = (n+2>texts.length) ? 0 : n+1;
	}
	n%=2;
	setTimeout(function(){weatherUpdater(id,texts,n)},5000);
}