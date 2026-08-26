<CF_MessageWindow>
<script src="/script/javascript/string_functions.js"></script>

<script language="javascript">
/* Populate the "From" bracket text boxes, based on the previous "To" value */
function PopulateValues()
{
var To_BracketValue;
var From_NextBracketValue;
var To_NextBracketValue;
var LastOcccuranceOfDash;
var j;
var m;
j = 0;
m = 0;

// Loop through the form
 for (var i=0;i<frmFreightBracket.length;i++)
 {	
 	var name_=frmFreightBracket[i].name; // get element name 
	if(name_.indexOf('txtTo_')!=-1)
	{	
		m = m+1;
 		j = m+1;
 		
 		// Get the "To" Bracket value of the current textbox
 		To_BracketValue = document.getElementById('txtTo_'+m).value;
 		 
 		/* The next "From" Bracket value will be a number higher than the "To" value, provided there is no
 			"*" on the textbox. It is for the last textbox (txtTo field)
 		*/ 
 		if(document.getElementById('txtFrom_'+j) && (To_BracketValue != '' && To_BracketValue.indexOf('*') == -1 && isNaN(parseInt(To_BracketValue)) == false))
 		{		
 			document.getElementById('txtFrom_'+j).value = parseInt(To_BracketValue) + parseInt(1);
 		}
 		// If the "To" value is removed, then remove the next "From" value too
 		else
 		{
 			if(document.getElementById('txtFrom_'+j))
 			{
 				document.getElementById('txtFrom_'+j).value = '';
 			}			
 		}
	}
 }
}

//Validate the form on submission
function CheckErrors()
{
 var BracketMessage;
 var ErrorCount;
 var BracketCount;
 var m;
 BracketMessage ="Do you accept the following brackets:";
 ErrorCount = 0;
 BracketCount = 0;
 m=0;
 
	// If the first entry is not complete
	if(document.getElementById('txtCode_1').value == ''  && document.getElementById('txtLabel_1').value == '' 
	&& document.getElementById('txtTo_1').value == '')
	{
		ErrorCount++;
		queueMessage("Please complete this entry", document.all.error_txtID_1);
	}
	else
 	{
		clearQueue(document.all.error_txtID_1);
	}
	
 // Loop through the form
 for (var i=0;i<frmFreightBracket.length;i++)
 {	
 	
 	var name_=frmFreightBracket[i].name; // get element name 
 	/* It could be any field. I have chosen 'txtTo_' arbitrarily.*/ 
	if(name_.indexOf('txtTo_')!=-1)
	{	
		m = m+1;
	/* If txtCode is entered for that row (I think 'txtCode' is a good candidate here, as it is the unique
		key for the user)
	*/
	if(document.getElementById('txtCode_'+m).value !='')
	{
	BracketMessage = BracketMessage + "\n"+m+": "+document.getElementById('txtFrom_'+m).value+" - "+document.getElementById('txtTo_'+m).value;
	BracketCount = BracketCount + 1;
	}
	// If any of the entries are incomplete, i.e., if you fill one, you have to fill the rest.
  	if
  	(
  	(document.getElementById('txtCode_'+m).value != '' && (document.getElementById('txtLabel_'+m).value == ''
  	|| document.getElementById('txtTo_'+m).value == ''))
  		|| 
  	(document.getElementById('txtLabel_'+m).value != '' && (document.getElementById('txtCode_'+m).value == ''
  	|| document.getElementById('txtTo_'+m).value == ''))
  		|| 
  	(document.getElementById('txtTo_'+m).value != '' && (document.getElementById('txtCode_'+m).value == ''
  	|| document.getElementById('txtLabel_'+m).value == ''))	
  	)
	{
		ErrorCount++;
		queueMessage("Please complete this entry", eval('document.all.error_txtID_'+m));
	}
	else
 	{
		clearQueue(eval('document.all.error_txtID_'+m));
	}
		
		To_BracketValue = document.getElementById('txtTo_'+m).value;
		
		// Make sure that the "To" value of an entry is always higher than the "From" value
 		if(document.getElementById('txtFrom_'+m) && To_BracketValue != '')
 		{		
 		From_NextBracketValue = parseInt(document.getElementById('txtFrom_'+m).value);
 		To_NextBracketValue = parseInt(document.getElementById('txtTo_'+m).value);

 			if(To_NextBracketValue < From_NextBracketValue)
 			{
 				ErrorCount++;
 				document.getElementById('txtTo_'+m).focus();
 				queueMessage("To (Upper Limit) must be greater than From (Lower Limit)", eval('document.all.error_txtTo_'+m));
 			}
 			else
 			{
				clearQueue(eval('document.all.error_txtTo_'+m));
			}	
 		}
	}
  }
  
  /* Now since we have the total bracket count. We can loop through those fields to
  	make sure that all the bracket counts are numeric, except the last one, 
  	which could have a "*" too
  */
  for(i=1;i<=BracketCount;i++)
  {
  	// For all the brackets, except the last one
  	if(i < BracketCount)
  	{	
  		if(isNumeric(document.getElementById('txtTo_'+i).value) == false)
  		{
  			ErrorCount++;
  			queueMessage("The value entered must be numeric", eval('document.all.error_txtTo_Num_'+i));
  		}
  		else
 		{
			clearQueue(eval('document.all.error_txtTo_Num_'+i));
		}	
  	}
  	// For the last bracket
  	else
  	{
  		if(document.getElementById('txtTo_'+i).value != '*' && isNumeric(document.getElementById('txtTo_'+i).value) == false)
  		{
  			ErrorCount++;
  			queueMessage("The value entered must be either a numeric or a *", eval('document.all.error_txtTo_Num_'+i));
  		}
  		else
 		{
			clearQueue(eval('document.all.error_txtTo_Num_'+i));
		}
  	
  	}
  	
  }
  
  // If no errors are found
  if(ErrorCount == 0) 
  {
  	//Find the last occurance of dash and replace the last "To" value with a "*"
  	LastOcccuranceOfDash = BracketMessage.lastIndexOf('-') + 1;
  	if(BracketMessage.indexOf('*'))
  	{
  		if (confirm(BracketMessage.substring(0,LastOcccuranceOfDash) + " *"))
  		{
  		frmFreightBracket.submit();
  		}
  	}
  } 	
  else
  {
  	 showMessageWindow();
  }
 }
 
 /* Add a new freight bracket field, on request by the user */
	function AddBracket(FreightBracketStart)
	{
		for(i=FreightBracketStart;i<=20;i++)
		{
			DisplayObject = document.getElementById('Bracket_ID_'+i)
				if(DisplayObject.style.display == 'none'){
					DisplayObject.style.display = ''
					break;
				}
		}
	}
