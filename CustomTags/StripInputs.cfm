<!---
Purpose: Strips out input values from page
Required Inputs: 	strip - boolean value
Optional Inputs: N/A
Outputs: 

Modifications:
		Created TSF 08/13/2003
		
ToDo:

--->

<cfparam name="Attributes.strip" default="false" type="boolean">

<cfoutput>

<!---if strip is on then go--->
<cfif Attributes.strip>

	<cfswitch expression="#thistag.ExecutionMode#">
	
		<!---do for generated content--->
		<cfcase value="END">
			
			<!---search for the input tag--->
			<cfset regex = "<input(.*?)>">
			
			<!---loop over all instances of input tag--->
			<cfloop index="indx" list="#thistag.GeneratedContent#" delimiters="regex">
			
				<!---get the length and position using regular expression--->
				<cfset sLenPos=REFindNoCase(regex, thistag.GeneratedContent, 1, "True")>
				
				<!---if we have an instance of it then remove--->
				<cfif sLenPos.len[1]>

					<cfset thistag.GeneratedContent = RemoveChars(thistag.GeneratedContent, sLenPos.Pos[1], sLenPos.Len[1]) />

				</cfif>
			</cfloop>

		</cfcase>
		
	</cfswitch>

</cfif>

</cfoutput>