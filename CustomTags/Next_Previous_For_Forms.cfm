<!--- CF_Number_of_Rows/CF_Next_Previous custom tags
		
What these do:
		Display the Result Pages of a query and let you link to next o previous	pages and next and previous series of pages. So you can pass from ten to ten pages or the number you specify in maxpages="". The default result	looks such the follow:
		
			1 2 3 4 5 6 7 8 9 10 > >>
		
		The number of the current page is not linked.
			
		You can change the arrows by a text and even a img tag using a simple quote. So you can get the displayed such this example:
		
			[Previous 5 pages] Previous 11 12 13 14 15 Next [Next 5 pages]
		
		You can complete the output writing in your language the follow:
		
			Results Pages #queryname.recordcount# <CF_Next_Previous ...> 	

How to apply it:
		Keep in mind in write first the CF_Number_of_Rows, before the cfoutput or cfloop of your query. These CF tags have to have specified Attributes. It's explained how in the Syntax.
		Afterwards write the CF_Next_Previous whom will output the Results Pages.
				
Syntax:

CF_Number_of_Rows	
		<CF_Number_of_Rows
		maxrows="number">
	
		MAXROWS
			Optional. Specifies the maxmium number of rows you want displayed
			in the output section. Default is 10.
---------------------------------				
			...Add the CFOUTPUT here in this way
				<cfoutput query="query_name" startrow="#StartRow#" maxrows="#MaxRows#">
				
				</cfoutput>
				
			...or the CFLOOP in this way	
				
				<cfloop query="query_name" startrow="#StartRow#" endrow="#EndRow#">
				
				</cfloop>
			
				NOTE: You don't have to set the StartRow, MaxRows and EndRow 
					  variables. This's done by CF_Number_of_Rows
---------------------------------

