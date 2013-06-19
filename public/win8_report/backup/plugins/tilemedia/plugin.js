$.plugin($afterTilesShow,{
	media:function(){
		$.fn.media.mapFormat('mp3', 'winmedia');		
		$('div.media').media({
		});	
	}
})