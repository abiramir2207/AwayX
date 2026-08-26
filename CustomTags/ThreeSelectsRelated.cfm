<!--- REMOVE THIS AND FIRST LINE IF NOT USING CF3.1 OR LATER --->
<CFSETTING ENABLECFOUTPUTONLY="YES">

<!--- TAG PARAMETERS --->
<CFPARAM NAME="Attributes.Query">  
<CFPARAM NAME="Attributes.Display1">
<CFPARAM NAME="Attributes.Display2">
<CFPARAM NAME="Attributes.Display3">
<CFPARAM NAME="Attributes.Value1" DEFAULT="#Attributes.Display1#">
<CFPARAM NAME="Attributes.Value2" DEFAULT="#Attributes.Display2#">
<CFPARAM NAME="Attributes.Value3" DEFAULT="#Attributes.Display3#">
<CFPARAM NAME="Attributes.Name1" DEFAULT="TwoSelectsRelated1">
<CFPARAM NAME="Attributes.Name2" DEFAULT="TwoSelectsRelated2">
<CFPARAM NAME="Attributes.Name3" DEFAULT="TwoSelectsRelated3">
<CFPARAM NAME="Attributes.TITLE1" DEFAULT="">
<CFPARAM NAME="Attributes.TITLE2" DEFAULT="">
<CFPARAM NAME="Attributes.TITLE3" DEFAULT="">
<CFPARAM NAME="Attributes.Size1" DEFAULT="1">
<CFPARAM NAME="Attributes.Size2" DEFAULT="1">
<CFPARAM NAME="Attributes.Size3" DEFAULT="1">
<CFPARAM NAME="Attributes.Width1" DEFAULT="">
<CFPARAM NAME="Attributes.Width2" DEFAULT="">
<CFPARAM NAME="Attributes.Width3" DEFAULT="">
<CFPARAM NAME="Attributes.ForceWidth1" DEFAULT="275">
<CFPARAM NAME="Attributes.ForceWidth2" DEFAULT="275">
<CFPARAM NAME="Attributes.ForceWidth3" DEFAULT="275">
<CFPARAM NAME="Attributes.ForceWidthChar" DEFAULT="&nbsp;">
<CFPARAM NAME="Attributes.EmptyText1" DEFAULT="">
<CFPARAM NAME="Attributes.EmptyText2" DEFAULT="">
<CFPARAM NAME="Attributes.EmptyText3" DEFAULT="">
<CFPARAM NAME="Attributes.Message1" DEFAULT="You must choose an option for #Attributes.Name1#.">
<CFPARAM NAME="Attributes.Message2" DEFAULT="You must choose an option for #Attributes.Name2#.">
<CFPARAM NAME="Attributes.Message3" DEFAULT="You must choose an option for #Attributes.Name3#.">
<CFPARAM NAME="Attributes.FormName" DEFAULT="forms[0]">
<CFPARAM NAME="Attributes.HTMLBetween1" DEFAULT="">
<CFPARAM NAME="Attributes.HTMLBetween1" DEFAULT="">
<CFPARAM NAME="Attributes.OnChange" DEFAULT="">
<CFPARAM NAME="Attributes.AutoSelectFirst" DEFAULT="Yes">
<CFPARAM NAME="Attributes.DataSource" DEFAULT="">
<CFPARAM NAME="Attributes.DataSource_ReturnVariableName" DEFAULT="">


<!--- This was added so that it allows more than one pair of 2 selects related per form --->
<!--- The name of the function called now dynamically takes the the name of the select box as an attribute --->
<CFSET FunctionName1 = ReplaceList(Attributes.FormName, "[,]", ",") & Attributes.Name1 & "ChangeMenu()">

<CFSET FunctionName2 = ReplaceList(Attributes.FormName, "[,]", ",") & Attributes.Name1 & "ChangeMenu_2()">

<!--- 
This was the original. Only allowed 1, 2selectsrelated per form
<CFSET FunctionName = ReplaceList(Attributes.FormName, "[,]", ",") & "ChangeMenu()">
 --->





<!--- "MAGIC" SHORTCUTS FOR THE ONCHANGE HANDLER --->
<CFIF Attributes.OnChange is "Jump!">
  <CFSET Attributes.OnChange = "document.location = this.options[selectedIndex].value;">
