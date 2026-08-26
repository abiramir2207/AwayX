
<!--- MD_Array_Sort.cfm
TAG DESCRIPTION: 
	This tag will sort a 2D Array on the specified column(s). The tag will sort based on one or more columns. If a 
		column is not selected the tag will sort the array on the first column of the array. The tag will sort in
		either ascending or descending order depending on what is specified. Ascending is the default sort order 
		though. It is assumed that all arrays will be comprised of a combination of text, numbers and / or dates so 
		all sorts will be	text based sorts. The tag allows you to specify case sensitivity though.

TAG ATTRIBUTES:
	Array_Name	- The name of the array to be sorted. This must be a populated 2D array. You must enclose the name 
						of the array in pound signs "#" to pass the array to the tag.

	Sort_Order 	- the column number(s) to sort the array by. You can specify one or more columns in the array to 
						sort on.	Seperate the column numbers with a comma ",". The first column in the array is the 
						default column to sort by. The sort order must not contain spaces between the numbers. 
						I.E. 1,2,3 = RIGHT. 1, 2, 3 = WRONG!!!

	Asc_Desc 	- "Asc" or "Desc", Desc by default.

	Sort_Type	- The type of sort to execute. Sort type can be:
						text -- Sorts text alphabetically, uppercase before lowercase 
						textnocase -- Sorts text alphabetically; case is ignored (default)

USAGE:
	To use put paste the tag <CF_MD_Array_Sort> after the 2D array to be sorted has been populated but before you 
		display the contents of the array. The newly sorted array is will be able to be displayed as "TmpArray".

EXAMPLE:

<CF_MD_Array_Sort 
	Array_Name = #Name_of_the_array_to_sort#
	Sort_Order= 1,2,3
	Asc_Desc = 'Asc'
	Sort_Type = 'text'>

--->

<CFIF NOT IsDefined("Attributes.Array_Name")>
	A Valid array name must be included to use this tag.<CFABORT>
<cfelse>

<!--- Check to see how many columns are in the array. --->
	<CFSET MyArrayLen = #ArrayLen(Attributes.Array_Name[1])#>
	<CFSET ii = 1>
	<CFSET StrArray=ArrayNew(1)>
	<CFLOOP condition="#ii# LTE #MyArrayLen#">
		<CFSET StrArray[ii] = "$~" & #ii# & "~$">
		<CFSET ii = #ii# + 1>
	</CFLOOP>

<!--- Verify the Attributes.Sort_Order is valid and put the sort columns into an array--->
	<CFSET Col2Sort=ArrayNew(1)>
	<CFIF  IsDefined("Attributes.Sort_Order")>
		<CFSET MyStr = ",">
		<CFSET SO_Len = #Len(Attributes.Sort_Order)#>
<!---  Debug Print Statemenets
	<CFOUTPUT>Pos = #FIND(MyStr, Attributes.Sort_Order)#,&nbsp;&nbsp;SO_Len = #SO_Len#<BR></CFOUTPUT> 
