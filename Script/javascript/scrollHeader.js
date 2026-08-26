function keepHeaderFixed(topPosition,leftPosition)
{
	var top_position = topPosition + 'px';
	var left_position = leftPosition + 'px';

	$(".headerTop").css({top: top_position }); 
	$(".headerTopAndLeft").css({top: top_position }); 

	$(".headerLeft").css({left: left_position }); 
	$(".headerTopAndLeft").css({left: left_position }); 
}