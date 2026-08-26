<!-----------------------------------------------------------------------------

FILE NAME:		_incTrSeparator.cfm
DESCRIPTION:	This file will do the calculation and add the <tr> and </tr> tags 
				appropriately
CREATED BY:		Anand Rao
MODIFICATION HISTORY:	
BY			DATE		DESCRIPTION OF CHANGE
Anand Rao	14-Dec-2011	This file decides and adds <tr> and </tr>

------------------------------------------------------------------------------> 
<cfset currentColCount = currentColCount + 1 />
<!---<cfif isNextRow(maxColsPerRow, currentColCount)>--->
<cfif currentColCount gte maxColsPerRow>
</TR>
<TR>
<cfset currentColCount = 0 />
</cfif>