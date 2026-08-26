<!DOCTYPE HTML>
<html>
<head>
<meta charset="utf-8">
<title>Untitled Document</title>
</head>

<style>
body.body
{
	padding:			0px 0px 0px 0px;
	margin:				0px 0px 0px 0px;
	background-color:	#333;
	background-image:	url(images/black_sand.png);
	text-align:			center;
}

div.outer_box
{
	padding:			0px 0px 0px 0px;
	margin-top:			13%;
	margin-right:		auto;
	margin-bottom:		13%;
	margin-left:		auto;
	border:				1px #333333 solid;
	width:				600px;
	height:				375px;

	background: 		#8c8c8c; /* Old browsers */
	background: 		-moz-linear-gradient(top,  #8c8c8c 0%, #353535 100%); /* FF3.6+ */
	background: 		-webkit-gradient(linear, left top, left bottom, color-stop(0%,#8c8c8c), color-stop(100%,#353535)); /* Chrome,Safari4+ */
	background: 		-webkit-linear-gradient(top,  #8c8c8c 0%,#353535 100%); /* Chrome10+,Safari5.1+ */
	background: 		-o-linear-gradient(top,  #8c8c8c 0%,#353535 100%); /* Opera 11.10+ */
	background: 		-ms-linear-gradient(top,  #8c8c8c 0%,#353535 100%); /* IE10+ */
	background: 		linear-gradient(top,  #8c8c8c 0%,#353535 100%); /* W3C */
	filter: progid:		DXImageTransform.Microsoft.gradient( startColorstr='#8c8c8c', endColorstr='#353535',GradientType=0 ); /* IE6-9 */

	-webkit-box-shadow: 0px 0px 3px 3px rgba(0, 0, 0, 0.25);
	-moz-box-shadow: 	0px 0px 3px 3px rgba(0, 0, 0, 0.25);
	box-shadow: 		0px 0px 3px 3px rgba(0, 0, 0, 0.25); 
	
	-webkit-border-radius:	7px;
	-moz-border-radius: 	7px;
	border-radius: 			7px; 

}

div.inner_box
{
	padding:			0px 0px 0px 0px;
	margin-right:		auto;
	margin-left:		auto;
	border:				1px #333333 solid;
	width:				350px;
	height:				150px;

	background: 		#353535; /* Old browsers */
	background: 		-moz-linear-gradient(top,  #353535 0%, #8c8c8c 100%); /* FF3.6+ */
	background: 		-webkit-gradient(linear, left top, left bottom, color-stop(0%,#353535), color-stop(100%,#8c8c8c)); /* Chrome,Safari4+ */
	background: 		-webkit-linear-gradient(top,  #353535 0%,#8c8c8c 100%); /* Chrome10+,Safari5.1+ */
	background: 		-o-linear-gradient(top,  #353535 0%,#8c8c8c 100%); /* Opera 11.10+ */
	background: 		-ms-linear-gradient(top,  #353535 0%,#8c8c8c 100%); /* IE10+ */
	background: 		linear-gradient(top,  #353535 0%,#8c8c8c 100%); /* W3C */
	filter: 			progid:DXImageTransform.Microsoft.gradient( startColorstr='#353535', endColorstr='#8c8c8c',GradientType=0 ); /* IE6-9 */
	
	-webkit-box-shadow: inset 0px 0px 3px 3px rgba(0, 0, 0, 0.25);
	-moz-box-shadow: 	inset 0px 0px 3px 3px rgba(0, 0, 0, 0.25);
	box-shadow: 		inset 0px 0px 3px 3px rgba(0, 0, 0, 0.25); 

}


input.login_text_boxes
{
	width:				175px;
	height:				25px;
	color:				#999999;
	background-color:	#EEEEEE;
	font-weight:		bold;
	font-size:			16px;
	margin:				18px 0px 0px 0px;
}

img.bs_logo
{
	margin:				15px 0px 0px 0px;
	padding:			0px 0px 0px 0px;
}


</style>

<body class="body">

<form action="index2.cfm" method="post" name="MyForm" id="MyForm">



<div class="outer_box">
<img src="images/bs_logo.png" class="bs_logo">
		
	<div class="inner_box">
		<br />
		<input 	name="User_Code" type="text" value="enter user code here" class="login_text_boxes" onclick="this.value='';" onfocus="this.select()" onblur="this.value=!this.value?'enter user code here':this.value;" value="enter user code here" autocorrect="off" autocapitalize="off"><br />
		<input id="password"onclick="document.getElementById('password').type='password'; document.getElementById('password').value='';" name="User_Password" value="enter password here" type="text" class="login_text_boxes" autocorrect="off" autocapitalize="off">
	</div>


	<div align="right" style="margin:30px 50px 0px 0px;">
		<input type="image" name="Button" src="/Images/Logon_Blacksmith/login_button.png">
	</div>
	
	<div align="left" style="margin:30px 50px 0px 0px; color:#777777; font-size:10px;">
		Version 7.0.000 Copyright 2011-2012 Blacksmith Applications, In
	</div>


</div>

</form>

</body>
</html>
























