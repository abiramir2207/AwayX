<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<HTML>
<HEAD>
	<TITLE>Untitled</TITLE>
</HEAD>

<BODY TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="8" TOPMARGIN="5">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Header Goes here --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<FONT SIZE="-1" FACE="Arial">
<A HREF="test3.cfm" TARGET="mainwindow">x x x x x x x x x x x x x x x x x x x x x </A>

<BR><BR>

x x x x x x x x x x x x x x x x x x x x x 

<BR><BR>

x x x x x x x x x x x x x x x x x x x x x 

<BR><BR>

x x x x x x x x x x x x x x x x x x x x x 

<BR><BR>

x x x x x x x x x x x x x x x x x x x x x 


<BR><BR>

x x x x x x x x x x x x x x x x x x x x x 

</FONT>

<!--DO NOT REMOVE BELOW SCRIPT. IT SHOULD ALWAYS APPEAR AT THE VERY END OF THE CONTENT-->

<script language="JavaScript1.2">
	var speed, currentpos=curpos1=0,alt=1,curpos2=-1
	
	function initialize(){
	if (window.parent.scrollspeed!=0){
	speed=window.parent.scrollspeed
	scrollwindow()
	}
	}
	
	function scrollwindow(){
	temp=(document.all)? document.body.scrollTop : window.pageYOffset
	alt=(alt==0)? 1 : 0
	if (alt==0)
	curpos1=temp
	else
	curpos2=temp
	window.scrollBy(0,speed)
	}
	setInterval("initialize()",30)
</script>


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Footer Goes here --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
</BODY>
</HTML>