<CFELSEIF Attributes.OnChange is "Submit!">
  <CFSET Attributes.OnChange = "this.form.submit();">
</CFIF>



<!--- USE PASSED QUERY WITHIN THIS CODE AS "MyQuery" --->
<CFSET MyQuery = Evaluate("Caller.#Attributes.Query#")>

<!--- BEGIN JAVASCRIPTING --->
<CFOUTPUT><SCRIPT LANGUAGE="JavaScript1.1"></CFOUTPUT>
<CFOUTPUT>
function addEmptyEntry(srcArray, level)
{
	var this_Level_Empty_Val = new Array();	
	if(level == 1)
	{
	<CFIF Attributes.EmptyText1 is not "">		
		this_Level_Empty_Val[0] = '';
		this_Level_Empty_Val[1] = '#JSStringFormat(Attributes.EmptyText1)#';
		this_Level_Empty_Val[2] = new Array();
		srcArray[srcArray.length] = this_Level_Empty_Val;
	</CFIF>
	}
	if(level == 2)
	{
	<CFIF Attributes.EmptyText2 is not "">		
		this_Level_Empty_Val[0] = '';
		this_Level_Empty_Val[1] = '#JSStringFormat(Attributes.EmptyText2)#';
		this_Level_Empty_Val[2] = new Array();
		srcArray[srcArray.length] = this_Level_Empty_Val;
	</CFIF>
	}
	if(level == 3)
	{
	<CFIF Attributes.EmptyText3 is not "">		
		this_Level_Empty_Val[0] = '';
		this_Level_Empty_Val[1] = '#JSStringFormat(Attributes.EmptyText3)#';
		srcArray[srcArray.length] = this_Level_Empty_Val;
	</CFIF>
	}
	return srcArray;
}
</CFOUTPUT>


<CFIF Attributes.DataSource EQ "">
<CFOUTPUT>var #Attributes.Name1#_Select_Values = new Array();</CFOUTPUT>
<CFOUTPUT>
<CFSET D_Counter = 0>
var thisLevel_Add_Empty_Obj = #Attributes.Name1#_Select_Values;
if(thisLevel_Add_Empty_Obj)
{
	thisLevel_Add_Empty_Obj = addEmptyEntry(thisLevel_Add_Empty_Obj, 1);
	
	if(thisLevel_Add_Empty_Obj.length > 0)
	{
		thisLevel_Add_Empty_Obj = thisLevel_Add_Empty_Obj[thisLevel_Add_Empty_Obj.length-1][2];
	}
	else
	{
		thisLevel_Add_Empty_Obj = null;
	}
	if(thisLevel_Add_Empty_Obj)
	{
		thisLevel_Add_Empty_Obj = addEmptyEntry(thisLevel_Add_Empty_Obj, 2);
		
		if(thisLevel_Add_Empty_Obj.length > 0)
		{
			thisLevel_Add_Empty_Obj = thisLevel_Add_Empty_Obj[thisLevel_Add_Empty_Obj.length-1][2];
		}
		else
		{
			thisLevel_Add_Empty_Obj = null;
		}
		if(thisLevel_Add_Empty_Obj)
		{
			thisLevel_Add_Empty_Obj = addEmptyEntry(thisLevel_Add_Empty_Obj, 3);
		}
	}
	
}


</CFOUTPUT>

<CFOUTPUT QUERY="MyQuery" GROUP="#Attributes.Display1#">
	var Level_1 = new Array();	
	Level_1[0] = '#JSStringFormat(Evaluate("#Attributes.Value1#"))#';
	Level_1[1] = '#JSStringFormat(Evaluate("#Attributes.Display1#"))#';
	var Level_2 = new Array();
	Level_2 = addEmptyEntry(Level_2, 2);
	<CFOUTPUT GROUP="#Attributes.Display2#">
		var this_Level_2 = new Array();
		this_Level_2[0] = '#JSStringFormat(Evaluate("#Attributes.Value2#"))#';
		this_Level_2[1] = '#JSStringFormat(Evaluate("#Attributes.Display2#"))#';
		var Level_3 = new Array();
		Level_3 = addEmptyEntry(Level_3, 3);
		<CFOUTPUT>
			var this_Level_3 = new Array();	
			this_Level_3[0] = '#JSStringFormat(Evaluate("#Attributes.Value3#"))#';
			this_Level_3[1] = '#JSStringFormat(Evaluate("#Attributes.Display3#"))#';
			Level_3[Level_3.length] = this_Level_3;
		</CFOUTPUT>
		this_Level_2[2] = Level_3;
		Level_2[Level_2.length] = this_Level_2;
	</CFOUTPUT>
	Level_1[2] = Level_2;
	#Attributes.Name1#_Select_Values[#Attributes.Name1#_Select_Values.length] = Level_1;
	<CFSET D_Counter = D_Counter + 1>