CF_Next_Previous	
			
			<CF_Next_Previous
			query="query_name"
			maxpages="number"
			droprows="number,number,number" 
			all or all="text"
			previous="text/img tag"
			next="text/img tag"
			previousseries="text/img tag"
			nextseries="text/img tag"
			addparams="param,param,param">

			QUERY
				Required. The query name.
			
			MAXPAGES
				Optional. Specifies the maximum pages for the series displayed.
				Default is 10.
				
			DROPROWS
				Optional. List of the number of the maxrows that will display by a select tag. It let the user to change the maxrows. If you just write DROPROWS the list is "10,25,50,100"
				
			ALL
				Optional. Display the link that let see all of the rows of the result. The text that is displayed is 'ALL'. You can change the text by introducing it. Example in catalan was ALL="TOTS".
				
			PREVIOUS
				Optional. The display of the link previous page. Default is '<'.
				You can use a img tag but take in mind write like this:
				<img src='previous.gif' border=0>, I mind with a simple quote '
				even without it, but not with double quote ".
				
			NEXT
				Optional. The display of the link next page. Default is '>'.
				
			PREVIOUSSERIES
				Optional. The display of the link previous 'maxpages' pages. Default is '<<'.
				
			NEXTSERIES
				Optional. The display of the link next 'maxpages' pages. Default is '>>'.			
				
			ADDPARAMS
				Optional. Add parameters at the URL for the links which pass pages. 
				Put	them separated just by comas (don't wrap them with #!). 
				example: ADDPARAMS="sortby,city". Sometimes you	need it	for build the query. 

Copy'n'paste (simple):
			<CF_Number_of_Rows>
			
			<cfoutput query="q" startrow="#StartRow#" maxrows="#MaxRows#"> 

			</cfoutput>
			
			<CF_Next_Previous query="q">
			
			
Copy'n'paste (Advanced):
			<CF_Number_of_Rows maxrows="12">
			
			<cfoutput query="q" startrow="#StartRow#" maxrows="#MaxRows#"> 

			</cfoutput>
			
			<CF_Next_Previous
			query="q"
			maxpages="x"
			droprows
			all
			previous="Previous"
			next="Next"
			previousseries="[Previous x pages]"
			nextseries="[Next x pages]"
			addparams="">
		
Communication: 
			If you have any comment or suggestion for improve the tag, even an anecdote, write me at justapp@fruir.net. Thanks on Advance. My english's not so good although I intend to do it right.
			Feel free to help me in this way: send me the faults corrected and I'll fix. A lot of thanks.
			
Written by: Lluís Casany -  JustApp@fruir.net
			www.fruir.net/web/JustApp - The Lluís Casany's Comp Page
      Date: March 30, 2000
	  
Dedication: I dedicate these customs tags to all authentic'n'good people.

 --->
<!--- CF_Next_Previous Custom tag
	Lluís Casany
	http://www.fruir.net/web/JustApp --->
<!--- CF_Next_Previous code --->	

<!---  --->

<cfset error_in="CF_Next_Previous ERROR:<br><br>">
<cfparam name="Attributes.query">
<cfparam name="frompage" default="1">
<cfparam name="Attributes.record_count" default="-1">
<cfif NOT isNumeric(frompage) OR frompage EQ "">
	<cfset frompage = 1 />
</cfif>
<cfif NOT IsDefined('caller.#Attributes.query#')>
	<cfoutput>
	#error_in#
	.The query you insert, <b>#Attributes.query#</b>, in QUERY="" attribute is not defined
	<cfabort>.
	</cfoutput>
</cfif>


<cfset queryrecords    = #evaluate("caller." & Attributes.query & ".recordcount")#>
<cfif Attributes.record_count neq -1>
	<cfset queryrecords = Attributes.record_count />
</cfif>

<cfset maxrows =  caller.maxrows>

<cfset startrow =  caller.startrow>

<cfif IsDefined('Attributes.maxpages')>
	<cfif NOT IsNumeric('#Attributes.maxpages#')>
	<cfoutput>
	#error_in#
	.You insert a non numeric value, <b>#Attributes.maxpages#</b>, in MAXPAGES attribute
	</cfoutput>
	<cfabort>
	</cfif>
	<cfset maxpages = Int(Attributes.maxpages)>
<cfelse>
	<cfset maxpages = 10>
</cfif>
<cfif IsDefined('Attributes.previous')>
	<cfset previous = Attributes.previous>
<cfelse>
	<cfset previous = "<b>&lt;</b>">
</cfif>
<cfif IsDefined('Attributes.next')>
	<cfset next = Attributes.next>
<cfelse>
	<cfset next = "<b>&gt;</b>">
</cfif>

<cfif IsDefined('Attributes.previousSeries')>
	<cfset previousSeries = Attributes.previousSeries>
<cfelse>
	<cfset previousSeries = "<b>&lt;&lt;</b>">
</cfif>
<cfif IsDefined('Attributes.nextSeries')>
	<cfset nextSeries = Attributes.nextSeries>
<cfelse>
	<cfset nextSeries = "<b>&gt;&gt;</b>">
</cfif>

<!-------------------Added by Deepa on 07/29/02------------------------------------------>
<cfif IsDefined('Attributes.firstseries')>
	<cfset firstseries = Attributes.firstseries>
<!------
<!----Commented this so that u can avoid showing the first series from showing up------>
<cfelse>
	<cfset firstseries = "<b>&nbsp;&lt;&lt;&lt;</b>">
------>
</cfif>
<cfif IsDefined('Attributes.lastSeries')>
	<cfset lastSeries = Attributes.lastSeries>
<!-------
<!----Commented this so that u can avoid showing the last series from showing up------>
<cfelse>
	<cfset lastSeries = "<b>&nbsp;&gt;&gt;&gt;</b>">
---->
</cfif>
<!-------------------End Added by Deepa on 07/29/02------------------------------------------>

<cfset addparams = "">
<cfif IsDefined('Attributes.addparams')>
	<cfloop index="i" list="#Attributes.addparams#">
	<cfif IsDefined('caller.#i#')>
		<cfset addparams = Insert(addparams,"&#i#=#evaluate('URLEncodedFormat(caller.#i#)')#", 0)>
	</cfif>
	</cfloop>
</cfif>
<!--- rows --->
<cfset addparams = Insert(addparams, "&maxrows=#maxrows#", 0)>

<!--- frompage --->
<cfif IsDefined('caller.frompage_set')>
	<!--- actualitzar frompage --->
	<cfset frompage = (Int(Int(StartRow/maxrows)/maxpages))*maxpages+1>
<cfelse>
	<cfset frompage = caller.frompage>
</cfif>


<cfset file = GetFileFromPath(GetBaseTemplatePath())>

<cfif IsDefined('Attributes.droprows')>
	<cfif Attributes.droprows is "TRUE">
		<cfset droprows = "10,25,50,100">
	<cfelse>
		<cfset droprows = Attributes.droprows>
	</cfif>
	<form action="<cfoutput>#file#</cfoutput>" method="get">
</cfif>

<cfset count_less = (frompage-1) * maxrows>
<cfset divi = (queryrecords-count_less) / MaxRows>
<cfif maxpages LT Ceiling(divi)>
	<cfset pag_num=maxpages>
<cfelse>
	<cfset pag_num=Ceiling(divi)>
</cfif>
<CFOUTPUT><SCRIPT>
	function navigate(frompage, startrow){
		document.all.#Attributes.formname#.frompage.value = frompage;
		document.all.#Attributes.formname#.startrow.value = startrow;
		document.all.#Attributes.formname#.submit();
	}
</SCRIPT>
</CFOUTPUT>
<cfset pag_num = pag_num + frompage - 1>
<cfif frompage GT 1>




<!-------------------Added by Deepa on 07/29/02------------------------------------------>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- First series link --->
<cfif isDefined("firstseries")>
<cfoutput>
<cfif Evaluate(frompage\maxpages) GT 1>
	<B><a ONCLICK="navigate(1,1)" STYLE="font-size: 16px; cursor:pointer;" TITLE="First Series...">#firstseries#</a></B>
</cfif>
</cfoutput>
</cfif>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!-------------------End Added by Deepa on 07/29/02------------------------------------------>


<cfoutput>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Previous series link --->
<B><a ONCLICK="navigate(#Evaluate(frompage-maxpages)#,#IncrementValue(Evaluate((frompage-maxpages-1)*maxrows))#)" STYLE="font-size: 16px; cursor:pointer;" TITLE="Previous Series...">#previousSeries#</a></B>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->


&nbsp;

</cfoutput>
</cfif>
<cfif Evaluate(StartRow - maxrows) LT IncrementValue(Evaluate((frompage-1)*maxrows))>
	<cfset frompage_set = frompage-maxpages>
<cfelse>
	<cfset frompage_set = frompage>
</cfif>
<cfif StartRow GT maxrows>

<cfoutput>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Previous link here --->
<B><a ONCLICK="navigate(#frompage_set#,#Evaluate(StartRow - maxrows)#)" STYLE="font-size: 16px; cursor:pointer;" TITLE="Previous page...">#previous#</a></B>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

</cfoutput>

&nbsp;&nbsp;
</cfif>

<cfloop index="index" from="#frompage#" to="#pag_num#">


<cfif StartRow is Evaluate(index * maxrows - maxrows + 1)>
	<cfoutput>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- If this is the current page... --->
		<B><FONT SIZE="3">[</FONT>#index#<FONT SIZE="3">]</FONT></B>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	</cfoutput>
<cfelse>
	<cfoutput>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- If it is not the current page... --->
<a ONCLICK="navigate(#frompage#, #Evaluate(index * maxrows - maxrows + 1)#)" STYLE="font-size: 12px; cursor:pointer;">#index#</a>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	</cfoutput>
</cfif>














</cfloop>
<cfif (StartRow + MaxRows) LTE queryrecords>
<cfif Evaluate(StartRow + maxrows) GT Evaluate((frompage+maxpages-1)*maxrows)>
	<cfset frompage_set = frompage+maxpages>
<cfelse>
	<cfset frompage_set = frompage>
</cfif>


&nbsp;&nbsp;
<cfoutput>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Next link goes here... --->
<B><a ONCLICK="navigate(#frompage_set#, #Evaluate(StartRow + maxrows)#)" STYLE="font-size: 16px; cursor:pointer;" TITLE="Next page...">#next#</a></B>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
</cfoutput>

</cfif>

<cfif maxpages LT Ceiling(divi)>
<cfoutput>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Next series goes here... --->
<B>&nbsp;<a ONCLICK="navigate(#Evaluate(frompage+maxpages)#, #IncrementValue(Evaluate((frompage+maxpages-1)*maxrows))#)" STYLE="font-size: 14px; cursor:pointer;" TITLE="Next series...">#nextSeries#</a></B>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
</cfoutput>
</cfif>

<!-------------------Added by Deepa on 07/29/02------------------------------------------>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Last series goes here... --->
<cfif isDefined("lastseries")>
<cfset lastPageSet=Evaluate(queryrecords\maxrows)>
<cfset lastPageSet=maxpages*(lastPageSet\maxpages)+1>
<cfif frompage LT Evaluate(lastPageSet-maxpages)>
<cfoutput>
<B>&nbsp;<a ONCLICK="navigate(#lastPageSet#, #Evaluate((lastPageSet-1)*maxrows+1)#)" STYLE="font-size: 14px; cursor:pointer;" TITLE="Last series...">#lastseries#</a></B>
</cfoutput>
</cfif>
</cfif>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!-------------------End Added by Deepa on 07/29/02------------------------------------------>

<cfif IsDefined('Attributes.all') and maxrows is not queryrecords>
<cfoutput>
&nbsp;&nbsp;&nbsp;<a href="#file#?maxrows_old=&startrow=1&maxrows=#queryrecords#"><cfif Attributes.all is "TRUE">ALL<cfelse>#Attributes.all#</cfif></a>
</cfoutput>
</cfif>

<cfif IsDefined('droprows')>

<cfif ListFind(droprows, maxrows, ",") is 0>
	<cfset droprows = ListInsertAt(droprows, 1, maxrows, ",")>
	<cfset droprows = ListSort(droprows, "numeric", "asc", ",")>
</cfif>

	<input type="hidden" name="maxrows_old">
	<input type="hidden" name="StartRow" value="<cfoutput>#startrow#</cfoutput>">
	&nbsp;<select name="maxrows">
	<cfset selected_x = 0>
	<cfloop index="i" list="#droprows#">
		<cfoutput><option <cfif i is maxrows>selected <cfset selected_x = 1></cfif>>#i#</cfoutput>
	</cfloop>
	<cfif selected_x is 0>
		<option selected><cfoutput>#maxrows#</cfoutput>
	</cfif>
	</select>
	<input type="submit" value="&gt;" style="font-size:9pt">
	</form>
</cfif>
<!--- /end CF_Next_Previous --->
