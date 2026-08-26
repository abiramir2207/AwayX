<CFSETTING ENABLECFOUTPUTONLY="YES">

<!---Checks and sets the tag attributes---------------->
<CFPARAM NAME="Attributes.Query">
<CFPARAM NAME="Attributes.Colname">
<CFPARAM NAME="Attributes.Listname" DEFAULT="collist">
<CFPARAM NAME="Attributes.Qualifier" DEFAULT="">
<CFPARAM NAME="Attributes.Delimiter" DEFAULT=",">

<!---Sets Tag variables--------------------------------->
<cfset queryname = "Caller." & #Attributes.Query#>
<cfset colname = #Attributes.Colname#>
<cfset numrows = Evaluate(queryname & ".RecordCount")>
<cfset queryColumns = "Caller." & #ATTRIBUTES.query# & ".columnlist">

<!---Checks to see if column name from the colname attribute is in the query--->
<cfif ListContainsNoCase(Evaluate(queryColumns),colname) is 0>
<cfabort showerror="
        <P>An error occurred in the custom tag Querycoltolist:</P>   
           The query named does NOT contain a column specified by the column name attribute. The column either does not exist or is misspelled.">
</cfif> 

<!---Converts colunm to a list--------------------------------------------------->
<cfset collist = "">
<CFLOOP INDEX="row" FROM="1" TO="#numrows#">
<cfloop INDEX="col" LIST="#colname#">
<cfset collist = #ListAppend(collist, Evaluate(queryname & "." & col & "[" & row & "]"))#>
</cfloop> 
</cfloop>

<!---Adds different qualifers and/or delimiters that were listed as attributes----->
<cfif  (Attributes.Qualifier is not "") OR (Attributes.Delimiter is not ",")>
<CFSET templist = "">
<CFLOOP INDEX="listel" LIST="#collist#">
  <CFSET templist = ListAppend(templist, Attributes.Qualifier & listel & Attributes.Qualifier,Attributes.Delimiter)>
</CFLOOP>
<CFSET collist = templist>
</cfif> 

<!---Passes the finished list to the calling appication----------------------------->
<CFSET "Caller.#Attributes.listname#" = collist>

<CFSETTING ENABLECFOUTPUTONLY="NO">