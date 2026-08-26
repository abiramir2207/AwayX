<!---
	Copyright (c)2012 Blacksmith Applications, Inc.       
	Filename:		C:\Work\base\AwayX\billbacks\ClaimForm\ClaimForm_Business_Consideration.cfm
	Created:		8/6/2012
	Developer:		drachala
	Description:	Used to save and display comments for one page claim form
	Label: 30374-One Page Claim Form - Add a Comment Field
--->	
<TABLE BORDER="0" CELLPADDING="2" CELLSPACING="0" WIDTH="100%">
	<TR>
		<TD ALIGN="left" bgcolor="#A7CAF2" WIDTH="100%" HEIGHT="25" style="background-image: url(/Images/gradient.jpg); background-repeat:no-repeat;">
			<SPAN STYLE="color:white; font-size:14px; font-weight: bold; padding-left:5px;">Comments</SPAN>
		</TD>
	</TR>
	</TABLE>

<cfif isdefined("form.submit")>
					<cfquery name="CheckComments" datasource="#application.datasource#">
								<cfif form.count>
									UPDATE Claim_Form_Business_Consideration
									SET  notes = '#trim(form.comment)#' , created_by = '#trim(request.AccessStructure.User_ID)#'
									WHERE form_id = #trim(url.formid)#
								<cfelse>
									INSERT INTO Claim_Form_Business_Consideration(Form_ID, Notes, Created_By)
									VALUES (#trim(url.formid)#, '#trim(form.comment)#',  '#trim(request.AccessStructure.User_ID)#')
								</cfif>
					</cfquery>	
					<script>
					  window.close();
					</script>
<cfelse>
					<cfquery name="CheckComments" datasource="#application.datasource#">
							SELECT  * 
							FROM  Claim_Form_Business_Consideration
							WHERE form_id = #trim(url.FormId)#
					</cfquery>
					<cfoutput>
							<form name="commentsform" action="ClaimForm_Business_Consideration.cfm?formid=#url.formid#" method="post">
							<table style="width:100%;">
									<tr>
											<td>
													
															<cfif len(CheckComments.Notes)>
																<textarea name="comment" style="width:100%;" rows="10">#trim(CheckComments.Notes)#</textarea>
															<cfelse>
																<textarea name="comment" style="width:100%;" rows="10"></textarea>
															</cfif>
																<input type="hidden" name="count" value="#CheckComments.RecordCount#">
											</td>
									</tr>
									<tr>
											<td>
													<span style="font-weight:bold;color:red"> [ </span> <input type="submit" name="submit" value="Save" style="border:none;background-color:white;width:35px;" OnClick="submitform();"><span style="font-weight:bold;color:red">]</span> 
													<span style="font-weight:bold;color:red"> [ </span> <input type="button" name="button" value="Close Window" style="border:none;background-color:white;width:70px;"  OnClick="javascript:window.close();"><span style="font-weight:bold;color:red"> ] </span>
											</td>
								</tr>
							</table>
							</form> 
					</cfoutput>
					<script>
					function submitform()
						{
							notes = document.commentsform.comment.value;
							
									if (notes.length == 0)
									{
										alert("Comments section is blank. Please enter valid comments.");
										return false;
									}
									else if (notes.length > 4000)
									{
										alert("Comments section exceeds the size limit. Please revise the comments.");
										return false;
									}
									else{
										document.commentsform.submit();
										return true;
									}
						}
					</script>
</cfif>