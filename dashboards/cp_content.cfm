<!--- ----------------------------------------------------------------------------------------- --->

<style>

table.data_table
{
	background-color:					#333333;
	border:								0px #FFCC00 dotted;
	border-collapse: 					separate;
	width:								95%;
	
    -webkit-border-radius:				10px;
    -moz-border-radius:					10px;
    border-radius:						10px;

    -webkit-border-top-left-radius:		10px;
    -webkit-border-top-right-radius:	10px;
    -webkit-border-bottom-right-radius:	10px;
    -webkit-border-bottom-left-radius:	10px;
    
    -moz-border-radius-topleft:			10px;
    -moz-border-radius-topright:		10px;
    -moz-border-radius-bottomright:		10px;
    -moz-border-radius-bottomleft:		10px;
    
    border-top-left-radius:				10px;
    border-top-right-radius:			10px;
    border-bottom-right-radius:			10px;
    border-bottom-left-radius:			10px;	
}

td.section_title
{
	color:				#000000;
	background-color:	#FFCC00;
	border-bottom:		0px #FFCC00 Solid;

    -webkit-border-top-left-radius:		10px;
    -webkit-border-top-right-radius:	10px;

	text-align:			left;
	font-size:			14px;
	font-weight:		bold;
	/*width:			100px; */
	padding:			5px 5px 5px 8px;
	margin:				35px 0px 0px 0px;
}

td.column_title
{
	color:				#FFFFFF;
	border-bottom:		2px #666666 Solid;
	text-align:			center;
	font-size:			12px;
	font-weight:		bold;
	width:				100px; 
	padding:			10px 0px 3px 8px;
	margin:				0px 0px 0px 0px;
}

td.section_sub_title
{
	color:				#FFCC00;
	border-bottom:		1px #FFCC00 dotted;
	text-align:			left;
	font-size:			12px;
	font-weight:		bold;
	width:				100px; 
	padding:			10px 0px 3px 8px;
	margin:				0px 0px 0px 0px;
}

td.row_text
{
	color:				#FFFFFF;
	border-bottom:		0px #999 Solid;
	text-align:			left;
	font-size:			12px;
	font-weight:		bold;
	/*width:			100px; */
	padding:			5px 0px 5px 8px;
	margin:				0px 0px 0px 0px;
}

td.row_text_centered
{
	text-align:			center;
}

input.checkboxes_styled, input.radiobuttons_styled
{
	width: 				26px; 
	height: 			26px; 
	-webkit-border-radius:13px; 
	background-color:	#111111;
}

input.radiobuttons_styled
{
	width: 				26px; 
	height: 			26px; 
	-webkit-border-radius:13px; 
	background-color:	#111111;
}

</style>

<div style="padding:10px; text-align:center">

<br />


<script type="text/javascript">
	/* This script and many more are available free online at
	The JavaScript Source!! http://javascript.internet.com
	Created by: Hillel Aftel |  */
	function checkAll(checkname, exby) {
	  for (i = 0; i < checkname.length; i++)
	  checkname[i].checked = exby.checked? true:false
	}
</script>


<form name ="myform">

<script>
function radioME(){
uncheckALL("j",4)
arguments[0].checked=true
return true
}

function uncheckALL(){
var currentId=0;
for(currentId=0;currentId<arguments[1];currentId++){
document.getElementById(arguments[0]+currentId).checked=false
}
}
</script>

<table cellpadding="0" cellspacing="0" align="center" class="data_table">

<!--- ----------------------------------------------------------------------------------------- --->
	<tr>
		<td colspan="100%" class="section_title">Select the default Unit Of Measure to be used by all dashboards</td>
	</tr>
	<tr>
		<td class="row_text"><input class="checkboxes_styled" id="j0" type="checkbox" value="1" onclick="radioME(this)" checked></td><td class="row_text" width="175">Dollars</td>
		<td class="row_text"><input class="checkboxes_styled" id="j1" type="checkbox" value="2" onclick="radioME(this)"></td><td class="row_text" width="175">Pounds</td>
		<td class="row_text"><input class="checkboxes_styled" id="j2" type="checkbox" value="3" onclick="radioME(this)"></td><td class="row_text" width="175">Cases</td>
		<td class="row_text"><input class="checkboxes_styled" id="j3" type="checkbox" value="4" onclick="radioME(this)"></td><td class="row_text" width="175">Equ. Cases</td>
	</tr>
