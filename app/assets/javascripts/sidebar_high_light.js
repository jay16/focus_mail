 function setStyle(id){
   $(id).css({"font-size":"140%","color":"blue"});
  }     
 var arr=location.pathname.split("/");
  //alert(arr[1]);
	switch(arr[1])
  {
   case "":
			  $(".nav-home").css({"font-size":"140%","color":"white"});
				 break;
			case "generate_email":
					setStyle("#nav-generate-email");
			  break;
			case "lists":
					setStyle("#nav-lists");
			  break;
			case "templates":
					setStyle("#nav-templates");
			  break;
			case "campaigns":
					setStyle("#nav-campaigns");
			  break;
			case "clicks":
					setStyle("#nav-clicks");
			  break;
			case "tracks":
					setStyle("#nav-tracks");
			  break;
   default:
   alert("where do you click?!") 
  }

