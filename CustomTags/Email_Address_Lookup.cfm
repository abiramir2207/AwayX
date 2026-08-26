<!------ Get application settings ----->
		<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
		<cfset appSettings = genSettingsManager.get()>

<!------Email_Address_Lookup.cfm----->
<CFPARAM NAME="Attributes.Destination_Form_Name" 	DEFAULT="">
<CFPARAM NAME="Attributes.Destination_Field_Name" 	DEFAULT="">
<CFPARAM NAME="Attributes.Width" 	DEFAULT="200">
<CFPARAM NAME="Attributes.Size" 	DEFAULT="5">
<CFPARAM NAME="Attributes.Alert" 	DEFAULT="false">
<CFPARAM NAME="Attributes.sort" 	DEFAULT="name_last"><!--- name_last --->
<cfset Attributes.sort = "name_last" />

<CFSET Attributes.Destination_Form_Name 	= Trim(Attributes.Destination_Form_Name)>
<CFSET Attributes.Destination_Field_Name 	= Trim(Attributes.Destination_Field_Name)>
<CFIF LCase(Attributes.Alert) NEQ "false">
	<CFSET Attributes.Alert = "true">
</CFIF>

<CFIF Attributes.Destination_Form_Name EQ "" OR Attributes.Destination_Field_Name EQ "">
	<CFEXIT>
</CFIF>

<CFQUERY NAME="E_getEmailAddress" datasource="#application.datasource#" cachedwithin="#CreateTimeSpan(0, 0, 0, 15)#">
	Create TABLE  ##tmp_eMail_ordered (
	EmailOrderNumber int IDENTITY (1, 1),
	User_Email varchar(50) NULL,
	Name_Last varchar(50) NULL,
	Name_first varchar(50) NULL)
	
	Insert ##tmp_eMail_ordered
	Select	DISTINCT User_Email, Name_Last, Name_first
		From	_Users
		Where	
				User_Email <> '' 
				AND 
				Deleted=0
		Order By User_Email
	
	SELECT	DISTINCT 
		U.User_Email, 
		U.Name_Last, 
		U.Name_first, 
		Tmp.EmailOrderNumber
		From	_Users U
		JOIN ##tmp_eMail_ordered Tmp ON
			Tmp.User_Email = U.User_Email AND
			Tmp.Name_Last = U.Name_Last AND
			Tmp.Name_first = U.Name_first
		WHERE	
				U.User_Email <> '' 
				AND 
				Deleted=0
		<!---Don't show BSA users --->
	<cfif IsDefined("appSettings.getHide_BSA_Users") AND appSettings.getHide_BSA_Users() IS 1>
	AND (U.User_Rights_ID IS NULL 
		OR U.User_Rights_ID != 9999)
	</cfif>
		Order BY U.name_last
	
	DROP table ##tmp_eMail_ordered
	
	

</CFQUERY>


<CFOUTPUT>
<CFIF NOT IsDefined("Caller.E_Email_Address_Lookup_JScript_Added")>
	<SCRIPT LANGUAGE="JavaScript">
		function add_Recipients(bType, thisObj, formName, fieldName, bAlert)
		{
			var emailObj = thisObj.form.E_User_Email_Address;
			var destObj;
			eval("destObj = document." + formName + "." + fieldName + ";");
			var user_Email;
			var emailString = "";
			if(bType == 0)
			{
				if(emailObj.selectedIndex > -1)
				{
					user_Email = emailObj.value;
					emailString = getEmail(destObj, user_Email, bAlert);
				}
			}
			else if(bType == -1)
			{
				for(var i=0;i<emailObj.options.length;i++)
				{
					user_Email = emailObj.options[i].value;
					if(emailString.length == 0)
					{
						emailString = getEmail(destObj, user_Email, false);
					}
					else
					{
						emailString = emailString + ";" + getEmail(destObj, user_Email, false);
					}					
				}
			}
			if(emailString.length > 0)
			{
				addThisEmail(destObj, emailString);
			}
		}
		
		
		function addThisEmail(emailObj, thisEmail)
		{
			var eValue = emailObj.value;
			if(eValue.length == 0)
			{
				emailObj.value = thisEmail;
			}
			else
			{
				var re = new RegExp(".*?; *?$","ig");
				if(re.test(eValue))
				{
					emailObj.value = eValue + thisEmail;
				}
				else
				{
					emailObj.value = eValue + ";" + thisEmail;
				}				
			}	
		}
		
		function getEmail(emailObj, thisEmail, bAlert)
		{
			var eValue = emailObj.value;
			var re = new RegExp(thisEmail,"ig");
			
			if(re.test(eValue))
			{
				if(bAlert)
				{
					alert(thisEmail + " already exist");
				}				
			}
			else
			{  
				return thisEmail;						
			}
			return "";
		}
		
		function delete_Recipients(bType, thisObj, formName, fieldName, bAlert)
		{
			var destObj;
			eval("destObj = document." + formName + "." + fieldName + ";");
			if(bType == 0)
			{
				/*
				var objSelectionRange = document.selection.createRange();
				if (objSelectionRange != null)
				{
					objSelectionRange.expand("word");
					objSelectionRange.select();
					loopEachToken(destObj, objSelectionRange);
				}
				*/
			}
			else if(bType == -1)
			{
				destObj.value = "";
			}			
		}
		
		function loopEachToken(txtObj, objSelectionRange)
		{
			var rng = txtObj.createTextRange();
			rng.moveToElementText(txtObj);
			rng.collapse();
			var i, found;
			for (i = 0; (found = rng.findText(";")) != false; i++) 
			{
				if(rng.inRange(objSelectionRange))
				{
					alert("aa");
					break;
				}
				if(i<5)
				{
					alert(rng.text);
				}
				rng.moveStart("character", 1);
				rng.moveEnd("textedit");
			}			
		}
	</SCRIPT>
	


