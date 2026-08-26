<!--- Check for existance of a UUID attribute 
      to load the attributes from SESSION --->
<cfif IsDefined("Attributes_internalUUID")>
	<!--- Fetch all attributes from the SESSION scope 
	      using the provided UUID as the key --->
	<cflock scope="SESSION" type="READONLY" timeout="10">
	   <cfset attributes = StructCopy(SESSION[Attributes_internalUUID])>
	</cflock>
	<cfset bGenerateSVG = true>
<cfelse>
	<cfset bGenerateSVG = false>
</cfif>	
<!--- Define required parameters --->
<cfparam name="Attributes_lineArray" type="array">
<!--- Define optional parameters --->
<cfparam name="Attributes_width" default="350" type="numeric">
<cfparam name="Attributes_height" default="350" type="numeric">
<cfparam name="Attributes_titleXAxis" default="" type="string">
<cfparam name="Attributes_titleYAxis" default="" type="string">
<cfparam name="Attributes_backgroundColor" default="" type="string">
<cfif NOT Len(Attributes_backgroundColor)>
	<cfset Attributes_backgroundColor = "none">
</cfif>

<!--- There must be at least 1 lines: --->
<cfif ArrayLen(Attributes_lineArray) LT 1>
	<cfthrow type="LineChart.InvalidConditionException.NotEnoughLines" 
		 message="There must be at least 1 line" errorcode="1">
</cfif>
<!--- ********************************** --->	
<!---  Embed the SVG-call into the HTML  --->
<!--- ********************************** --->	
<cfif NOT bGenerateSVG>
	<!--- Remember to place all attributes into SESSION-scope 
	(keyed by a UUID allowing multiple instances within one page) --->
	<cfset myUUID = CreateUUID()>
	<cflock scope="SESSION" type="EXCLUSIVE" timeout="10">
		<cfset SESSION[myUUID] = attributes>
	</cflock>
	<!--- Embed the SVG-call into the HTML document --->
	<cfset myURL = ListDeleteAt(CGI.SCRIPT_NAME, ListLen(CGI.SCRIPT_NAME,"/"), "/") & "/lineChartLoader.cfm?uuid=#myUUID#">
	<cfoutput>
		<EMBED SRC="#myURL#" 
			   NAME="myEmbed" 
			   HEIGHT="#Attributes_height#" WIDTH="#Attributes_width#" 
			   TYPE="image/svg+xml" 
			   PLUGINSPAGE="http://www.adobe.com/svg/viewer/install/"></EMBED>
	</cfoutput>
