<!----
	Filename:	C:\Work\Code\base\AwayX\DEDUCTIONS\Closure\Non_Trade_Save.cfm
	Created:	12/19/2011
 	Developer:	drachala        
	Copyright (c) 2006 Blacksmith Applications, Inc.       
             
	Description:
		The following validations will be executed on this file
			a.	If cases are entered for an item dollars must be greater than zero and cannot be null
			b.	If dollars are entered for an item cases must be greater than zero and cannot be null
			c.	Total dollars entered must equal the total dollar value of the deduction
			d.	The average rate per case for the items selected by the user cannot be greater than the average rate per case based on sales history
					i.		Calculate a rate per case based on what the user entered for cases and volume by item; rate per case = dollars / cases
					ii.		Compare the above rate to the average rate per case returned from the invoice search for the selected items
					iii.	If the rates don’t match give the user a message that asks if they are sure they want to save the data
					iv.		A user profile setting will define a % tolerance that will allow the user to approve beyond the average case rate as long as it is within the tolerance or if the user have asterisk
					v.		If the comparison exceeds the user profile tolerance the user will not be able to save the record, they will need to adjust the dollars and cases for the items that exceed the average case rate
---->
<cfparam name="form.items" default="">
<cfparam name="form.cases" default="">
<cfparam name="form.dollars" default="">

<cfset useLakebaseForDeduction_User_Profile = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions_profiles_settings")>
<cfif useLakebaseForDeduction_User_Profile>
	<cftry>
		<cfset Deduction_User_Profile = application.oLakebase.toQuery(
			application.oLakebase.selectRows("deductions_profiles_settings", {
				"profiles_id" = "eq.#url.profile_id#"
			})
		)>
		<cfcatch type="any">
			<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
			<cfset useLakebaseForDeduction_User_Profile = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForDeduction_User_Profile>
<cfquery name="Deduction_User_Profile" datasource="#application.Datasource#">
	SELECT * 
	FROM Deductions_Profiles_Settings 
	WHERE Profiles_ID = #url.profile_id#
</cfquery>
</cfif>


	<cfset useLakebaseForcheck_DD_Closure_Type = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions")>
	<cfif useLakebaseForcheck_DD_Closure_Type>
		<cftry>
			<cfset check_DD_Closure_Type = application.oLakebase.toQuery(
				application.oLakebase.selectRows("deductions", {
					"select" = "dd_closure_type",
					"deduction_id" = "eq.#form.Deduction_ID#"
				}),
				"dd_closure_type"
			)>
			<cfcatch type="any">
				<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
				<cfset useLakebaseForcheck_DD_Closure_Type = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseForcheck_DD_Closure_Type>
	<cfquery name="check_DD_Closure_Type" datasource="#application.Datasource#">
			SELECT DD_Closure_Type 
			FROM Deductions
			WHERE Deduction_id = '#form.Deduction_ID#'
	</cfquery>
	</cfif>
<!--- Checks if this Dedction is already closed by other Type if so we wont dont anything --->
<cfif (len(check_DD_Closure_Type.DD_Closure_Type) EQ 0) OR (check_DD_Closure_Type.DD_Closure_Type EQ 8)>
<!--- empty list for Evaluate  form variables values START --->
		<cfset cases 				= "">
		<cfset dollars 				= "">
		<cfset avg_case_rate 		= "">
		<cfset BSA_Item_Master_ID 	= "">
		<cfset ReasonCode_ID 		= "">
		<cfset items 				= #form.items#>