<script language="JavaScript1.1"><!--
function deleteOption(object,index) {
    object.options[index] = null;
}

function addOption(object,text,value,id,title) {
    var defaultSelected = false;
    var selected = false;
    var optionName = new Option(text, value, defaultSelected, selected, id, title)  
    object.options[object.length] = optionName;
	object.options[object.length-1].id = id;
	object.options[object.length-1].title = title;
	//object.options[object.length-1].label = label;
    //object.options[object.length-1].selected = false;
	//document.all.test.innerText = object.options[object.length-1].id + '@@' + text + value + '@@' + id + title;
    
}

function sortOptionslast(what) {
    var copyOption = new Array();
    for (var i=0;i<what.options.length;i++)
		{
        copyOption[i] = new Array(what[i].id,what[i].text,what[i].value,what[i].title);
		}
  		copyOption.sort(function(a,b) { return a[0]-b[0]; });

    for (var i=what.options.length-1;i>-1;i--)//(var i=0;i<copyOption.length;i++)
       	 {deleteOption(what,i);}
		
    		for (var i=0;i<copyOption.length;i++)
				{
				    addOption(what,copyOption[i][1],copyOption[i][2],copyOption[i][0],copyOption[i][3]);  
					//document.all.test.innerText = i;
					//var stuffa = eval(copyOption[i][1]) + eval(copyOption[i][2]) + eval(copyOption[i][0]) + eval(copyOption[i][3]) + 'z';
					//document.all.test.innerText = stuffa;
				}
				
}

function sortOptionsemail(what) {
    var copyOption = new Array();
    for (var i=0;i<what.options.length;i++)
		{
        copyOption[i] = new Array(what[i].title,what[i].text,what[i].value,what[i].id);  
		}

    copyOption.sort(function(a,b) { return a[0]-b[0]; });

    for (var i=what.options.length-1;i>-1;i--)
        {deleteOption(what,i);}

    for (var i=0;i<copyOption.length;i++)
        {addOption(what,copyOption[i][1],copyOption[i][2],copyOption[i][3],copyOption[i][0]);} 
		
		//var stuff = eval(copyOption[i][1] + copyOption[i][2] + copyOption[i][3] + copyOption[i][0]);
		//document.all.test.innerText = stuff; 
		
}
//--></script>
	
	
	<CFSET Caller.E_Email_Address_Lookup_JScript_Added = true>
</CFIF>
</CFOUTPUT>
<TABLE CELLSPACING="0" CELLPADDING="0" BORDER="0">
	<TR>
		<TD>&nbsp;
		</TD>
		<TD>
		<CFOUTPUT>
		<TABLE CELLPADDING="2" CELLSPACING="0">
		<TR>
			<TD>
			<INPUT NAME="AddEmailButton" TYPE="BUTTON" TITLE="Add selected email address" STYLE="width:30px;" VALUE="<" onClick="javaScript: add_Recipients(0,this,'#Attributes.Destination_Form_Name#','#Attributes.Destination_Field_Name#',#Attributes.Alert#)">
			</TD>
		</TR>
		<TR>
			<TD>
			<INPUT TYPE="BUTTON" TITLE="Add all email addresses" STYLE="width:30px;" VALUE="<<" onClick="javaScript: add_Recipients(-1,this,'#Attributes.Destination_Form_Name#','#Attributes.Destination_Field_Name#',#Attributes.Alert#)">
			</TD>
		</TR>
		<TR>
			<TD>
			<INPUT TYPE="BUTTON" TITLE="Delete all email address" STYLE="width:30px;" VALUE=">>" onClick="javaScript: delete_Recipients(-1,this,'#Attributes.Destination_Form_Name#','#Attributes.Destination_Field_Name#',#Attributes.Alert#)">
			</TD>
		</TR>
		<!--- <TR><TD><span id="test">&nbsp;xx</span></TD></TR> --->
		</TABLE>
		<!---<INPUT TYPE="BUTTON" STYLE="width:20px;" VALUE=">" onClick="javaScript: delete_Recipients(0,this,'#Attributes.Destination_Form_Name#','#Attributes.Destination_Field_Name#',#Attributes.Alert#)">---->
		</CFOUTPUT>
		</TD>
		<TD ROWSPAN="2">
		&nbsp;
		<SELECT ONDBLCLICK="document.all.AddEmailButton.click();" NAME="E_User_Email_Address" STYLE="WIDTH:<CFOUTPUT>#Attributes.Width#</CFOUTPUT>" SIZE="<CFOUTPUT>#Attributes.Size#</CFOUTPUT>">
			<CFOUTPUT QUERY="E_getEmailAddress">
				<OPTION VALUE="#User_Email#" id="#E_getEmailAddress.currentRow#" title="#E_getEmailAddress.EmailOrderNumber#">#Name_Last#  ::  #Name_First#  ::  #User_Email#</OPTION>
			</CFOUTPUT>		
		</SELECT>
		</TD>
	</TR>
</TABLE>