<!--- *********************************** --->	
<!---  Generate the SVG data dynamically  --->
<!--- *********************************** --->	
<cfelse>
	<!--- Get minimum and maximum values --->	
	<cfset datedifflist="">
	<cfif isdefined("Attributes_zerobased")>
		<cfset nMinX = 0>
		<cfset nMinY = 0>
	</cfif>
	<cfloop index="i" from=1 to=#ArrayLen(Attributes_lineArray)#>
		<cfset aline = Attributes_lineArray[i]>
		<cfif isdefined("Attributes_xdates")>
			<cfset xarray=arraynew(1)>
			<!--- we need to change dates into a numeric value - calc diff to 1/1/2000 --->
			<cfset temp_xarray=listtoarray(aline.x)>
			<cfset temp_list="">
			<cfloop from="1" to="#arraylen(temp_xarray)#" index="e">
				<cfif Attributes_xdates is "US">
				<cfset temp_day=gettoken(temp_xarray[e], 2, "/")>
				<cfset temp_month=gettoken(temp_xarray[e], 1, "/")>
				<cfelse>
				<cfset temp_day=gettoken(temp_xarray[e], 1, "/")>
				<cfset temp_month=gettoken(temp_xarray[e], 2, "/")>
				</cfif>
				<cfset temp_year=gettoken(temp_xarray[e], 3, "/")>
				<cfset val=DateDiff("d", CreateDate(2000, 01, 01), CreateDate(temp_year, temp_month, temp_day))>
				<cfset temp_list=listappend(temp_list, val)>
				<cfset datedifflist=listappend(datedifflist, val)>
			</cfloop>
			<cfset temp_array=listtoarray(temp_list)>
			<cfset temp_min=arraymin(temp_array)>
			<!--- zero values --->
			<cfloop from="1" to="#arraylen(temp_array)#" index="a">
				<cfset xarray[a]=temp_array[a]-temp_min>
			</cfloop>
		<cfelse>
			<cfset xarray = listtoarray(aline.x)>
		</cfif>
		<cfset yarray = listtoarray(aline.y)>
		<cfif i eq 1>
			<cfif not isdefined("Attributes_zerobased")>
				<cfset nMinX=arraymin(xarray)>
				<cfset nMinY=arraymin(yarray)>
			</cfif>
			<cfset nMaxX=arraymax(xarray)>
			<cfset nMaxY=arraymax(yarray)>
		<cfelse>
		<!--- X --->
		<cfif arraymax(xarray) GT nMaxX>
			<cfset nMaxX = arraymax(xarray)>
		<cfelseif arraymin(xarray) LT nMinX>
			<cfset nMinX = arraymin(xarray)>
		</cfif>
		<!--- Y --->
		<cfif arraymax(yarray) GT nMaxY>
			<cfset nMaxY = arraymax(yarray)>
		<cfelseif arraymin(yarray) LT nMinY>
			<cfset nMinY = arraymin(yarray)>
		</cfif>
		</cfif>
	</cfloop>
	<!--- calc no. of x sections if dates used --->
	<cfif isdefined("Attributes_xdates")>
		<cfset days=nMaxX-nMinX>
		<cfif isdefined("Attributes_xyear")>
			<cfset sections=days/365>
			<cfset addpercent=80/sections>
		<cfelseif isdefined("Attributes_xmonth")>
			<cfset sections=round(days/(365/12))>
			<cfset addpercent=80/sections>
		<cfelseif isdefined("Attributes_xweek")>
			<cfset sections=days/7>
			<cfset addpercent=80/sections>
		<cfelseif isdefined("Attributes_xday")>
			<cfset sections=days>
			<cfset addpercent=80/sections>
		</cfif>
	</cfif>
	<!--- set date offset --->
	<cfif isdefined("Attributes_xdates")>
		<cfset dateoff=listtoarray(datedifflist)>
		<cfset dateoffset=arraymin(dateoff)>
	</cfif>	
	<!--- // Calculate min and max values for the axis // --->
	<!--- X-Axis --->
	<cfset nXAxisStart = nMinX>
	<cfset nXAxisEnd = nMaxX>
	<!--- X-Padding --->
	<cfif isdefined("Attributes_xpadding")>
		<cfif isdefined("Attributes_xpaddingfactor")>
			<cfset nPaddingX = ((nXAxisEnd - nXAxisStart) / (Attributes_xpaddingfactor*20)) * (Attributes_height/Attributes_width)>
		<cfelse>
			<cfset nPaddingX = ((nXAxisEnd - nXAxisStart) / 20) * (Attributes_height/Attributes_width)>
		</cfif>
	<cfelse>
		<cfset nPaddingX = 0>
	</cfif>
	<cfset nXAxisStart = nXAxisStart - nPaddingX>
	<cfset nXAxisEnd = nXAxisEnd + nPaddingX>
	<cfif isdefined("Attributes_xdates")>
		<cfset nAxisStepWidthX = (nXAxisEnd - nXAxisStart) / sections>
	<cfelse>
		<cfset nAxisStepWidthX = (nXAxisEnd - nXAxisStart) / 10>
	</cfif>
	<!--- Y-Axis --->
	<cfset nYAxisStart = nMinY>
	<cfset nYAxisEnd = nMaxY>
	<!--- Y-Padding --->
	<cfif isdefined("Attributes_ypadding")>
		<cfif isdefined("Attributes_ypaddingfactor")>
			<cfset nPaddingY = ((nYAxisEnd - nYAxisStart) / (Attributes_ypaddingfactor*20)) * (Attributes_width/Attributes_height)>
		<cfelse>
			<cfset nPaddingY = ((nYAxisEnd - nYAxisStart) / 20) * (Attributes_width/Attributes_height)>
		</cfif>
	<cfelse>
	<cfset nPaddingy = 0>
	</cfif>
		<cfset nYAxisStart = nYAxisStart - nPaddingY>
		<cfset nYAxisEnd = nYAxisEnd + nPaddingY>
	<cfset nAxisStepWidthY = (nYAxisEnd - nYAxisStart) / 10>
	<!--- // Calculate a step-width for the x- and y-axis // --->
	<!--- X-Axis --->
	<cfset nlineStepWidthX = (nXAxisEnd - nXAxisStart) / 80>
	<!--- Y-Axis --->
	<cfset nlineStepWidthY = (nYAxisEnd - nYAxisStart) / 80>
	<!--- Suppress Debug-Output !! --->
	<cfsetting showdebugoutput="No">
	<!--- Set MIME-Type and reset everything that 
	      was sent to the client before here --->
	<cfcontent type="image/svg+xml" reset="Yes"><?xml version="1.0" standalone="no"?>
	<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.0//EN"
	"http://www.w3.org/TR/2001/REC-SVG-20010904/DTD/svg10.dtd">
	<!--- // Output the SVG // --->
	<cfoutput>
		<svg width="100%" height="100%">
			<!--- Title --->
			<title>Line-Chart</title>
			<!--- Description --->
			<desc>This graph draws a demo line chart</desc>
			<!--- Background --->
			<g>
				<rect x="0%" y="0%"
				      width="100%" height="100%"
				 style="fill:#Attributes_backgroundColor#"/>
			</g>
			<!--- Axis Lines --->
			<g style="stroke:black; stroke-width:1.2px">
				<!--- X-Axis --->
				<line x1="10%" y1="90%"
				      x2="90%" y2="90%"/>
				<!--- Y-Axis --->
				<line x1="10%" y1="10%"
				      x2="10%" y2="90%"/>
			</g>
			<!--- Axis Titles --->
			<g style="fill:navy; font-size:10pt">
				<!--- X-Axis --->
				<text x="99%" y="99%"
				 style="text-anchor:end">
				   #Attributes_titleXAxis#
				</text>
				<!--- Y-Axis --->
				<text x="1%" y="5%">
				   #Attributes_titleYAxis#
				</text>
			</g>	
			<!--- Grid Lines --->
			<g style="stroke:gray; stroke-width:0.2px;">
				<cfif isdefined("Attributes_xdates")>
					<!--- X-Axis --->
					<cfloop index="i" from="1" to="#sections#">
						<cfset tmpX = (i * addpercent) + 10>
						<line x1="#tmpX#%" y1="10%"
							  x2="#tmpX#%" y2="92%"/>
					</cfloop>
				<cfelse>
					<!--- X-Axis --->
					<cfloop index="i" from="1" to="11">
						<cfset tmpX = (i * 8) + 2>
						<line x1="#tmpX#%" y1="10%"
							  x2="#tmpX#%" y2="92%"/>
					</cfloop>
				</cfif>
				<!--- Y-Axis --->
				<cfloop index="i" from="1" to="11">
					<cfset tmpY = (i * 8) + 2>
					<line x1="90%" y1="#tmpY#%"
						  x2="08%" y2="#tmpY#%"/>
				</cfloop>
			</g>
			<!--- Grid Values --->
			<g style="fill:gray; font-size:8pt;">
				<!--- X-Axis --->
				<g style="text-anchor:middle">
					<cfif isdefined("Attributes_xdates")>
						<cfloop index="i" from="0" to="#sections#">
							<cfset tmpX = ((i) * addpercent) + 10>
							<cfset tmpValue = (i * nAxisStepWidthX) + nXAxisStart>
							<cfif NOT tmpValue CONTAINS ".">
								<cfset tmpValue=tmpValue&".0">
							</cfif>
							<cfset old_date=CreateDate(2000, 01, 01)>
							<cfset date_add=tmpvalue+dateoffset>
							<cfset newDate=DateAdd("d", date_add, old_date)>
							<text x="#tmpX#%" y="95%">#DateFormat(newDate, "dd mmm")#</text>
						</cfloop>
					<cfelse>
						<cfloop index="i" from="1" to="11">
							<cfset tmpX = (i * 8) + 2>
							<cfset tmpValue = ((i-1) * nAxisStepWidthX) + nXAxisStart>
							<cfif NOT tmpValue CONTAINS ".">
								<cfset tmpValue=tmpValue&".0">
							</cfif>
							<text x="#tmpX#%" y="95%">#tmpValue#</text>
						</cfloop>
					</cfif>
				</g>
				<!--- Y-Axis --->
				<g style="text-anchor:end;">
					<cfloop index="i" from="1" to="11">
						<cfset tmpY = (i * 8) + 3>
						<cfset tmpValue = nYAxisEnd - ((i-1) * nAxisStepWidthY)>
						<cfset tmpValue = (tmpValue*10)/10>
						<cfif NOT tmpValue CONTAINS ".">
							<cfset tmpValue=tmpValue&".0">
						</cfif>
						<text x="7%" y="#tmpY#%">#tmpValue#</text>
					</cfloop>
				</g>
			</g>
			<!--- Draw lines ---> 
			<g style="fill-opacity:0.6;">
				<cfset datearray=arraynew(1)>
				<cfset mx=1>	
				<cfloop index="i" 
					from=1 
					to=#ArrayLen(Attributes_lineArray)#>
					<cfset aline = Attributes_lineArray[i]>
					<cfif isdefined("Attributes_xdates")>
						<cfset xarray=arraynew(1)>
						<!--- we need to change dates into a numeric value - calc diff to 1/1/2000 --->
						<cfset temp_xarray2=listtoarray(aline.x)>
						<cfset temp_list="">
						<cfloop from="1" to="#arraylen(temp_xarray2)#" index="e">
							<cfif Attributes_xdates is "US">
							<cfset temp_day=gettoken(temp_xarray2[e], 2, "/")>
							<cfset temp_month=gettoken(temp_xarray2[e], 1, "/")>
							<cfelse>
							<cfset temp_day=gettoken(temp_xarray2[e], 1, "/")>
							<cfset temp_month=gettoken(temp_xarray2[e], 2, "/")>							
							</cfif>
							<cfset temp_year=gettoken(temp_xarray2[e], 3, "/")>
							<cfset val=DateDiff("d", CreateDate(2000, 01, 01), CreateDate(temp_year, temp_month, temp_day))>
							<cfset temp_list=listappend(temp_list, val)>
							<cfset datedifflist=listappend(datedifflist, val)>
						</cfloop>
						<cfset temp_array=listtoarray(temp_list)>
						<cfset temp_min=arraymin(temp_array)>
						<cfset datearray[mx]=arraymin(temp_array)>
						<cfset mx=IncrementValue(mx)>
						<cfset datearray[mx]=arraymin(temp_array)>
						<cfset mx=IncrementValue(mx)>
						<!--- zero values --->
						<cfloop from="1" to="#arraylen(temp_array)#" index="a">
							<cfset xarray[a]=temp_array[a]-temp_min>
						</cfloop>
					<cfelse>
						<cfset xarray = listtoarray(aline.x)>
					</cfif>
					<cfset yarray = listtoarray(aline.y)>
					<!--- URL-Link --->
					<cfif Len(aline.url)>
						<a xlink:href="#aline.url#" 
						   xlink:title="#aline.alt#"
						   target="#aline.target#">
					</cfif>
					<!--- loop through elements of x, y values --->
					<cfloop from="1" to="#arraylen(yarray)#" index="a">
					<cfset b=a+1>
					<cfif b lte arraylen(yarray)>
					<!--- Calculate Position --->
					<cfset tmpPosX1 = ((xarray[a] - nXAxisStart) / nlineStepWidthX) + 10>
					<cfset tmpPosX2 = ((xarray[b] - nXAxisStart) / nlineStepWidthX) + 10>
					<cfset tmpPosY1 = 90 - ((yarray[a] - nYAxisStart) / nlineStepWidthY)>
					<cfset tmpPosY2 = 90 - ((yarray[b] - nYAxisStart) / nlineStepWidthY)>
					<!--- // The Line // --->
					<line id="line#a#"
							x1="#tmpPosX1#%" 
							x2="#tmpPosX2#%" 
							y1="#tmpPosY1#%" 
							y2="#tmpPosY2#%"
							style="fill:#aline.color#; stroke:#aline.color#; stroke-width:#aline.width#">
							<!--- Animated Attribute: Length --->
						    <animate attributeName="opacity" attributeType="CSS"
						             begin="0s" dur="3.0s" 
									 fill="freeze" 
									 from="0" 
									 to="1"/>
					</line> 
					</cfif>
					</cfloop>
					<cfif Len(aline.url)></a></cfif>
				</cfloop>
			</g>	
			--->		
		</svg>	
	</cfoutput>
	<!--- Exit EVERYTHING so no junk will be sent after here --->
	<cfabort>
</cfif>
