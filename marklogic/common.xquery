xquery version '1.0-ml';
module namespace common = "http://calldei.com/modules/xqgraph/marklogic/common";
import module namespace functx = "http://www.functx.com" at "/MarkLogic/functx/functx-1.0-nodoc-2007-01.xqy";
import module namespace xqgraph = "http://calldei.com/modules/xqgraph" at "../xqgraph.xquery" ;



declare variable $common:blank := text { "&#160;" };
declare variable $common:nl  := "&#10;" ;




declare	function common:twodigits( $val as xs:integer )
{
	if( $val lt 10 ) then 
		fn:concat( "0" , $val )
	else
		xs:string( $val )

};


declare function common:formatHour( $d as xs:dateTime ) as xs:string
{

	fn:format-dateTime( $d , "[H01]")

};

declare function common:formatSecond( $d as xs:dateTime ) as xs:string
{

	fn:format-dateTime( $d , "[s01]")

};

declare function common:formatMinute( $d as xs:dateTime ) as xs:string
{

	fn:format-dateTime( $d , "[m01]")

};

declare function common:formatDate( $d as xs:date ) as xs:string
{

	fn:format-date( $d , "[Y0001]-[M01]-[D01]")

};

declare function common:formatTime( $d ) as xs:string
{
	if( fn:empty($d) ) then "0" else

	 typeswitch( $d ) 
	 case $dt as xs:dateTime  return  fn:format-dateTime( fn:adjust-dateTime-to-timezone($dt),  "[Y0001]-[M01]-[D01] [H01]:[m01]:[s01]") 
	 case $dt as xs:dayTimeDuration  
	 	return  
		
		fn:format-number(fn:sum( (
			if( fn:hours-from-duration($dt) gt 0 ) then 
				fn:hours-from-duration( $dt ) * 60.0 * 60.0 
			else 0.0,
			fn:minutes-from-duration( $dt ) * 60. ,
			fn:seconds-from-duration( $dt ) ) ), "#,##0.00" )

	 default 
	 	return $d 
	 	

};

declare function common:text-to-html( $text as xs:string ) 
{
	for $line in fn:tokenize( $text , "\n" ) 
	return
		( $line , <BR/> )



};


declare function common:script( $body  ) 
{

	 <script type="text/javascript">{ $body }&nbsp;</script> , text { $nl } 

};

declare function common:script-var( $var as xs:string , $value )
{
	common:script(  
	
		fn:concat( "var " , $var , 
			if( fn:exists($value) ) then 
				fn:concat( "=" , $value  ,  ";" )
			else
				() 	

			)
		)
	

};


declare function common:script-string-var( $var as xs:string , $value ) 
{
	
	script-var( $var , 		
	if( fn:exists($value) ) then 
		xqgraph:json-value( $value , 'string')
	else ()
		
	 )		


};




declare function common:string-if-attr( $n ) 
{
	typeswitch( $n )
	case	attribute() return fn:string($n)
	default	return $n 

};



declare function common:html( $body ) 
{
	common:head_html( "", () , $body )
};


declare function common:head_html(  $title , $head , $body ) 
{
(: xdmp:query-trace(fn:true()), :)
xdmp:set-response-content-type("text/html"),
xdmp:set-response-code(200,"OK"),
<html>
<head>
<title>{$title}</title>
{$head}
<style type="text/css">
{"
table {
border-width: 1px;
border-style: solid;
border-color: #000000;
border-collapse: collapse;
}
th, td {
border-width: 1px;
border-style: solid;
border-color: #000000;
padding: 2px;
}

tr.d0 td {
	background-color: #CC9999; color: black;
}
tr.d1 td {
	background-color: #9999CC; color: black;
}

table.noborder , th.noborder , td.noborder{
border-style: none;
border-width: 0px;

}


"
}

</style>

</head>
<body>

{$body}
<BR/>
<HR/>
Execution Time: {
let $tm := xdmp:elapsed-time( )
return 
	fn:concat(fn:minutes-from-duration( $tm ) ,":" , fn:seconds-from-duration($tm) )


}
<HR/>
</body>
</html>


};


declare function common:google-data( $tqx as xs:string , $table as element(table) )
{

xdmp:set-response-code(200,"OK"),
if( fn:string-length( $tqx ) gt 0 ) then  (
	let 	$out   := xqgraph:txq_entry( $tqx , 'out' ),
			$outFileName := xqgraph:txq_entry( $tqx , 'outFileName' )
	return
(
	if( fn:exists( $outFileName) ) then 
		xdmp:add-response-header(
			"Content-Disposition", 
			fn:concat("attachment; filename=""",$outFileName,"""") )
		else (),

	if( $out eq 'html' ) then (
		xdmp:set-response-content-type("text/html"),
		xqgraph:data-table-html(   $table )
	) 
	else 
	if( $out eq 'csv' ) then (
		xdmp:set-response-content-type("text/csv"),
		if( fn:not($outFileName) ) then 
			xdmp:add-response-header(
				"Content-Disposition", 
				fn:concat("attachment; filename=""data.csv""") )
			else (),
		xqgraph:data-table-csv(  $table )
	)
	
	else (
		xdmp:set-response-content-type("text/plain"),
		xqgraph:data-table-json( $tqx , 'ok' ,  $table )
	)
)) 
else (
	xdmp:set-response-content-type("application/xml"),
	$table 
)

};

declare function common:seconds( $d as xs:dayTimeDuration ) as xs:decimal
{

	xs:dayTimeDuration($d) div xs:dayTimeDuration("PT1S")
};

declare function common:join( $as as xs:anyAtomicType* ) as xs:string 
{

	fn:string-join(
		for $a in $as return xs:string($a)

	, "" )


};

(: Stylus Studio meta-information - (c) 2004-2009. Progress Software Corporation. All rights reserved.

<metaInformation>
	<scenarios>
		<scenario default="yes" name="Scenario1" userelativepaths="yes" externalpreview="no" useresolver="yes" url="" outputurl="" processortype="datadirect" tcpport="0" profilemode="0" profiledepth="" profilelength="" urlprofilexml="" commandline=""
		          additionalpath="" additionalclasspath="" postprocessortype="none" postprocesscommandline="" postprocessadditionalpath="" postprocessgeneratedext="" host="" port="0" user="" password="" validateoutput="no" validator="internal"
		          customvalidator="">
			<advancedProperties name="DocumentURIResolver" value=""/>
			<advancedProperties name="CollectionURIResolver" value=""/>
			<advancedProperties name="ModuleURIResolver" value=""/>
		</scenario>
	</scenarios>
	<MapperMetaTag>
		<MapperInfo srcSchemaPathIsRelative="yes" srcSchemaInterpretAsXML="no" destSchemaPath="" destSchemaRoot="" destSchemaPathIsRelative="yes" destSchemaInterpretAsXML="no"/>
		<MapperBlockPosition></MapperBlockPosition>
		<TemplateContext></TemplateContext>
		<MapperFilter side="source"></MapperFilter>
	</MapperMetaTag>
</metaInformation>
:)