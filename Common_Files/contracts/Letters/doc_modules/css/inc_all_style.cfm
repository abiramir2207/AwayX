<cfsilent>
<!--- 
FILE: 		
FILENAME: 	doc_modules/css/inc_all_style.cfm
CREATED: 	12/19/2007 - RBL
EDITED:		05/09/2008 - RBL

FUNCTIONALITY:
- This template is used for embedded CSS to be employed with all files associated with the deal letters...

Options Legend:
Before Small = header-.6em, body-.5em, h1-1.1em, h2-1em, h3-.9em, footer-.5em, clause-1.1em, freight-.5em
After Mid = header-.7em, body-.6em, h1-1em, h2-.9em, h3-.8em, footer-.6em, clause-1.2em, freight-.6em
After Large = header-.8em, body-.7em, h1-1.3em, h2-1.2em, h3-1.1em, footer-.7em, clause-1.3em, freight-.7em

--->

<!--- These parameters are required for this template to process correctly --->
<cfparam name="thisTag.preferred_fontFamily" 	type="string" 	default="Century Gothic">
<cfparam name="thisTag.doc_type"		type="string"	default="pdf">

</cfsilent>

<cfoutput>
  <cfswitch expression="#thisTag.doc_type#">
    <cfcase value="pdf">
    	<style media="print,screen">
				//em here
					.header_text {
					color : ##000000;
					font-family:"#thisTag.preferred_fontFamily#", "Times New Roman", Times, serif;
					font-size:.99em;
				}
					body, body table tr td, p {
					color : ##000000;
					font-family:"#thisTag.preferred_fontFamily#", "Times New Roman", Times, serif;
					font-size:.7em;
					white-space:normal;
				}
					h1 .redText {
						font-size:1em;
						<!--- was 1.1 5/09/08 --->
				}
					h2 .redText {
						font-size:.9em;
						<!--- was 1 5/09/08 --->
				}
					h3 .redText {
						font-size:.8em;
						<!--- was .9 5/09/08 --->
				}
					.footer_text {
					color : ##000000;
					font-family:"#thisTag.preferred_fontFamily#", "Times New Roman", Times, serif;
					font-size:.6em;
				}
					.clause_text {
					color : ##000000;
					font-family:"#thisTag.preferred_fontFamily#", "Times New Roman", Times, serif;
					font-size:1.2em;
				}
				 	.noBorderNoPadNoMargin {
						border-left-width:0em;
						border-bottom-width:0em;
						border-right-width:0em;
						border-top-width:0em;
						margin-bottom:0em;
						margin-left:0em;
						margin-right:0em;
						margin-top:0em;
						padding-bottom:0em;
						padding-left:0em;
						padding-right:0em;
						padding-top:0em;
				}
					a:link, a:visited {
					color : ##00008B;
					font-family:"#thisTag.preferred_fontFamily#", "Times New Roman", Times, serif;
					text-decoration : none;
				}
					a:hover {
					color : ##00008B;
					font-family:"#thisTag.preferred_fontFamily#", "Times New Roman", Times, serif;
					text-decoration:underline;
				}
					.redText {
					color: ##990000;
					font-family:"#thisTag.preferred_fontFamily#", "Times New Roman", Times, serif;
				}
					.whiteText {
					color: ##ffffff;
					font-family:"#thisTag.preferred_fontFamily#", "Times New Roman", Times, serif;
				}
					.grayBG {
					background-color: ##eeeeee;
				}
					.darkGrayBG {
					background-color: ##333333;
				}
					.blackBG {
					background-color: ##000000;
				}
					.whiteBG {
					background-color: ##ffffff
				}
				

				
				// purposely leaving the following as pixels...
					.thinBottomBorder {
					border-bottom: 1px solid ##000000;
				}
					.thinTopBorder {
					border-top: 1px solid ##000000;
				}
					.thinLeftBorder {
					border-left: 1px solid ##000000;
				}
					.thinRightBorder {
					border-right: 1px solid ##000000;
				}
					.height_50 {
				height:50px; min-height:50px;	
				}
					.height_100 {
				height:100px; min-height:100px;
				}
					.width_100 {
				width:100px; min-width:100px; 	
				}
					.width_150 {
				width:150px; min-width:150px;
				}
					.width_200 {
				width:200px; min-width:200px;
				}
					.width_250 {
				width:250px; min-width:250px;	
				}
					.width_300 {
				width:300px; min-width:300px;	
				}
					.width_400 {
				width:400px; min-width:400px;
				}
					.width_500 {
				width:500px; min-width:500px;
				}
				.hRule {
					height:1px; width:100%;
				}
				.top {vertical-align:top;}
				<!--- added back in 'overflow:visible;' 5/09/08  --->
				##contentWrapper {vertical-align:text-top; margin-bottom:0em; margin-top:1em; padding-top:0em; border-top:none; overflow:visible; }
				##headerWrapper {vertical-align:text-bottom; margin-bottom:0em; margin-top:0em; padding-bottom:0em; border-bottom:none; }
				##introWrapper {vertical-align:text-top; margin-bottom:0em; margin-top:1em; padding-top:0em; border-top:none; }
			</style>
    </cfcase>
    <cfcase value="html">
    	<style media="print,screen">
				//px here
					.header_text {
					color : ##000000;
					font-family:"#thisTag.preferred_fontFamily#", "Times New Roman", Times, serif;
					font-size:10px;
				}
					body, body table tr td, p {
					color : ##000000;
					font-family:"#thisTag.preferred_fontFamily#", "Times New Roman", Times, serif;
					font-size:9px;
				}
					.footer_text {
					color : ##000000;
					font-family:"#thisTag.preferred_fontFamily#", "Times New Roman", Times, serif;
					font-size:9px;
				}
					.clause_text {
					color : ##000000;
					font-family:"#thisTag.preferred_fontFamily#", "Times New Roman", Times, serif;
					font-size:.5em;
				}
					a:link, a:visited {
					color : ##00008B;
					font-family:"#thisTag.preferred_fontFamily#", "Times New Roman", Times, serif;
					text-decoration : none;
				}
					a:hover {
					color : ##00008B;
					font-family:"#thisTag.preferred_fontFamily#", "Times New Roman", Times, serif;
					text-decoration:underline;
				}
					.redText {
					color: ##990000;
					font-family:"#thisTag.preferred_fontFamily#", "Times New Roman", Times, serif;
				}
					.whiteText {
					color: ##ffffff;
					font-family:"#thisTag.preferred_fontFamily#", "Times New Roman", Times, serif;
				}
					.thinBottomBorder {
					border-bottom: 1px solid ##000000;
				}
					.thinTopBorder {
					border-top: 1px solid ##000000;
				}
					.thinLeftBorder {
					border-left: 1px solid ##000000;
				}
					.thinRightBorder {
					border-right: 1px solid ##000000;
				}
					.grayBG {
					background-color: ##eeeeee;
				}
					.darkGrayBG {
					background-color: ##333333;
				}
					.blackBG {
					background-color: ##000000;
				}
					.whiteBG {
					background-color: ##ffffff
				}
					.width_100 {
				width:100px;	
				}
					.width_200 {
				width:200px;	
				}
					.width_300 {
				width:300px;	
				}
					.width_400 {
				width:400px;
				}
			</style>
    </cfcase>
  </cfswitch>
</cfoutput>