--->
		<CFIF (#FIND(MyStr, Attributes.Sort_Order)# NEQ 0) AND (#FIND(MyStr, Attributes.Sort_Order)# NEQ #SO_Len#)>
			<CFSET Col2Sort = ListToArray(Attributes.Sort_Order)>
		<CFELSE>
			<CFSET Col2Sort[1] = LEFT(Attributes.Sort_Order, (SO_Len - 1))>
		</CFIF>
		
<!--- Find the largest column number in the array to be sorted. If it is larger than the number of columns in the
	array itself then return an error. --->
		<CFSET kk = 2>
		<CFSET BadValue = 0>
		<CFSET BigCol = #Col2Sort[1]#>
		<CFLOOP condition="#kk# LTE #ArrayLen(Col2Sort)#">
			<CFIF #Col2Sort[kk]# GT #BigCol#><CFSET BigCol = #Col2Sort[kk]#></CFIF>
			<CFIF NOT IsBoolean(#Col2Sort[kk]#)><CFSET BadValue = 1></CFIF>
			<CFSET kk = #kk# + 1>
		</CFLOOP>
		
<!--- Make sure the Sort_Order values are valid and that the largest sort order value is less than the number of
	columns in the array to be sorted. --->
		<CFIF IsBoolean(BigCol) and #BadValue# EQ 0>
			<CFSET BigCol = int(BigCol)>
			<CFIF (BigCol gt #MyArrayLen#) OR (BigCol lt 1)>
				The largest Sort_Order value is larger than the number of columns in the array<CFABORT>	
			</CFIF>
		<CFELSE>
			The Sort_Order parameters are not a valid integers.<CFABORT>
		</CFIF>

	<CFELSE>
		<cfset Col2Sort[1] = 1>
	</CFIF>

<!--- Debug print statements 
	<CFOUTPUT>BigCol = #BigCol#<BR></CFOUTPUT>
	<CFSET kk = 1><BR>Col2Sort Array Before<BR>
	<CFLOOP condition="#kk# LTE #ArrayLen(Col2Sort)#">
		<CFOUTPUT>
			.#Col2Sort[kk]#.<BR>
			<CFSET kk = #kk# + 1>
		</CFOUTPUT>
	</CFLOOP>
--->

<!--- Check the Asc_Desc flag --->
	<CFIF  IsDefined("Attributes.Asc_Desc")>
		<CFIF #Attributes.Asc_Desc# NEQ "Asc" AND #Attributes.Asc_Desc# NEQ "Desc">
			The parameter Asc_Desc must be set to either Desc or Asc.<CFABORT>
		<CFELSE>
			<CFSET MyAscDesc = #Attributes.Asc_Desc#>
		</CFIF>
	<CFELSE>
		<CFSET MyAscDesc = "Desc">
	</CFIF>

<!--- Check the Sort_Type flag --->
	<CFIF IsDefined("Attributes.Sort_Type")>
		<CFIF #Attributes.Sort_Type# NEQ "text" AND #Attributes.Sort_Type# NEQ "textnocase">
			The parameter Asc_Desc must be set to either Desc or Asc.<CFABORT>
		<CFELSE>
			<CFSET MySortType = #Attributes.Sort_Type#>
		</CFIF>
	<CFELSE>
		<CFSET MySortType = "textnocase">
	</CFIF>
	
<!--- Populate the Col2Sort array with all the possible columns in the array to be sorted. --->
	<CFSET ii = 1>
	<CFLOOP condition="#ii# LTE #MyArrayLen#">
		<CFSET jj = 1>
		<CFSET FoundIt = 0>
		<CFLOOP condition="#jj# LTE #ArrayLen(Col2Sort)#">
			<CFIF Col2Sort[jj] EQ #ii#>
				<CFSET FoundIt = 1>
			</CFIF>
			<CFSET jj = #jj# + 1>
		</CFLOOP>
		<CFIF FoundIt EQ 0>
			<CFSET Col2Sort[#jj#] = #ii#>
		</CFIF>
		<CFSET ii = #ii# + 1>
	</CFLOOP>
	
<!--- Debug print statements 
	<CFSET kk = 1><BR>Col2Sort Array after<BR>
	<CFLOOP condition="#kk# LTE #ArrayLen(Col2Sort)#">
		<CFOUTPUT>
			#Col2Sort[kk]#<BR>
			<CFSET kk = #kk# + 1>
		</CFOUTPUT>
	</CFLOOP>
--->

<!--- Populate the array to be sorted. --->
	<CFSET TmpArray1=ArrayNew(1)>
	<CFSET ii = 1>
	<CFLOOP condition="#ii# LTE #ArrayLen(Attributes.Array_Name)#">
		<CFSET kk = 1>
		<CFSET TmpStr = "">
		<CFLOOP condition="#kk# LTE #ArrayLen(Col2Sort)#">
			<CFSET TmpStr = #TmpStr# & #Attributes.Array_Name[ii][(Col2Sort[kk])]# & #StrArray[kk]#>
			<CFSET kk = #kk# + 1>
		</CFLOOP>
<!---	Debug Print Statements
	<CFOUTPUT>TmpStr=#TmpStr#<BR></CFOUTPUT> 
--->
		<CFSET TmpArray1[#ii#] = #TmpStr#>
		<CFSET ii = #ii# + 1>
	</CFLOOP>

<!--- Sort the Tmp1Array --->
	<CFSET SortArray = ArraySort(TmpArray1, #MySortType#, #MyAscDesc#)>
	
<!--- Debug print statements 
	<CFSET kk = 1>TmpArray1 after the sort<BR>
	<CFLOOP condition="#kk# LTE #ArrayLen(TmpArray1)#">
		<CFOUTPUT>
			#TmpArray1[kk]#<BR>
			<CFSET kk = #kk# + 1>
		</CFOUTPUT>
	</CFLOOP>
--->

<!--- Break the sorted array back out and put it into its origional element as defined by its position in the 
	array that was passed to this tag. Its position in the sort order is not relavant. --->
	<CFSET TmpArray=ArrayNew(2)>
	<CFSET ii = 1>
	<CFLOOP condition="#ii# LTE #ArrayLen(TmpArray1)#">
		<CFSET StrParam = #FIND(StrArray[1], TmpArray1[ii])#>
		<CFSET TmpStr = #LEFT(TmpArray1[ii], (StrParam - 1))#>
		<CFSET TmpArray[#ii#][(#Col2Sort[1]#)] = #TmpStr#>
		<!--- <CFOUTPUT>TmpStr = #TmpStr#&nbsp;&nbsp;</CFOUTPUT> --->
		<CFSET kk = 2>
		<CFLOOP condition="#kk# LTE #MyArrayLen#">
			<CFSET StrParam = #FIND(StrArray[kk - 1], TmpArray1[ii])#>
			<CFSET StrParam1 = #FIND(StrArray[kk], TmpArray1[ii])#>
			<CFSET TmpStr = #MID(TmpArray1[ii], (StrParam + 5), (StrParam1 - StrParam -5))#>
			<CFSET TmpArray[#ii#][(#Col2Sort[kk]#)] = #TmpStr#>
			<!--- <CFOUTPUT>#TmpStr#&nbsp;&nbsp;</CFOUTPUT> --->
			<CFSET kk = #kk# + 1>
		</CFLOOP>
		<CFSET ii = #ii# + 1>
	</CFLOOP>

<!--- Debug print statements 
	<CFSET ii = 1>
	<CFLOOP condition="#ii# LTE #ArrayLen(TmpArray)#">
		<CFOUTPUT>TmpArray[#ii#] = </CFOUTPUT>
		<CFSET kk = 1>
		<CFLOOP condition="#kk# LTE #MyArrayLen#">
			<CFOUTPUT>#TmpArray[ii][(Col2Sort[kk])]#</CFOUTPUT>
			<CFSET kk = #kk# + 1>
		</CFLOOP>
		<BR>
		<CFSET ii = #ii# + 1>
	</CFLOOP>
--->

	<CFSET CALLER.TmpArray = TmpArray>
</CFIF>
