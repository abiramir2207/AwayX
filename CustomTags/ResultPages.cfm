<!--- CF_ROWS/CF_RESULTPAGES custom tags
		
What these do:
		Display the Result Pages of a query and let you link to next o previous	pages and next and previous series of pages. So you can pass from ten to ten pages or the number you specify in maxpages="". The default result	looks such the follow:
		
			1 2 3 4 5 6 7 8 9 10 > >>
		
		The number of the current page is not linked.
			
		You can change the arrows by a text and even a img tag using a simple quote. So you can get the displayed such this example:
		
			[Previous 5 pages] Previous 11 12 13 14 15 Next [Next 5 pages]
		
		You can complete the output writing in your language the follow:
		
			Results Pages #queryname.recordcount# <CF_ResultPages ...> 	

How to apply it:
		Keep in mind in write first the CF_ROWS, before the cfoutput or cfloop of your query. These CF tags have to have specified attributes. It's explained how in the Syntax.
		Afterwards write the CF_RESULTPAGES whom will output the Results Pages.
				
Syntax:

CF_ROWS	
		<CF_Rows
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
					  variables. This's done by CF_ROWS
---------------------------------

CF_RESULTPAGES	
			
			<CF_ResultPages
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
			<cf_Rows>
			
			<cfoutput query="q" startrow="#StartRow#" maxrows="#MaxRows#"> 

			</cfoutput>
			
			<cf_ResultPages query="q">
			
			
Copy'n'paste (Advanced):
			<cf_Rows maxrows="12">
			
			<cfoutput query="q" startrow="#StartRow#" maxrows="#MaxRows#"> 

			</cfoutput>
			
			<CF_ResultPages
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
<!--CF_RESULTPAGES Custom tag
	Lluís Casany
	http://www.fruir.net/web/JustApp -->
<!--- CF_RESULTPAGES code --->	

<!---  --->
<cfset error_in="CF_RESULTPAGES ERROR:<br><br>">
<cfparam name="attributes.query">
<cfif NOT IsDefined('caller.#attributes.query#')>
	<cfoutput>
	#error_in#
	.The query you insert, <b>#attributes.query#</b>, in QUERY="" attribute is not defined
	<cfabort>.
	</cfoutput>
</cfif>

<cfset queryrecords    = #evaluate("caller." & attributes.query & ".recordcount")#>

<cfset maxrows =  caller.maxrows>

<cfset startrow =  caller.startrow>

<cfif IsDefined('attributes.maxpages')>
	<cfif NOT IsNumeric('#attributes.maxpages#')>
	<cfoutput>
	#error_in#
	.You insert a non numeric value, <b>#attributes.maxpages#</b>, in MAXPAGES attribute
	</cfoutput>
	<cfabort>
	</cfif>
	<cfset maxpages = Int(attributes.maxpages)>
<cfelse>
	<cfset maxpages = 10>
</cfif>
<cfif IsDefined('attributes.previous')>
	<cfset previous = attributes.previous>
<cfelse>
	<cfset previous = "<b>&lt;</b>">
</cfif>
<cfif IsDefined('attributes.next')>
	<cfset next = attributes.next>
<cfelse>
	<cfset next = "<b>&gt;</b>">
</cfif>

<cfif IsDefined('attributes.previousSeries')>
	<cfset previousSeries = attributes.previousSeries>
<cfelse>
	<cfset previousSeries = "<b>&lt;&lt;</b>">
</cfif>
<cfif IsDefined('attributes.nextSeries')>
	<cfset nextSeries = attributes.nextSeries>
<cfelse>
	<cfset nextSeries = "<b>&gt;&gt;</b>">
</cfif>

<cfset addparams = "">
<cfif IsDefined('attributes.addparams')>
	<cfloop index="i" list="#attributes.addparams#">
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
</cfif>
<cfparam name="frompage" default="1">

<cfset file = GetFileFromPath(GetBaseTemplatePath())>

<cfif IsDefined('attributes.droprows')>
	<cfif attributes.droprows is "TRUE">
		<cfset droprows = "10,25,50,100">
	<cfelse>
		<cfset droprows = attributes.droprows>
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
<cfset pag_num = pag_num + frompage - 1>
<cfif frompage GT 1>

<cfoutput>
<a href="#file#?frompage=#Evaluate(frompage-maxpages)#&StartRow=#IncrementValue(Evaluate((frompage-maxpages-1)*maxrows))##addparams#">#previousSeries#</a>


&nbsp;

</cfoutput>
</cfif>
<cfif Evaluate(StartRow - maxrows) LT IncrementValue(Evaluate((frompage-1)*maxrows))>
	<cfset frompage_set = frompage-maxpages>
<cfelse>
	<cfset frompage_set = frompage>
</cfif>
<cfif StartRow GT maxrows>
<!--- Previous link here --->
<cfoutput><a href="#file#?frompage=#frompage_set#&StartRow=#Evaluate(StartRow - maxrows)##addparams#" STYLE="font-size: 14px;" TITLE="Previous page...">#previous#</a>
</cfoutput>

&nbsp;&nbsp;
</cfif>
<cfloop index="index" from="#frompage#" to="#pag_num#">



<cfif StartRow is Evaluate(index * maxrows - maxrows + 1)>
	<cfoutput>
		<SPAN STYLE="background-color: Red; color: White;"><b>&nbsp;#index#&nbsp;</b></SPAN>
	</cfoutput>
<cfelse>
	<cfoutput>
		<!--- Individual link page numbers --->
		<a href="#file#?frompage=#frompage#&StartRow=#Evaluate(index * maxrows - maxrows + 1)##addparams#" STYLE="font-size: 12px;">#index#</a>
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
<!--- Next link goes here --->
<cfoutput>
<a href="#file#?frompage=#frompage_set#&StartRow=#Evaluate(StartRow + maxrows)##addparams#" STYLE="font-size: 14px;" TITLE="Next page...">#next#</a>
</cfoutput>

</cfif>

<cfif maxpages LT Ceiling(divi)>
<cfoutput>
&nbsp;<a href="#file#?frompage=#Evaluate(frompage+maxpages)#&StartRow=#IncrementValue(Evaluate((frompage+maxpages-1)*maxrows))##addparams#">#nextSeries#</a>
</cfoutput>
</cfif>

<cfif IsDefined('attributes.all') and maxrows is not queryrecords>
<cfoutput>
&nbsp;&nbsp;&nbsp;<a href="#file#?maxrows_old=&startrow=1&maxrows=#queryrecords#"><cfif attributes.all is "TRUE">ALL<cfelse>#attributes.all#</cfif></a>
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
<!-- /end CF_RESULTPAGES -->