</CFOUTPUT>

<CFSET Attributes.DataSource = "#Attributes.Name1#_Select_Values">
</CFIF>

<CFIF Attributes.DataSource_ReturnVariableName NEQ "">
	<CFSET "Caller.#Attributes.DataSource_ReturnVariableName#" = Attributes.DataSource>
</CFIF>

<CFOUTPUT>
<CFSET JS_Function_Name = "#Attributes.FormName#_#Attributes.Name1#_Populate_Select_Box">
function #JS_Function_Name#(iLevel)
{
	var dataSource = #Attributes.DataSource#;
	if(iLevel < 1 || iLevel > 2)
		return;
	if(iLevel == 1)
	{
		var selObj = document.#Attributes.FormName#.#Attributes.Name2#;
		var parentSelObj1 = document.#Attributes.FormName#.#Attributes.Name1#;
		var selIndex1 = parentSelObj1.selectedIndex;
		var arObj = dataSource[selIndex1][2];
	}
	else if(iLevel == 2)
	{
		var selObj = document.#Attributes.FormName#.#Attributes.Name3#;
		var parentSelObj1 = document.#Attributes.FormName#.#Attributes.Name1#;		
		var selIndex1 = parentSelObj1.selectedIndex;
		var parentSelObj2 = document.#Attributes.FormName#.#Attributes.Name2#;
		var selIndex2 = parentSelObj2.selectedIndex;
		var arObj = dataSource[selIndex1][2][selIndex2][2];
	}
	
	lst = selObj.length;

	for (i = lst; i > 0; i--) 
	{
		selObj.options[i] = null;
	}
	
	for (i = 0; i < arObj.length; i++) 
	{
		var optObj = new Option(arObj[i][1]);
		optObj.value = arObj[i][0];
		selObj.options[i] = optObj;
	}
	if(iLevel == 1)
	{
		#JS_Function_Name#(2);
	}  
}


</SCRIPT>
</CFOUTPUT>
	

<!--- ALLOW FOR AUTO-SIZING "SHORTCUT" OF SELECT BOXES --->
<CFIF Attributes.Size1 is "Auto">
  <!--- MAKE THE FIRST SELECT BE BIG ENOUGH FOR ALL OF ITS OPTIONS --->
  <CFSET Attributes.Size1 = Counter>
</CFIF>
<CFIF Attributes.Size2 is "Auto">
  <!--- MAKE THE SECOND SELECT BE THE SAME SIZE AS THE FIRST --->
  <CFSET Attributes.Size2 = Attributes.Size1>
</CFIF>


<CFSET D_VALUE_1_LEN_SET = false>
<CFSET D_VALUE_2_LEN_SET = false>
<CFSET D_VALUE_1_LEN = 1>
<CFSET D_VALUE_2_LEN = 1>
<CFSET D_VALUE_1 = "">
<CFSET D_VALUE_2 = "">

<CFOUTPUT><TABLE CELLSPACING="0" CELLPADDING="0"><TR></CFOUTPUT>
<CFOUTPUT><TD></CFOUTPUT>
<CFIF Attributes.TITLE1 NEQ ""><CFOUTPUT><B>#Attributes.TITLE1#</B><BR></CFOUTPUT></CFIF>
<!----- Level 1 Select ---->
<CFOUTPUT><SELECT NAME="#Attributes.Name1#" onChange="#JS_Function_Name#(1);" SIZE="#Attributes.Size1#" STYLE="width:#Attributes.ForceWidth1#"></CFOUTPUT>
	<CFIF Attributes.EmptyText1 is not ""><CFOUTPUT><OPTION VALUE="">#Attributes.EmptyText1#</CFOUTPUT></CFIF>
	<CFOUTPUT QUERY="MyQuery" GROUP="#Attributes.Display1#">
	<CFSILENT>
		<CFIF CurrentRow EQ 1>
		<CFSET D_VALUE_1 = Evaluate(Attributes.Value1)>
	</CFIF>
	<CFIF NOT D_VALUE_1_LEN_SET AND CurrentRow GT 1>
		<CFSET D_VALUE_1_LEN_SET = true>
		<CFSET D_VALUE_1_LEN = CurrentRow - 1>
	</CFIF>
	</CFSILENT>
	<OPTION VALUE="#Evaluate(Attributes.Value1)#">#Evaluate(Attributes.Display1)#</CFOUTPUT>