<!--- empty list for Evaluate  form variables values END --->
<!--- Evaluate form variables and assign them to list START --->		
		<cfloop list="#form.items#" index="i">
				<cfset cases 					= listappend(cases, #evaluate( 'form.cases_#i#' )#)>
				<cfset dollars 					= listappend(dollars, #evaluate( 'form.dollars_#i#' )#)>
				<cfset avg_case_rate 			= listappend(avg_case_rate, #evaluate( 'form.Avg_case_rate_#i#' )#)>
				<cfset BSA_Item_Master_ID 		= listappend(BSA_Item_Master_ID, #evaluate( 'form.BSA_Item_Master_ID_#i#' )#)>
				<cfset ReasonCode_ID 			= listappend(ReasonCode_ID, #evaluate('form.ReasonCode_#i#')#)>
		</cfloop> 
<!--- Evaluate form variables and assign them to list END --->
<!--- This Script will assign NULL to empty values in LIST START --->
		<cfscript>
		/**
		 * Fixes a list by replacing null entries.
		 * This is a modified version of the ListFix UDF 
		 * written by Raymond Camden. It is significantly
		 * faster when parsing larger strings with nulls.
		 * Version 2 was by Patrick McElhaney 
		 * @param list 	 The list to parse. (Required)
		 * @param delimiter 	 The delimiter to use. Defaults to a comma. (Optional)
		 * @param null 	 Null string to insert. Defaults to "NULL". (Optional)
		 * @return Returns a list. 
		 * @author Steven Van Gemert 
		 * @version 3, July 31, 2004 
		 */
		function listFix(list) {
		var delim = ",";
		  var null = "NULL";
		  var special_char_list      = "\,+,*,?,.,[,],^,$,(,),{,},|,-";
		  var esc_special_char_list  = "\\,\+,\*,\?,\.,\[,\],\^,\$,\(,\),\{,\},\|,\-";
		  var i = "";
		       
		  if(arrayLen(arguments) gt 1) delim = arguments[2];
		  if(arrayLen(arguments) gt 2) null = arguments[3];
		
		  if(findnocase(left(list, 1),delim)) list = null & list;
		  if(findnocase(right(list,1),delim)) list = list & null;
		
		  i = len(delim) - 1;
		  while(i GTE 1){
			delim = mid(delim,1,i) & "_Separator_" & mid(delim,i+1,len(delim) - (i));
			i = i - 1;
		  }
		
		  delim = ReplaceList(delim, special_char_list, esc_special_char_list);
		  delim = Replace(delim, "_Separator_", "|", "ALL");
		
		  list = rereplace(list, "(" & delim & ")(" & delim & ")", "\1" & null & "\2", "ALL");
		  list = rereplace(list, "(" & delim & ")(" & delim & ")", "\1" & null & "\2", "ALL");
			  
		  return list;
		}
		</cfscript>
		
		<cfset item 			= #listFix(items)#>
		<cfset cases 			= #listFix(cases)#>
		<cfset dollars 			= #listFix(dollars)#>
		<cfset avg_case_rate 	= #listFix(avg_case_rate)#>
<!--- This Script will assign NULL to empty values in LIST END --->
	
	<cfif listlen(form.items) NEQ listlen(cases)>
		<cfset diff = #listlen(form.items)# -#listlen(cases)#>
		<cfloop from="1" to="#diff#" index="z">
			<cfset cases = ListPrepend(cases, "")>
		</cfloop>
	</cfif>

	<cfif listlen(form.items) NEQ listlen(dollars)>
		<cfset diff = #listlen(form.items)# -#listlen(dollars)#>
		<cfloop from="1" to="#diff#" index="z">
			<cfset dollars = ListPrepend(dollars, "")>
		</cfloop>
	</cfif>
		
		<cfset cases 	= #listFix(cases)#>
		<cfset dollars 	= #listFix(dollars)#>
		
		<cfset final_items 					= "">
		<cfset final_cases 					= "">
		<cfset final_dollars 				= "">
		<cfset final_deduction_amount 		= 0>
		<cfset final_BSA_Item_Master_ID 	= "">
		<cfset final_ReasonCode_ID 			= "">
		
		<cfset error_message = "">
<!--- if listlen eq i and it value is null that means user submited blank form so we are setting both listlen value to 0 START --->
<cfif (listlen(cases) EQ 1 AND cases EQ "NULL") AND (listlen(dollars) EQ 1 AND dollars EQ "NULL" )>
	<cfset cases = "">
	<cfset dollars = "">
</cfif>
<!--- if listlen eq i and it value is null that means user submited blank form so we are setting both listlen value to 0 END --->
	<cfset case_null 	= "1">
	<cfset dollar_null 	= "1">
	<cfset Reasoncode	= "1">
<cfloop from="1" to="#listlen(cases)#" index="c">
	<cfif #listgetat(cases, c)# EQ "null">
		<cfset case_null = 0>
	<cfelse>
		<cfset case_null = 1>
		<cfbreak>
	</cfif>
</cfloop>
<cfloop from="1" to="#listlen(dollars)#" index="d" >
	<cfif #listgetat(dollars, d)# EQ "null">
		<cfset dollar_null = 0>
	<cfelse>
		<cfset dollar_null = 1>
		<cfbreak>
	</cfif>
</cfloop>
<cfloop from="1" to="#listlen(final_ReasonCode_ID)#" index="r" >
	<cfif #listgetat(final_ReasonCode_ID, r)# EQ "0">
		<cfset Reasoncode = 0>
	<cfelse>
		<cfset Reasoncode = 1>
		<cfbreak>
	</cfif>
</cfloop>
	<cfif (case_null) AND (dollar_null) AND (Reasoncode)>
		<cfoutput>
			<cfloop from="1" to="#listlen(form.items)#" index="i">
				<!--- Reassing value to form variables to display values if we re-route back to parent page START --->
				<cfif ListGetAt(cases, i) EQ "NULL">
					<cfset "form.cases_#ListGetAt(items, i)#" = "">
				<cfelse>
					<cfset "form.cases_#ListGetAt(items, i)#" = ListGetAt(cases, i)>
				</cfif>
				<cfif ListGetAt(dollars, i) EQ "NULL">
					<cfset "form.dollars_#ListGetAt(items, i)#" = "">
				<cfelse>
					<cfset "form.dollars_#ListGetAt(items, i)#" = ListGetAt(dollars, i)>
				</cfif>
				<!--- Reassing value to form variables to display values if we re-route back to parent page END --->		

				<cfif (ListGetAt(cases, i) NEQ "NULL") AND (ListGetAt(dollars, i) NEQ "NULL") AND (IsNumeric(ListGetAt(cases, i))) AND (IsNumeric(ListGetAt(dollars, i)) AND (ListGetAt(dollars, i) GT 0))>
							<!--- Checks if user has unlimted tollarence or certain tolarence and check newAverage rate is under tolerance limit START --->
						<cfif #Deduction_User_Profile.dd_non_trade_tolerance# EQ "*">
								<cfset final_items 					= listappend(final_items, #ListGetAt(items, i)#)>
								<cfset final_cases 					= listappend(final_cases, #ListGetAt(cases, i)#)>
								<cfset final_dollars 				= listappend(final_dollars, #ListGetAt(dollars, i)#)>
								<cfset final_BSA_Item_Master_ID 	= listappend(final_BSA_Item_Master_ID, #listGetAt(BSA_Item_Master_ID, i)#)>
								<cfset final_deduction_amount 		= #final_deduction_amount# + #ListGetAt(dollars, i)#>
								<cfset final_ReasonCode_ID			= listappend(final_ReasonCode_ID, #ListGetAt(ReasonCode_ID, i)#)>
						<cfelseif #Deduction_User_Profile.dd_non_trade_tolerance# NEQ "*"> 
								    <cfset old_avg_case_rate = #ListGetAt(avg_case_rate, i)#>
									<cfset new_avg_case_rate = #ListGetAt(dollars, i)#/#ListGetAt(cases, i)#>
								<cfif len(Deduction_User_Profile.dd_non_trade_tolerance) eq 0><cfset Deduction_User_Profile.dd_non_trade_tolerance = 0></cfif>
									<cfset percentage = 100 + #Deduction_User_Profile.dd_non_trade_tolerance#>
									<cfset max_avg_case_rate = (#percentage#*#old_avg_case_rate#)/100>
								<cfif max_avg_case_rate LT new_avg_case_rate>
		 							<cfset error_message = listappend(error_message, 'item ' & #ListGetAt(items, i)#&' new average rate over tolerance limit')>
								<cfelseif max_avg_case_rate GT new_avg_case_rate>
		 							<cfset error_message = listappend(error_message, 'item ' & #ListGetAt(items, i)#&' new average rate under tolerance limit')>							
								<cfelse>
									<cfset final_items 					= listappend(final_items, #ListGetAt(items, i)#)>
									<cfset final_cases 					= listappend(final_cases, #ListGetAt(cases, i)#)>
									<cfset final_dollars 				= listappend(final_dollars, #ListGetAt(dollars, i)#)>
									<cfset final_BSA_Item_Master_ID 	= listappend(final_BSA_Item_Master_ID, #listGetAt(BSA_Item_Master_ID, i)#)>
									<cfset final_deduction_amount 		= #final_deduction_amount# + #ListGetAt(dollars, i)#>
									<cfset final_ReasonCode_ID			= listappend(final_ReasonCode_ID, #ListGetAt(ReasonCode_ID, i)#)>
								</cfif>
						</cfif>
						<!--- Checks if user has unlimted tollarence or certain tolarence and check newAverage rate is under tolerance limit END --->
				</cfif>
				<!--- Checks if user entered value for cases is Numeric and not NULL START --->
				<cfif (ListGetAt(cases, i) NEQ "NULL") AND (NOT IsNumeric(ListGetAt(cases, i)))>
						<cfset error_message = listappend(error_message,'item '& #ListGetAt(item, i)#&' has cases value non numeric')>
				</cfif>
				<!--- Checks if user entered value for cases is Numeric and not NULL END --->
				<!--- Checks if user entered value for cases is GT 0 and not NULL START --->
				<cfif (ListGetAt(cases, i) NEQ "NULL") AND (ListGetAt(cases, i) LTE 0)>
						<cfset error_message = listappend(error_message, 'item '& #ListGetAt(item, i)#&' has cases value null or Zero or less than zero')>
				</cfif>
				<!--- Checks if user entered value for cases is GT 0 and not NULL END --->
				<!--- Checks if user entered value for dollars is Numeric and not NULL START --->
				<cfif ((ListGetAt(dollars, i) NEQ "NULL") AND (NOT IsNumeric(ListGetAt(dollars, i))))>
						<cfset error_message = listappend(error_message, 'item '& #ListGetAt(item, i)#&' has dollars value non numeric')>
				</cfif>
				<!--- Checks if user entered value for dollars is Numeric and not NULL END --->
				<!--- Checks if user entered value for dollars is GT 0 and not NULL START --->
				<cfif (ListGetAt(dollars, i) NEQ "NULL") AND (ListGetAt(dollars, i) LTE 0)>
						<cfset error_message = listappend(error_message, 'item ' & #ListGetAt(item, i)#&' has dollars value null or Zero or less than zero')>
				</cfif>
				<!--- Checks if user entered value for dollars is GT 0 and not NULL END --->
				<!--- Checks if user selected value for reasoncode START --->
				<cfif (ListGetAt(ReasonCode_ID, i) EQ "0") AND ((ListGetAt(dollars, i) NEQ "NULL") AND ((ListGetAt(dollars, i) LTE 0) OR (IsNumeric(ListGetAt(dollars, i)) ) )) AND ((ListGetAt(cases, i) NEQ "NULL") AND ((ListGetAt(cases, i) LTE 0) OR (IsNumeric(ListGetAt(cases, i)))))>
						<cfset error_message = listappend(error_message, 'item ' & #ListGetAt(item, i)#&' reason code is not selected')>
				</cfif>
				<!--- Checks if user selected value for reasoncode END --->
				<cfset i = i + 1>
		
			</cfloop>
		</cfoutput>
	<cfelse>
		<cfset error_message = listappend(error_message, 'You cannot submit empty form')>
	</cfif>
	
	<!--- Checks if enter dollars amount matches to deduction amount SATRT --->
		<!--- D29907  for ISSUE 3 --->
	<cfif (#DollarFormat(Deduction_Info.DD_Amount)# NEQ #DollarFormat(final_deduction_amount)#) AND ((listcontains(error_message, 'tolerance') EQ 0) AND (listcontains(error_message, 'cases') EQ 0) AND (listcontains(error_message, 'dollars') EQ 0) AND (listcontains(error_message, 'empty') EQ 0) AND (listcontains(error_message, 'reason') EQ 0))>
		<cfset error_message = listappend(error_message, 'Total amount is not equal to the deduction amount')>
	</cfif>
	<!--- Checks if enter dollars amount matches to deduction amount END --->
		<cfif len(error_message) GT 0>
		<!--- Display Error messages to users START --->
			<div style="background-color:red; color: white; font-weight: bold; width:100%; padding-top:5px; padding-bottom:5px;">
				<cfloop list="#error_message#" index="error_info" delimiters="," >
					<cfoutput>&nbsp;&nbsp;#UCase(error_info)#</cfoutput><br>
				</cfloop>
			</div>
		<!--- Display Error messages to users END --->
		<cfelse>
			<cfset Nontrade = CreateObject("component", "components.deduction.Nontrade")>
		<!--- Insert Records into "DD_Non_Trade_Product" if Item has Cases and Dollar Value Greater than START --->
			<cfloop from="1" to="#listlen(final_items)#" index="i">
					<cfscript>
						Nontrade.NonTradeInsert
													(
													BSA_Item_Master_ID 			= #listgetat(final_BSA_Item_Master_ID, i)#, 
													DeductionID 				= #form.Deduction_ID#, 
													Cases 						= #listgetat(final_cases, i)#, 
													Dollars 					= #listgetat(final_dollars, i)#,
													ReasonCode					= #listgetat(final_ReasonCode_ID, i)#
													);
					</cfscript>
					<cfset reasoncode = #listgetat(final_ReasonCode_ID, i)#>
		    </cfloop>
		<!--- Insert Records into "DD_Non_Trade_Product" if Item has Cases and Dollar Value Greater than END --->
		<!--- Update "Deductions" with Closer type ID START --->
					<cfscript>
						Nontrade.UpdateClosureType
													(
													BSA_Item_Master_ID 			= #listgetat(final_BSA_Item_Master_ID, 1)#, 
													DeductionID 				= #form.Deduction_ID#,
													User_ID						= #request.AccessStructure.user_ID#
													);
					</cfscript>
		<!--- Update "Deductions" with Closer type ID END --->
			
		<cfset DeductionManager = CreateObject("component", "components.deduction.DeductionManager")>
				<cfscript>
						DeductionManager.RFADeduction 
										(
										deductionId			= 	#form.Deduction_ID#
										);		
				</cfscript>
				<cfif Deduction_User_Profile.DD_APPROVE>
						<cfoutput>
							<cfif #url.from# EQ 'pop-up'>
								<script>
									window.open('/deductions/closure/index.cfm?frompopup=1&Deduction_ID=#form.Deduction_ID#&PopupReasonCode=1&reasoncode=#reasoncode#&Closure_Type=Approve','ApproveDeduction', 'width=800, height=600'); 
									self.close();
								</script>
							<cfelse>
								<!--- D38841 : Update non-trade feature to open in a new window START--->
								<script>
                                    	window.opener.document.all.deduction_ID.value='#form.Deduction_ID#';
										window.opener.document.all.reasoncode.value='#reasoncode#';
										window.opener.document.all.closure_Type.value='Approve';
										window.opener.document.dataForm.submit();
										self.close();
								</script>
									<!---<cflocation url="/deductions/closure/index.cfm?Deduction_ID=#form.Deduction_ID#&PopupReasonCode=1&reasoncode=#reasoncode#&Closure_Type=Approve">--->
							<!--- D38841 : Update non-trade feature to open in a new window END--->
							</cfif>
						</cfoutput>
				<cfelse>
							<cfif #url.from# EQ 'pop-up'>
									<cfset RFA_Deduction = 1>
										<div style="background-color:Green; color: white; font-weight: bold; width:100%; padding-top:5px; padding-bottom:5px;">
											This Deduction has been RFA<br>
											This window will close automatically.
										</div>
							<cfelse>
									<cflocation url="/deductions/inc_deduction_details.cfm?Deduction_ID=#form.Deduction_ID#">
							</cfif>
				</cfif>
			
		</cfif>

</cfif>