<!DOCTYPE HTML>
<html>
<head>
<meta charset="utf-8">
<title>Blacksmith Applications, Inc.</title>
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

	background: 		-moz-linear-gradient(top,  rgba(200,200,200,0.50) 0%, rgba(55,55,55,0.50) 100%); /* FF3.6+ */
	background: 		-webkit-gradient(linear, left top, left bottom, color-stop(0%,rgba(200,200,200,0.50)), color-stop(100%,rgba(55,55,55,0.50))); /* Chrome,Safari4+ */
	background: 		-webkit-linear-gradient(top,  rgba(200,200,200,0.50) 0%,rgba(55,55,55,0.50) 100%); /* Chrome10+,Safari5.1+ */
	background: 		-o-linear-gradient(top,  rgba(200,200,200,0.50) 0%,rgba(55,55,55,0.50) 100%); /* Opera 11.10+ */
	background: 		-ms-linear-gradient(top,  rgba(200,200,200,0.50) 0%,rgba(55,55,55,0.50) 100%); /* IE10+ */
	background: 		linear-gradient(top,  rgba(200,200,200,0.50) 0%,rgba(55,55,55,0.50) 100%); /* W3C */
	filter: 			progid:DXImageTransform.Microsoft.gradient( startColorstr='#bf8c8c8c', endColorstr='#bf355555',GradientType=0 ); /* IE6-9 */


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
	border:				0px #777777 solid;
	width:				350px;
	height:				150px;

	background: 		-moz-linear-gradient(top,  rgba(55,55,55,0.50) 0%, rgba(200,200,200,0.50) 100%); /* FF3.6+ */
	background: 		-webkit-gradient(linear, left top, left bottom, color-stop(0%,rgba(55,55,55,0.50)), color-stop(100%,rgba(200,200,200,0.50))); /* Chrome,Safari4+ */
	background: 		-webkit-linear-gradient(top,  rgba(55,55,55,0.50) 0%,rgba(200,200,200,0.50) 100%); /* Chrome10+,Safari5.1+ */
	background: 		-o-linear-gradient(top,  rgba(55,55,55,0.50) 0%,rgba(200,200,200,0.50) 100%); /* Opera 11.10+ */
	background: 		-ms-linear-gradient(top,  rgba(55,55,55,0.50) 0%,rgba(200,200,200,0.50) 100%); /* IE10+ */
	background: 		linear-gradient(top,  rgba(55,55,55,0.50) 0%,rgba(200,200,200,0.50) 100%); /* W3C */
	filter: 			progid:DXImageTransform.Microsoft.gradient( startColorstr='#bf355555', endColorstr='#bf8c8c8c',GradientType=0 ); /* IE6-9 */


}


input.login_text_boxes
{
	width:				175px;
	height:				30px;
	color:				#999999;
	background-color:	#EEEEEE;
	font-weight:		bold;
	font-size:			15px;
	margin:				19px 0px 0px 0px;
	padding:			0px 0px 0px 10px;

    -moz-border-radius:		6px;
    -webkit-border-radius:	6px;
    border-radius:			6px;
	
	border:					2px #999999 solid;
}

img.bs_logo
{
	margin:				15px 0px 0px 0px;
	padding:			0px 0px 0px 0px;
}




div.links
{
	line-height:			35px; 
	width:					150px;
	text-align:				center;
	padding: 				0px 0px 5px 0px; 
	margin: 				0px 0px 0px 0px; 
	color:					#FFFFFF; 
	font-size:				12px; 
	font-weight:			bold;

	background: #7d7e7d; /* Old browsers */
	background: -moz-linear-gradient(top,  #7d7e7d 0%, #0e0e0e 100%); /* FF3.6+ */
	background: -webkit-gradient(linear, left top, left bottom, color-stop(0%,#7d7e7d), color-stop(100%,#0e0e0e)); /* Chrome,Safari4+ */
	background: -webkit-linear-gradient(top,  #7d7e7d 0%,#0e0e0e 100%); /* Chrome10+,Safari5.1+ */
	background: -o-linear-gradient(top,  #7d7e7d 0%,#0e0e0e 100%); /* Opera 11.10+ */
	background: -ms-linear-gradient(top,  #7d7e7d 0%,#0e0e0e 100%); /* IE10+ */
	background: linear-gradient(top,  #7d7e7d 0%,#0e0e0e 100%); /* W3C */
	filter: progid:DXImageTransform.Microsoft.gradient( startColorstr='#7d7e7d', endColorstr='#0e0e0e',GradientType=0 ); /* IE6-9 */

    -moz-border-radius:		6px;
    -webkit-border-radius:	6px;
    border-radius:			6px;

    border:					solid 1px #333333;
}



a.links
{
	color:					#FFFFFF; 
	font-size:				20px;
}








</style>

<body class="body">

<form action="enter.cfm" method="post" name="myFORM" id="myFORM">

<div class="outer_box">
	<img src="/Images/Logon_Blacksmith/bs_logo.png" class="bs_logo">
		
	<div class="inner_box">
		<br />
		<input 	
			name="User_Code" 
			id="usercode" 
			type="text" 
			value="enter user code here" 
			class="login_text_boxes" 
			onclick="this.value='';" 
			onfocus="this.select()" 
			onblur="this.value=!this.value?'enter user code here':this.value;" 
			autocorrect="off" 
			autocapitalize="off"><br />

		<input 
			name="User_Password" 
			id="password" 
			type="text" 
			value="enter password here" 
			class="login_text_boxes" 
			onclick="document.getElementById('password').type='password'; document.getElementById('password').value='';" 
			onFocus="document.getElementById('password').type='password'; document.getElementById('password').value='';" 
			onblur="this.value=!this.value?'enter password here':this.value;"
			autocorrect="off" 
			autocapitalize="off">
	</div>


	<div align="right" style="margin:30px 50px 0px 0px;">
		<div class="links sales" onclick="javascript:myFORM.action='enter.cfm'; myFORM.submit(); return false;" style="cursor: pointer;">click here to login</div> 
	</div>
	
	<div align="left" style="margin:30px 50px 0px 0px; color:#777777; font-size:10px;">
		Version 7.0.000 Copyright 2011-2012 Blacksmith Applications, Inc.
	</div>

</div>

</form>

</body>
</html>





