</script>

<cfset FreightBracketObj = CreateObject("component","components.freight.FreightBracketSetting") />

<!--- Get the freight brackets info --->
<cfset qryFreightBracketObj = FreightBracketObj.getFreightBracketInfo() />

<!--- Get the freight settings info --->
<cfset qryFreightSettingsObj = FreightBracketObj.getFreightSettings() />

<body onfocus="PopulateValues()">
	
<cfif qryFreightBracketObj.recordcount neq 0>	
<br />
<TABLE BGCOLOR="White" style="border-color:Orange;border-style:solid;" CELLPADDING="3" CELLSPACING="0">
<TR>
<TD>
	<FONT SIZE="2"><B><cfoutput>The settings were last updated on #dateformat(qryFreightBracketObj.Freight_Bracket_Created_Date, 'mm/dd/yyyy')# #timeformat(qryFreightBracketObj.Freight_Bracket_Created_Date, 'hh:mm:ss TT')# by #qryFreightBracketObj.User_Modifier#</cfoutput></B></FONT>	</TD>
</TD>
</TR>
</TABLE>
</cfif>
<br />
<table>
	<tr>
		<td><b>ID</b></td>
		<td><b>Code</b></td>
		<td><b>Label</b></td>
		<td><b>From</b></td>
		<td><b>To</b></td>
	</tr>
	<form name="frmFreightBracket" method="post" action="freight_bracket_settings_action.cfm">
	<!--- If there are no freight bracket entries. By default, there are 6 entries --->
	
	<cfif qryFreightBracketObj.recordcount eq 0>
	<cfset FreightBracketObjCount = 7>
		<cfoutput>
		<cfloop from="1" to="6" index="i">
		 <tr>
			<td><span id="error_txtID_#i#"></span><input type="text" name="txtID_#i#" id="txtID_#i#" size="1" value="#i#" style="background-color: cccccc" READONLY></td>
			<td><input type="text" name="txtCode_#i#" id="txtCode_#i#" size="15" maxlength="15"></td>
			<td><input type="text" name="txtLabel_#i#" id="txtLabel_#i#" value="" size="17" maxlength="10"></td>
			<td><input type="text" name="txtFrom_#i#" id="txtFrom_#i#" <cfif i neq 1>style="background-color: cccccc" READONLY</cfif> size="5" maxlength="10"></td>
			<td><span id="error_txtTo_#i#"></span><span id="error_txtTo_Num_#i#"></span><input type="text" name="txtTo_#i#" id="txtTo_#i#" value="" size="5" maxlength="10"  OnKeyPress="javaScript: return Allow_Key_List('0123456789*');" OnBlur="PopulateValues()" OnFocus="PopulateValues()"></td>
		 </tr>
		</cfloop>
		</cfoutput>
	<cfelse>
	<cfset FreightBracketObjCount = qryFreightBracketObj.Recordcount + 1>
	<!--- If there are saved entries --->
		<cfoutput query="qryFreightBracketObj">
		 <tr>
			<td><span id="error_txtID_#Freight_Bracket_Setting_ID#"></span><input type="text" name="txtID_#Freight_Bracket_Setting_ID#" id="txtID_#Freight_Bracket_Setting_ID#" value="#Freight_Bracket_Setting_ID#" size="1" style="background-color: cccccc" READONLY></td>
			<td><input type="text" name="txtCode_#Freight_Bracket_Setting_ID#" id="txtCode_#Freight_Bracket_Setting_ID#"  value="#Freight_Bracket_Code#" size="15" maxlength="15"></td>
			<td><input type="text" name="txtLabel_#Freight_Bracket_Setting_ID#" id="txtLabel_#Freight_Bracket_Setting_ID#"  value="#Freight_Bracket_Label#" size="17" maxlength="10"></td>
			<td><input type="text" name="txtFrom_#Freight_Bracket_Setting_ID#" id="txtFrom_#Freight_Bracket_Setting_ID#"  value="#Freight_Bracket_From#" size="5" maxlength="10"  <cfif Freight_Bracket_Setting_ID neq 1>style="background-color: cccccc" READONLY</cfif>></td>
			<td><span id="error_txtTo_#Freight_Bracket_Setting_ID#"></span><span id="error_txtTo_Num_#Freight_Bracket_Setting_ID#"></span><input type="text" name="txtTo_#Freight_Bracket_Setting_ID#" id="txtTo_#Freight_Bracket_Setting_ID#"  value="#Freight_Bracket_To#" size="5" maxlength="10"  OnKeyPress="javaScript: return Allow_Key_List('0123456789*');"  OnBlur="PopulateValues()" OnFocus="PopulateValues()"></td>
		 </tr>
		</cfoutput>
	</cfif>
	
	<!--- I have arbitrarily chosen a number (20). I have that many rows for bracket freights. I am 
		  only showing them on request by the user (click on the "Add a bracket" link) --->
		<cfif FreightBracketObjCount LT 20>
		<cfoutput>
		<cfloop from="#FreightBracketObjCount#" to="20" index="i">
		 <tr style="display:none" id="Bracket_ID_#i#">
			<td><span id="error_txtID_#i#"></span><input type="text" name="txtID_#i#" id="txtID_#i#" size="1" value="#i#" style="background-color: cccccc" READONLY></td>
			<td><input type="text" name="txtCode_#i#" id="txtCode_#i#" size="15" maxlength="15"></td>
			<td><input type="text" name="txtLabel_#i#" id="txtLabel_#i#" value="" size="17" maxlength="10"></td>
			<td><input type="text" name="txtFrom_#i#" id="txtFrom_#i#" <cfif i eq 1> value="0" <cfelse> value="" </cfif> size="5" maxlength="10"  style="background-color: cccccc" READONLY></td>
			<td><span id="error_txtTo_#i#"></span><span id="error_txtTo_Num_#i#"></span><input type="text" name="txtTo_#i#" id="txtTo_#i#" value="" size="5" maxlength="10"  OnKeyPress="javaScript: return Allow_Key_List('0123456789*');" OnBlur="PopulateValues()" OnFocus="PopulateValues()"></td>
		 </tr>
		</cfloop>
		</cfoutput>
		</cfif>
		
	<cfoutput>
	<tr>
		<td colspan="5"><input type="checkbox" name="chkCalculateInvoice" value="1" <cfif qryFreightSettingsObj.Recalculate_Invoice_Table_Brackets eq 1>checked</cfif>><b>Recalculate invoice brackets</b></td>
	</tr>
	<tr>
		<td><B><span style="color:FF0000">[</span> <a href="javascript:CheckErrors();">Save</a> <span style="color:FF0000">]</span></B></td>
		<td colspan="4"><B><span style="color:FF0000">[</span><a href="javascript:void(0);" onClick="AddBracket('#FreightBracketObjCount#')">Add a bracket</a><span style="color:FF0000"> ]</span></B></td>		
	</tr>
	</cfoutput>
	</form>
</table>
</body>