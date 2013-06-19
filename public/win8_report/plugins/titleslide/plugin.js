/* Plugin JS file */
$(document).on("mouseenter",".tileSlide",function(){
	if($(this).data("doslide")){
		
		if($(this).hasClass("right")){
			$(this).children('.imageWrapper').stop().animate({"margin-left":$(this).children(".slideText").width()+15},400);
			$(this).children(".slideText").stop().animate({"left":0},400);
		}else if($(this).hasClass("left")){
			$(this).children('.imageWrapper').stop().animate({"margin-left":-$(this).children(".slideText").width()-15},400);
			$(this).children(".slideText").stop().animate({"left":"-="+($(this).children(".slideText").width()+15)},400);
		}else if($(this).hasClass("down")){
			$(this).children('.imageWrapper').stop().animate({"margin-top":$(this).children(".slideText").height()+15},400);
			$(this).children(".slideText").stop().animate({"top":0},400);
		}else if($(this).hasClass("up")){
			$(this).children('.imageWrapper').stop().animate({"margin-top":-$(this).children(".slideText").height()-15},400);
			$(this).children(".slideText").stop().animate({"top":"-="+($(this).children(".slideText").height()+15)},400);
		}
	}else{
		if($(this).hasClass("right")){
			$(this).children('.imageWrapper').stop().animate({"margin-left":$(this).children(".slideText").width()+15},400);
		}else if($(this).hasClass("left")){
			$(this).children('.imageWrapper').stop().animate({"margin-left":-$(this).children(".slideText").width()-15},400);
		}else if($(this).hasClass("down")){
			$(this).children('.imageWrapper').stop().animate({"margin-top":$(this).children(".slideText").height()+15},400);
		}else if($(this).hasClass("up")){
			$(this).children('.imageWrapper').stop().animate({"margin-top":-$(this).children(".slideText").height()-15},400);
		}
	}
	
}).on("mouseleave",".tileSlide",function(){
	$(this).children('.imageWrapper').stop().animate({"margin-left":0, "margin-top":0},400);
	if($(this).data("doslide")){	
		if($(this).hasClass("right")){
			$(this).children(".slideText").stop().animate({"left":-$(this).children(".slideText").width()},400);
		}else if($(this).hasClass("left")){
			$(this).children(".slideText").stop().animate({"left":$(this).width()},400);
		}else if($(this).hasClass("down")){
			$(this).children(".slideText").stop().animate({"top":-$(this).children(".slideText").height()},400);
		}else if($(this).hasClass("up")){
			$(this).children(".slideText").stop().animate({"top":$(this).height()},400);
		}
	}
})