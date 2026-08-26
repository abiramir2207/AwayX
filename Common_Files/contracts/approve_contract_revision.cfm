<CF_MessageWindow>
	
	<CFIF Program_Is_A_Revision EQ 1>
	
		<CFOUTPUT>
		
		<CFQUERY NAME="GetRevisionParentInfo" datasource="#application.datasource#">
			SELECT Contract_End_Date, Contract_Start_Date
			FROM Contract_Main
			WHERE Contract_Main_ID = #parent_program_id#
		</CFQUERY>			
	
		<table ALIGN="center">
			<TR>
				<TD VALIGN="bottom"><span ID="error_ContractSpan"></SPAN></TD>
				<TD>
					<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" width="300" ALIGN="center">
						<TR>
							<TD COLSPAN="100%" STYLE="color: red; font-size: 10px;" HEIGHT="30">
								Please enter the start and end dates for this revision. 
								<!---TSF: Modification Retro Revision--->
								<cfparam name="form.allowRetroRevision" default=0 />
										
								<!---if program allows retro revisions then show and set valid start date--->
								<cfif getProgramSettngs.Allow_Retro_Revision eq 1>
										
									<cfset form.allowRetroRevision = 1 />
											
									<cfset form.allowedStartDate = DateAdd("d", - getProgramSettngs.Allow_Retro_Revision_Span, Now()) /> 
									<!---if the validStartDate is less than the parent start date then use the revision start date as the valid start date--->
									<cfif DateCompare(form.allowedStartDate, GetRevisionParentInfo.Contract_Start_Date) neq 1>
										<cfset form.allowedStartDate = GetRevisionParentInfo.Contract_Start_Date /> 
									</cfif>
									<br>(Start date can be no earlier than #DateFormat(form.allowedStartDate, "mm/dd/yyyy")#.)
									
									<INPUT NAME="allowedStartDate" TYPE="Hidden" VALUE="#DateFormat(form.allowedStartDate, "mm/dd/yyyy")#">
								<cfelse>
									(Start date can be no earlier than today.)
								</cfif>
								
								<BR>
								Original program dates: 
								<span STYLE="color:blue;">
									#dateformat(GetRevisionParentInfo.Contract_Start_Date, 'mm/dd/yyyy')# - #dateformat(GetRevisionParentInfo.Contract_End_Date, 'mm/dd/yyyy')#
								</span>
							</TD>
						</TR>
						<TR id="cellWithDateSpan">
							<TD>
								Start:<br>
									<CF_EASYDATE FORMNAME="MyForm" FIELDNAME="start_date" FORMAT="mm/dd/yyyy" DEFAULT="">
							</TD>
							<TD></TD>
							<TD>
								End:<br>
									<CF_EASYDATE FORMNAME="MyForm" FIELDNAME="end_date" FORMAT="mm/dd/yyyy" DEFAULT="">
							</TD>
						</TR>
						<TR>
							<TD COLSPAN="100%" STYLE="color: red; font-size: 10px;" HEIGHT="30">* If this program includes a formula pricing discount, approved revisions must begin on the first day of the next pricing period.</TD>
						</TR>
					</TABLE>		
				</TD>
			</TR>
		</table>
		
		<!---TSF: Modification Retro Revision--->
		<INPUT NAME="allowRetroRevision" TYPE="Hidden" VALUE="#form.allowRetroRevision#">
		</CFOUTPUT>
		
	</CFIF>
			
		<CFIF Program_Is_A_Revision EQ 1>
			<HR WIDTH="50%" COLOR="orange">
			<INPUT NAME="Program_Is_A_Revision" TYPE="Hidden" VALUE="1">
		<CFELSE>
		<input type="hidden" name="Pay_Brokerage" value="1">
		
		</CFIF>

			
			<script>
			function approveProgram(){
				ErrorCount = 0;
				<CFIF Program_Is_A_Revision EQ 1>

					FromDate = new Date(document.all.start_date.value);
					ToDate = new Date(document.all.end_date.value);		
					DateToday = new Date()
					DateToday = new Date(DateToday.getFullYear(), DateToday.getMonth(),DateToday.getDate())
					
					//is retro revision allowed
					var bAllowRetroRevision = document.all.allowRetroRevision.value;
					
					ParentEndDate = new Date(<CFOUTPUT>#datepart('yyyy',GetRevisionParentInfo.Contract_End_Date)#,#evaluate(datepart('m',GetRevisionParentInfo.Contract_End_Date)-1)#,#datepart('d',GetRevisionParentInfo.Contract_End_Date)#</CFOUTPUT>)
					//alert('<CFOUTPUT>#GetRevisionParentInfo.Contract_End_Date#</CFOUTPUT>')
					//alert(ParentEndDate)
					
					
					<!--- Date Validation --->
					if(document.all.start_date.value.length == 0 || document.all.end_date.value.length == 0)	{
						ErrorCount++;
						queueMessage("You must enter start and end dates for your revision", document.all.error_ContractSpan);
					}
					else
					{
						//TSF: Modification Retro Revision
						//if retroactive revisions are allowed then we must validate start date off of the allowd retroactive date
						if(bAllowRetroRevision == 1)
						{
							
							validDate = new Date(document.all.allowedStartDate.value);

							//is the from date before the allowed start date
							if(FromDate < validDate)
							{
								ErrorCount++;
								queueMessage("Your program revision start date cannot be less than " + document.all.allowedStartDate.value + ".", document.all.error_ContractSpan);
							}
							else
							{
								clearQueue(document.all.error_ContractSpan);
							}
						
						}
						else
						{
							//is the from date before today
							if(FromDate < DateToday)
							{
								ErrorCount++;
								queueMessage("Your program revision must start today or later.", document.all.error_ContractSpan);
							}
							else
							{
								clearQueue(document.all.error_ContractSpan);
							}
						}
						
						if(ErrorCount == 0){
							<!--- The To Date Must Be After The From Date --->
							if(ToDate < FromDate){
								ErrorCount++;
								queueMessage("Your start date must be after your end date.", document.all.error_ContractSpan);
							}
							else{
								clearQueue(document.all.error_ContractSpan);
							}
						}
						
						if(ErrorCount == 0){
							<!--- is the from date before the parent program end date --->
							if(FromDate > ParentEndDate){
								ErrorCount++;
								queueMessage("The new start date must be on or before the end date of the program being revised", document.all.error_ContractSpan);
							}
							else{
								clearQueue(document.all.error_ContractSpan);
							}						
						}

						if(ErrorCount == 0){												
							if(ToDate < FromDate){
								ErrorCount++;
								queueMessage("The end date must be after the start date", document.all.error_ContractSpan);
							}
							else{
								clearQueue(document.all.error_ContractSpan);
							}
						}
						<cfif trim(getProgramSettngs.Max_Duration) EQ 1>
							<CFOUTPUT>
							//var real_Program_Start_Date = new Date(#datepart('yyyy',GetRevisionParentInfo.Contract_Start_Date)#,#evaluate(datepart('m',GetRevisionParentInfo.Contract_Start_Date)-1)#,#datepart('d',GetRevisionParentInfo.Contract_Start_Date)#);							
							if(ErrorCount == 0)
							{
								numberOfDays = days_between(FromDate,ToDate);
								if(numberOfDays > parseInt(#trim(listgetat(getProgramSettngs.Max_Duration_Length, 1, "."))#)) {	
									ErrorCount++;
									queueMessage("The length of the program cannot exceed  #listgetat(trim(getProgramSettngs.Max_Duration_Length), 1, ".")# day(s)", document.all.error_ContractSpan)
								}
								else{
									clearQueue(document.all.error_ContractSpan);
								}
							}
							</CFOUTPUT>
						</CFIF>
					}
				<CFELSE>
				</CFIF>
				
				if(ErrorCount == 0){
					if(confirm("Are you sure you want to approve this program?")) {
						programGettingApproved = 1;
						document.MyForm.submit()
					}
				}
				else {
					showMessageWindow()
				}
			}
		</script>
		
		
