/*flip tile 0.1 */
if(($.browser.name=="msie" && $.browser.version<11)  || $.browser.name=="opera"){	
	$(document).on("mouseenter",".tileFlip",function(){
		$(this).removeClass("support3D").find(".flipFront, .tileLabelWrapper").stop().fadeOut(500);
	}).on("mouseleave",".tileFlip",function(){
		$(this).find(".flipFront, .tileLabelWrapper").fadeIn(500);
	})
}else{
	$(document).on("mouseenter",".tileFlip",function(){
		clearTimeout(timers["tileFlipTimer"]);
		$(this).addClass("tileFlipped");
	}).on("mouseleave",".tileFlipped",function(){
		timers["tileFlipTimer"] = setTimeout(function(){$(".tileFlipped").removeClass("tileFlipped")},600);
	})
}