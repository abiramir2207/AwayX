<!---------------------------------------------------------------------------------------------------------------------
	  Template: \Common_Files\jsError.cfm
	  Date:     July, 2011
	  Author:   Chris Nguyen
	  Purpose:  Process JavaScript errors
----------------------------------------------------------------------------------------------------------------------->

<cfinvoke component="components.settings.ApplicationSettingsManager"
			method="get"
			returnVariable="appSettings">
</cfinvoke>

<cfif IsDefined("form") and isStruct(form)>
  <cfmail
   <!---to  = "dakao.saigon@gmail.com"--->
		to  = "#appSettings.getRemoteEventsEmail()#"
	   from = "#appSettings.getDifferent_From_Address()#"
	subject = "JavaScript Error on #Server_Name#"
	   type = "HTML">
  #DumpVar(form)#
  </cfmail>
</cfif>

<!--------------------------------------------------------------------------------------------------------------------->

<cfscript>
/**
 * Displays contents of any data type except WDDX.
 *
 * @param varToProcess 	 The variable to dump.
 * @return Returns a string.
 * @author Chris Benson (&#97;&#105;&#114;&#102;&#111;&#111;&#102;&#64;&#121;&#97;&#104;&#111;&#111;&#46;&#99;&#111;&#109;)
 * @version 1, April 23, 2002
 */
function DumpVar(varToProcess){
		var structLoopCount = 0;
		var LoopCount = 0;
		var ObjSize = 0;
		var key = "";
		var keys = "";
		var numOfColumns = 0;
		var count2 = 0;

		var StartString = "";
		var EndString = "</table>#chr(10)#";
		var vars = {};

		if(isSimpleValue(varToProcess)){
			if(isWDDX(varToProcess)){
				StartString = "#chr(10)#<table bordercolor='black' border='1' cellspacing='0' cellpadding='1'>#chr(10)#";

				return StartString & "<tr>#chr(10)#<td>WDDX currently not displayable</td>#chr(10)#</tr>#chr(10)#" & EndString;
			}else{
				return varToProcess;
			}
		}else if(isArray(varToProcess)){
			StartString = "#chr(10)#<table bordercolor='##008000' border='1' cellspacing='0' cellpadding='1'>#chr(10)#";
			ObjSize = ArrayLen(varToProcess);

			for(LoopCount = 1;LoopCount LTE ObjSize;LoopCount = LoopCount + 1){
				StartString = StartString & "<tr>#chr(10)#<td bgcolor='##cceecc' valign='top'>#LoopCount#</td><td>#dumpVar(varToProcess[LoopCount])#</td>#chr(10)#</tr>#chr(10)#";
			}
			return StartString & EndString;
		}else if(isStruct(varToProcess)){
			StartString = "#chr(10)#<table bordercolor='blue' border='1' cellspacing='0' cellpadding='5'>#chr(10)#";

	  vars.aKeys = [];
			// get all the key names
			for(key in varToProcess){
			  // ignore the fieldnames key
			  if (key neq "FieldNames")
				  ArrayAppend(vars.aKeys, key);
			}
			//sort the key names
	  ArraySort(vars.aKeys, "textnocase");

	  //dump all keys and values in order of names
	  for (vars.i = 1; vars.i <= arrayLen(vars.aKeys); vars.i++) {
		key = vars.aKeys[ vars.i ];
				StartString = StartString & "<tr>#chr(10)#<td bgcolor='##aaaaee' valign='top'><b>#LCase(key)#</b></td>#chr(10)#<td>#dumpVar(varToProcess[key])#</td>#chr(10)#</tr>#chr(10)#";
	  }

			return StartString & EndString;
		}else if(isQuery(varToProcess)){
			StartString = "#chr(10)#<table bordercolor='red' border='1' cellspacing='0' cellpadding='1'>#chr(10)#";
			ObjSize = varToProcess.recordCount;
			Keys = varToProcess.columnList;
			numOfColumns = ListLen(Keys);
			StartString = StartString & "<tr>#chr(10)#";

			for(count2 = 1;count2 LTE numOfColumns;count2 = count2 + 1){
				StartString = StartString & "<td bgcolor='##eeaaaa'>#listGetAt(Keys,count2)#</td>#chr(10)#";
			}
			StartString = StartString & "</tr>#chr(10)#";

			for(LoopCount = 1;LoopCount LTE ObjSize;LoopCount = LoopCount + 1){
				StartString = StartString & "<tr>#chr(10)#";
				for(count2 = 1;count2 LTE numOfColumns;count2 = count2 + 1){
					StartString = StartString & "<td>#varToProcess[listGetAt(Keys,count2)][loopCount]#</td>#chr(10)#";
				}
				StartString = StartString & "</tr>#chr(10)#";
			}
			return StartString & EndString;
		}else{
			return " ";
		}
}
</cfscript>