<CFOUTPUT></SELECT></TD></CFOUTPUT>


<CFOUTPUT>#Attributes.HTMLBetween1#</CFOUTPUT>

<CFOUTPUT><TD></CFOUTPUT>
<CFIF Attributes.TITLE2 NEQ ""><CFOUTPUT><B>#Attributes.TITLE2#</B><BR></CFOUTPUT></CFIF>
<!----- Level 2 Select ---->
<CFOUTPUT><SELECT NAME="#Attributes.Name2#" onChange="#JS_Function_Name#(2);" SIZE="#Attributes.Size2#" <CFIF Attributes.onChange is not "">onChange="#Attributes.OnChange#"</CFIF> STYLE="width:#Attributes.ForceWidth2#"></CFOUTPUT>
	<CFIF Attributes.EmptyText2 is not ""><CFOUTPUT><OPTION VALUE="">#Attributes.EmptyText2#</CFOUTPUT></CFIF>
	<CFIF Attributes.EmptyText1 is "">		
		<CFOUTPUT QUERY="MyQuery" GROUP="#Attributes.Display2#" STARTROW="1" MAXROWS="#D_VALUE_1_LEN#">		
		<CFIF D_VALUE_1 EQ Evaluate(Attributes.Value1)>
		<CFSILENT>
		<CFIF CurrentRow EQ 1>
		<CFSET D_VALUE_2 = Evaluate(Attributes.Value2)>
		</CFIF>
		<CFIF NOT D_VALUE_2_LEN_SET AND CurrentRow GT 1>
		<CFSET D_VALUE_2_LEN_SET = true>
		<CFSET D_VALUE_2_LEN = CurrentRow - 1>
		</CFIF>
		</CFSILENT>
		<OPTION VALUE="#Evaluate(Attributes.Value2)#">#Evaluate(Attributes.Display2)#
		</CFIF>
		</CFOUTPUT>
	</CFIF>	
<CFOUTPUT></SELECT></TD></CFOUTPUT>

<CFOUTPUT>#Attributes.HTMLBetween2#</CFOUTPUT>

<CFOUTPUT></TR><TR><TD COLSPAN="2"></CFOUTPUT>
<CFIF Attributes.TITLE3 NEQ ""><CFOUTPUT><B>#Attributes.TITLE3#</B><BR></CFOUTPUT></CFIF>
<!----- Level 3 Select ---->
<CFOUTPUT><SELECT NAME="#Attributes.Name3#" SIZE="#Attributes.Size3#" <CFIF Attributes.onChange is not "">onChange="#Attributes.OnChange#"</CFIF> STYLE="width:#Attributes.ForceWidth3#"></CFOUTPUT>
	<CFIF Attributes.EmptyText3 is not ""><CFOUTPUT><OPTION VALUE="">#Attributes.EmptyText3#</CFOUTPUT></CFIF>
	<CFIF Attributes.EmptyText2 is "">		
		<CFOUTPUT QUERY="MyQuery" GROUP="#Attributes.Display3#" STARTROW="1" MAXROWS="#D_VALUE_2_LEN#">
		<CFIF D_VALUE_2 EQ Evaluate(Attributes.Value2)>
		<OPTION VALUE="#Evaluate(Attributes.Value3)#">#Evaluate(Attributes.Display3)#
		</CFIF>
		</CFOUTPUT>
	</CFIF>	
<CFOUTPUT></SELECT></TD></CFOUTPUT>
<CFOUTPUT></TR></TABLE></CFOUTPUT>

<!--- REMOVE THIS AND FIRST LINE IF NOT USING CF3.1 OR LATER --->
<CFSETTING ENABLECFOUTPUTONLY="NO">