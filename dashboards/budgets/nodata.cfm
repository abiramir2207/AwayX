<style>

div.button
{
	border:					2px #333333 solid;
	width:					300px;
	padding:				0px 0px 0px 0px;
	margin:					12px 12px 12px 12px;

    -webkit-border-radius:	10px;
    -moz-border-radius:		10px;
    border-radius:			10px;

    background-image:	-ms-linear-gradient(top, #616161 0%, #0c0c0c 100%);/* ie10 */ 
    background-image:	-moz-linear-gradient(top, #616161 0%, #0c0c0c 100%);/* mozilla firefox */ 
    background-image:	-o-linear-gradient(top, #616161 0%, #0c0c0c 100%);/* opera */ 
    background-image:	-webkit-gradient(linear, left top, left bottom, color-stop(0, #616161), color-stop(1, #0c0c0c));/* webkit:safari/chrome 10 */
    background-image:	-webkit-linear-gradient(top, #616161 0%, #0c0c0c 100%);/* webkit (chrome 11+) */ 
    background-image:	linear-gradient(top, #616161 0%, #0c0c0c 100%);/* proposed w3c markup */ 

	float: 				inherit;
	height:				60px;
	text-align:			left;
	
}


a.button,a.button:hover,a.button:visited,a.button:hover
{
	font-family:			Arial, Helvetica, sans-serif;
	font-size:				14px;
	font-weight:			bold;
	line-height:			45px;
	color:					#ffffff;
	text-decoration:		none;
}

span.button_image
{
	margin:					0px 5px 0px 3px;
	padding:				5px 0px 0px 10px;

	float:left;
	text-align:center;
}

span.button_text
{
	font-family:			Arial, Helvetica, sans-serif;
	font-size:				14px;
	font-weight:			bold;
	text-align:				left;

	padding:				0px 10px 0px 0px;
	line-height:			55px;
}

</style>

<body>

<br />




<table cellpadding="0" cellspacing="0">
	<tr>
    	<td>
            <a class="button" href="display.cfm?content=11554512">
            <div class="button">
            <span class="button_image"><img src="images/red.png"></span>
            <span class="button_text"><cfoutput>#zone_label#</cfoutput></span>
            </div>
            </a>
        </td>
    	<td>
            <a class="button" href="display.cfm?content=93767531">
            <div class="button">
            <span class="button_image"><img src="images/red.png"></span>
            <span class="button_text"><cfoutput>#zone_detail_label#</cfoutput></span>
            </div>
            </a>
        </td>
	</tr>
</table>