<!--- ----------------------------------------------------------------------------------------- --->

</table>

<br /><br />

<table cellpadding="0" cellspacing="0" align="center" class="data_table">
	<tr>
		<td colspan="100%" class="section_title">Users' Access Rights & Permissions</td>
	</tr>
	
	<cfset	column_titles="	
			&nbsp;,
			Select<br />All,
			Budgets,
			Billbacks,
			Sales,
			Mobile<br />Access,
			Change Own<br />Settings,
			Dashboards<br />Administrator
			">
	<tr>
		<cfloop index="i" list="#column_titles#" delimiters=",">
		<td class="column_title"><cfoutput>#i#</cfoutput></td>
		</cfloop>
	</tr>

	<tr>
		<td class="section_sub_title" colspan="100%">Profile Group 1</td>
	</tr>
	<tr>
		<td class="row_text" nowrap>User Name</td>
		<td class="row_text" style="text-align:center;"><input class="checkboxes_styled" name="user_settings11" type="checkbox" value="" onClick="checkAll(document.myform.user_settings11,this)"></td>
		<td class="row_text" style="text-align:center;"><input class="checkboxes_styled" name="user_settings11" type="checkbox" value=""></td>
		<td class="row_text" style="text-align:center;"><input class="checkboxes_styled" name="user_settings11" type="checkbox" value=""></td>
		<td class="row_text" style="text-align:center;"><input class="checkboxes_styled" name="user_settings11" type="checkbox" value=""></td>
		<td class="row_text" style="text-align:center;"><input class="checkboxes_styled" name="user_settings11" type="checkbox" value=""></td>
		<td class="row_text" style="text-align:center;"><input class="checkboxes_styled" name="user_settings11" type="checkbox" value=""></td>
		<td class="row_text" style="text-align:center;"><input class="checkboxes_styled" name="user_settings11_admin" type="checkbox" value=""></td>
	</tr>
	<tr>
		<td class="row_text" nowrap>User Name</td>
		<td class="row_text" style="text-align:center;"><input class="checkboxes_styled" name="user_settings12" type="checkbox" value=""onClick="checkAll(document.myform.user_settings12,this)"></td>
		<td class="row_text" style="text-align:center;"><input class="checkboxes_styled" name="user_settings12" type="checkbox" value=""></td>
		<td class="row_text" style="text-align:center;"><input class="checkboxes_styled" name="user_settings12" type="checkbox" value=""></td>
		<td class="row_text" style="text-align:center;"><input class="checkboxes_styled" name="user_settings12" type="checkbox" value=""></td>
		<td class="row_text" style="text-align:center;"><input class="checkboxes_styled" name="user_settings12" type="checkbox" value=""></td>
		<td class="row_text" style="text-align:center;"><input class="checkboxes_styled" name="user_settings12" type="checkbox" value=""></td>
		<td class="row_text" style="text-align:center;"><input class="checkboxes_styled" name="user_settings12_admin" type="checkbox" value=""></td>
	</tr>

	<tr>
		<td class="section_sub_title" colspan="100%">Profile Group 1</td>
	</tr>
	<tr>
		<td class="row_text" nowrap>User Name</td>
		<td class="row_text" style="text-align:center;"><input class="checkboxes_styled" name="user_settings21" type="checkbox" value="" onClick="checkAll(document.myform.user_settings21,this)"></td>
		<td class="row_text" style="text-align:center;"><input class="checkboxes_styled" name="user_settings21" type="checkbox" value=""></td>
		<td class="row_text" style="text-align:center;"><input class="checkboxes_styled" name="user_settings21" type="checkbox" value=""></td>
		<td class="row_text" style="text-align:center;"><input class="checkboxes_styled" name="user_settings21" type="checkbox" value=""></td>
		<td class="row_text" style="text-align:center;"><input class="checkboxes_styled" name="user_settings21" type="checkbox" value=""></td>
		<td class="row_text" style="text-align:center;"><input class="checkboxes_styled" name="user_settings21" type="checkbox" value=""></td>
		<td class="row_text" style="text-align:center;"><input class="checkboxes_styled" name="user_settings21_admin" type="checkbox" value=""></td>
	</tr>
	<tr>
		<td class="row_text" nowrap>User Name</td>
		<td class="row_text" style="text-align:center;"><input class="checkboxes_styled" name="user_settings22" type="checkbox" value=""onClick="checkAll(document.myform.user_settings22,this)"></td>
		<td class="row_text" style="text-align:center;"><input class="checkboxes_styled" name="user_settings22" type="checkbox" value=""></td>
		<td class="row_text" style="text-align:center;"><input class="checkboxes_styled" name="user_settings22" type="checkbox" value=""></td>
		<td class="row_text" style="text-align:center;"><input class="checkboxes_styled" name="user_settings22" type="checkbox" value=""></td>
		<td class="row_text" style="text-align:center;"><input class="checkboxes_styled" name="user_settings22" type="checkbox" value=""></td>
		<td class="row_text" style="text-align:center;"><input class="checkboxes_styled" name="user_settings22" type="checkbox" value=""></td>
		<td class="row_text" style="text-align:center;"><input class="checkboxes_styled" name="user_settings22_admin" type="checkbox" value=""></td>
	</tr>



	<tr>
		<td class="section_sub_title" colspan="100%">Profile Group 3</td>
	</tr>
	<tr>
		<td class="row_text" nowrap>User Name</td>
		<td class="row_text" style="text-align:center;"><input class="checkboxes_styled" name="user_settings31" type="checkbox" value="" onClick="checkAll(document.myform.user_settings31,this)"></td>
		<td class="row_text" style="text-align:center;"><input class="checkboxes_styled" name="user_settings31" type="checkbox" value=""></td>
		<td class="row_text" style="text-align:center;"><input class="checkboxes_styled" name="user_settings31" type="checkbox" value=""></td>
		<td class="row_text" style="text-align:center;"><input class="checkboxes_styled" name="user_settings31" type="checkbox" value=""></td>
		<td class="row_text" style="text-align:center;"><input class="checkboxes_styled" name="user_settings31" type="checkbox" value=""></td>
		<td class="row_text" style="text-align:center;"><input class="checkboxes_styled" name="user_settings31" type="checkbox" value=""></td>
		<td class="row_text" style="text-align:center;"><input class="checkboxes_styled" name="user_settings31_admin" type="checkbox" value=""></td>
	</tr>
	<tr>
		<td class="row_text" nowrap>User Name</td>
		<td class="row_text" style="text-align:center;"><input class="checkboxes_styled" name="user_settings32" type="checkbox" value=""onClick="checkAll(document.myform.user_settings32,this)"></td>
		<td class="row_text" style="text-align:center;"><input class="checkboxes_styled" name="user_settings32" type="checkbox" value=""></td>
		<td class="row_text" style="text-align:center;"><input class="checkboxes_styled" name="user_settings32" type="checkbox" value=""></td>
		<td class="row_text" style="text-align:center;"><input class="checkboxes_styled" name="user_settings32" type="checkbox" value=""></td>
		<td class="row_text" style="text-align:center;"><input class="checkboxes_styled" name="user_settings32" type="checkbox" value=""></td>
		<td class="row_text" style="text-align:center;"><input class="checkboxes_styled" name="user_settings32" type="checkbox" value=""></td>
		<td class="row_text" style="text-align:center;"><input class="checkboxes_styled" name="user_settings32_admin" type="checkbox" value=""></td>
	</tr>


