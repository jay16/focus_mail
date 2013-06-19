minZoomScale = 0.8 // CHANGE TO YOUR LIKING -> lower is smaller!

zoomScale = 1
$.plugin($windowResizeEnd,{
	resizeTiles:function(){
		setTimeout(function(){
		if($page.current == "home" && $page.layout != "column"){
			tcH =  $("#tileContainer").height();
			tcMargin = parseInt($("#wrapper").css("padding-top"))+parseInt($("#centerWrapper").css("margin-bottom"))+35
			zoomScale = Math.abs(($(window).height()-tcMargin)/tcH)
			
			if(zoomScale >=1){
				zoomScale = 1;
				if($.browser.name == "opera" || $.browser.name == "mozilla"){
					$("#tileContainer").css("-moz-transform","none").css("-o-transform","none");
				}else{
					$("#tileContainer").css('zoom',1)
				}
			}else{
				zoomScale = (zoomScale<minZoomScale)? minZoomScale : zoomScale;
				if($.browser.name == "opera" || $.browser.name == "mozilla"){
					$("#tileContainer").css("-moz-transform","scale("+zoomScale+")").css("-o-transform","scale("+zoomScale+")");
				}else{
					$("#tileContainer").css('zoom',zoomScale)
				}
			}
		}else{
			$("#tileContainer").css('zoom', 1);
		}
		},2000);
	}
});
