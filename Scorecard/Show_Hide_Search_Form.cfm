<CFPARAM NAME="show_hide_type" 	DEFAULT="1">
<CFOUTPUT>
<SCRIPT LANGUAGE="JavaScript" TYPE="text/javascript">
     <!--
		function switchLayer(lyrID, title, titleclosed, borderwidth, imageA,imageB, colorA,colorB)
		{

			var iFrameOBj = document.all.Search_Result;
			var increaseLength = #increaseLength#;
			var increasePageLength = #increasePageLength#;
			var searchForm = document.all.SearchForm;

			if (document.all.length)
			{
				// Determine if the layer is currently expanded or collapsed:
				var tmpStatus;
				eval("tmpStatus = document.all.lyrGroup_"+ lyrID +".style.display");
				// OK, then now expand or collapse it...
				if (tmpStatus == 'none')
				{
					eval("document.all.lyrGroup_"+ lyrID +".style.display='block';");
					eval("document.all.border_"+ lyrID +".style.borderWidth='"+borderwidth+"px';");
					eval("document.all.title_"+ lyrID +".innerHTML='"+title+"';");
					tmpImage = imageA;
					tmpColor = colorA;
					<cfif show_hide_type EQ 1>
						if(iFrameOBj)
							iFrameOBj.height = (iFrameOBj.height ? parseFloat(iFrameOBj.height) : 500) - parseFloat(increaseLength);
						searchForm.pageLength.value = parseFloat(searchForm.pageLength.value) - increasePageLength;
					<cfelse>
						<!------ hide result ----->
						var TableHeadOBj = document.all.Table_Header;
						TableHeadOBj.style.display = "none";
						iFrameOBj.style.display = "none";
					</cfif>
				}
				else
				{
					eval("document.all.lyrGroup_"+ lyrID +".style.display='none'");
					eval("document.all.border_"+ lyrID +".style.borderWidth='0px';");
					eval("document.all.title_"+ lyrID +".innerHTML='"+titleclosed+"';");
					tmpImage = imageB;
					tmpColor = colorB;
					<cfif show_hide_type EQ 1>
						// 17294 RBL [begin]
						if(iFrameOBj)
							iFrameOBj.height = (iFrameOBj.height ? parseFloat(iFrameOBj.height) : 500) + parseFloat(increaseLength);
						// 17294 RBL [end]
						searchForm.pageLength.value = parseFloat(searchForm.pageLength.value) + increasePageLength;
					<cfelse>
						<!------ show result ----->
						var TableHeadOBj = document.all.Table_Header;
						TableHeadOBj.style.display = "block";
						iFrameOBj.style.display = "block";
						if(bNoPrevSearch)
						{
							//searchForm.submit();
							bNoPrevSearch = false;
						}
					</cfif>
				}
				// If an image is used as the click-control, switch it...
				if ((tmpImage != null) && (imageA != imageB))
				{
					eval("document.all.image_"+ lyrID +".src='"+tmpImage+"'");
				}
				// If different title-colors are used, switch them...
				if (tmpColor != '')
				{
					eval("document.all.title_"+ lyrID +".style.color='"+tmpColor+"'");
				}

				<cfif show_hide_type EQ 1>
					//searchForm.submit();
				</cfif>
			}
		}

     //-->
     </SCRIPT>
	 </CFOUTPUT>