<CFSET Program_Volume = CreateObject("component", "components.programs.volume.ContractVolume")>

<CFPARAM NAME="Form.Program_ID" 	DEFAULT="">
<CFPARAM NAME="URL.Program_ID" 		DEFAULT="#Form.Program_ID#">

<CFIF Form.Program_ID NEQ "">
	<CFSET D_Temp = Program_Volume.Load_Basic_Information(Form.Program_ID)>
	<CFSET D_Temp = Program_Volume.Do_Forecast(AccessStructure)>
</CFIF>

<CFLOCATION ADDTOKEN="No" URL="Contract_Volume.cfm?#Program_Volume.Build_To_URL(Program_Volume.pass_url, "action", "loadforecast")#">