</table>

<br /><br />


<table cellpadding="0" cellspacing="0" align="center" class="data_table">

	<tr>
		<td class="section_title" colspan="100%">Dashboard Administrators are able to...</td>
	</tr>

	<tr>
		<td class="column_title">&nbsp;</td>
		<td class="column_title">No</td>
		<td class="column_title">Yes</td>
	</tr>
	<tr>
		<td class="row_text" style="border-bottom:1px #666666 dotted;" width="65%">Change all rights off all users</td>
		<td class="row_text row_text_centered" style="border-bottom:1px #666666 dotted;"><input name="AA_1" onclick="if(AA_2.checked)AA_2.checked=!this.checked" type="checkbox" class="radiobuttons_styled" checked></td>
		<td class="row_text row_text_centered" style="border-bottom:1px #666666 dotted;"><input name="AA_2" onclick="if(AA_1.checked)AA_1.checked=!this.checked" type="checkbox" class="radiobuttons_styled"></td>
	</tr>
	<tr>
		<td class="row_text">Change the default Unit Of Measure used by the dahsboards</td>
		<td class="row_text row_text_centered"><input name="BB_1" onclick="if(BB_1.checked)BB_2.checked=!this.checked" type="checkbox" class="radiobuttons_styled" checked></td>
		<td class="row_text row_text_centered"><input name="BB_2" onclick="if(BB_2.checked)BB_1.checked=!this.checked" type="checkbox" class="radiobuttons_styled"></td>
	</tr>

	<tr>
		<td class="row_text">Grant access to Budgets' Dashboards</td>
		<td class="row_text row_text_centered"><input name="CC_1" onclick="if(CC_1.checked)CC_2.checked=!this.checked" type="checkbox" class="radiobuttons_styled" checked></td>
		<td class="row_text row_text_centered"><input name="CC_2" onclick="if(CC_2.checked)CC_1.checked=!this.checked" type="checkbox" class="radiobuttons_styled"></td>
	</tr>
	<tr>
		<td class="row_text">Grant access to Billbacks' Dashboards</td>
		<td class="row_text row_text_centered"><input name="DD_1" onclick="if(DD_1.checked)DD_2.checked=!this.checked" type="checkbox" class="radiobuttons_styled" checked></td>
		<td class="row_text row_text_centered"><input name="DD_2" onclick="if(DD_2.checked)DD_1.checked=!this.checked" type="checkbox" class="radiobuttons_styled"></td>
	</tr>
	<tr>
		<td class="row_text">Grant access to Sales' Dashboards</td>
		<td class="row_text row_text_centered"><input name="EE_1" onclick="if(EE_1.checked)EE_2.checked=!this.checked" type="checkbox" class="radiobuttons_styled" checked></td>
		<td class="row_text row_text_centered"><input name="EE_2" onclick="if(EE_2.checked)EE_1.checked=!this.checked" type="checkbox" class="radiobuttons_styled"></td>
	</tr>
	<tr>
		<td class="row_text">Deny access to Budgets' Dashboards</td>
		<td class="row_text row_text_centered"><input name="FF_1" onclick="if(FF_1.checked)FF_2.checked=!this.checked" type="checkbox" class="radiobuttons_styled" checked></td>
		<td class="row_text row_text_centered"><input name="FF_2" onclick="if(FF_2.checked)FF_1.checked=!this.checked" type="checkbox" class="radiobuttons_styled"></td>
	</tr>
	<tr>
		<td class="row_text">Deny access to Billbacks' Dashboards</td>
		<td class="row_text row_text_centered"><input name="GG_1" onclick="if(GG_1.checked)GG_2.checked=!this.checked" type="checkbox" class="radiobuttons_styled" checked></td>
		<td class="row_text row_text_centered"><input name="GG_2" onclick="if(GG_2.checked)GG_1.checked=!this.checked" type="checkbox" class="radiobuttons_styled"></td>
	</tr>
	<tr>
		<td class="row_text">Deny access to Sales' Dashboards</td>
		<td class="row_text row_text_centered"><input name="II_1" onclick="if(II_1.checked)II_2.checked=!this.checked" type="checkbox" class="radiobuttons_styled" checked></td>
		<td class="row_text row_text_centered"><input name="II_2" onclick="if(II_2.checked)II_1.checked=!this.checked" type="checkbox" class="radiobuttons_styled"></td>
	</tr>
</table>


</form>

<br />

</div>


<!--- ----------------------------------------------------------------------------------------- --->