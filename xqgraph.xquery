(:
 : 
 : Copyright (C) 2011 , 2012 David A. Lee.
 : 
 : The contents of this file are subject to the "Simplified BSD License" (the "License");
 : you may not use this file except in compliance with the License. You may obtain a copy of the
 : License at http: : www.opensource.org/licenses/bsd-license.php 
 : 
 : Software distributed under the License is distributed on an "AS IS" basis,
 : WITHOUT WARRANTY OF ANY KIND, either express or implied.
 : See the License for the specific language governing rights and limitations under the License.
 : 
 : The Original Code is: all this file.
 : 
 : The Initial Developer of the Original Code is David A. Lee
 : 
 : Portions created by (your name) are Copyright (C) (your legal entity). All Rights Reserved.
 : 
 : Contributor(s): none.
 :)

xquery version '1.0-ml';
module namespace xqgraph = "http://calldei.com/modules/xqgraph";


declare option xdmp:mapping "false";
declare variable $xqgraph:lf := "&#10;";



declare function xqgraph:pad-integer-to-length 
  ( $integerToPad as xs:anyAtomicType? ,
    $length as xs:integer )  as xs:string {
	let $si := fn:string($integerToPad)
	return 

    fn:concat(
         (fn:string-join( (for $i in 1 to $length - fn:string-length($si)  return '0' ), '')
          ),
          $si)
 } ;



declare function xqgraph:txq_entry( $tqx as xs:string , $name as xs:string ) as xs:string?
{
	
	for $pairs in fn:tokenize( $tqx , ";" ) 
		let $pair := fn:tokenize( $pairs , ":" ) 
		where $pair[1] eq $name 
		return $pair[2] 
 
};

declare function xqgraph:zero4( $v as xs:integer ) as xs:string
{

 	xqgraph:pad-integer-to-length( $v , 4 )
};

declare function xqgraph:zero2( $v as xs:integer ) as xs:string
{

 	xqgraph:pad-integer-to-length( $v , 2 )
};



(: 
 Parse a table XML file into the JSON format xqgraph expects 
 :)


(: Escape a string to encode literal quotes as \' :)

declare function xqgraph:escape( $value as xs:string ) as xs:string 
{
	fn:replace( $value , "\\'" , "\\\\'" )

};


(: Quote a CSV field by quoting and escaping quotes :)
declare function xqgraph:quote-csv( $value as xs:string ) as xs:string 
{
		fn:concat( '"' ,  fn:replace($value , '"' , '""' ) , '"' )

};


(: Quote a value to represent it as a json string :)
declare function xqgraph:quote( $value as xs:string )  as xs:string 
{
    (: could use  xdmp:to-json( $value ) but want to do single quotes like xqgraph wants :)
	
	fn:concat( "'" , xqgraph:escape( $value ) , "'" )
	
};

declare function xqgraph:format-date( $value as xs:date ) as xs:string 
{
	$value 

};

declare function xqgraph:format-datetime( $value as xs:dateTime ) as xs:string 
{



	fn:concat( 'new Date(' , 	
		fn:string-join( (
			xs:string(xqgraph:zero4(fn:year-from-dateTime( $value ))) ,
			xs:string(xqgraph:zero2(fn:month-from-dateTime( $value ) - 1)) ,
			xs:string(xqgraph:zero2(fn:day-from-dateTime( $value ))) ,
			xs:string(xqgraph:zero2(fn:hours-from-dateTime( $value ))) , 
			xs:string(xqgraph:zero2(fn:minutes-from-dateTime( $value ))) , 
			xs:string(fn:seconds-from-dateTime( $value )) ), "," )  ,
			')' ) 
		
};


declare function xqgraph:format-timeofday( $value as xs:time ) as xs:string 
{
	$value 

};

(: encode a value into a string in the format xqgraph wants JSON :)
declare function xqgraph:json-value( $value , $type as xs:string? )
{
	(: no type output literally without quoting :)
	if( fn:empty($type) or $type eq '' ) then 
		xs:string($value) 
	else

	if( $type eq 'boolean' ) then xqgraph:quote( xs:string($value) ) 
	else
 	if( $type eq 'number'  ) then xs:string( $value ) 
	else
	if( $type eq 'string' ) then xqgraph:quote( $value ) 
	else
	if( $type eq 'date' ) then xqgraph:format-date( xs:date( $value ) )
	else
	if( $type eq 'datetime' ) then xqgraph:format-datetime( xs:dateTime( $value ) )
	else
	if( $type eq 'timeofday' ) then xqgraph:format-timeofday( xs:time( $value ) )
	else
	(: no type output literally without quoting :)
 	if( $type eq 'none' ) then xs:string($value) 
	else 
		xs:string( $value ) 

};

declare function xqgraph:json-value( $value ) 
{
	xqgraph:json-value( $value , () ) 
};


declare function xqgraph:json-member( $name as xs:string , $value , $type as xs:string? ) as xs:string 
{
	fn:concat( 
		$name , ":" , json-value( $value , $type ) )

};
declare function xqgraph:json-member( $name as xs:string , $value ) as xs:string 
{
	xqgraph:json-member( $name , $value , () )
};

declare function xqgraph:json-array( $values as xs:string* ) as xs:string
{
	fn:concat( '[' , 
		fn:string-join( $values , ',' ) ,
	']' )
};

declare function xqgraph:json-object( $members as xs:string* ) as xs:string
{
	fn:concat( '{' , 
		fn:string-join( $members , ',' ) ,
	'}' )
};



declare function xqgraph:json-col( $col as element(col) ) as xs:string
{
	xqgraph:json-object(
	  (
		xqgraph:json-member( 'type' , $col/@type , 'string'  ) ,		
		if( fn:exists($col/@id ) ) then xqgraph:json-member( 'id' , $col/@id , 'string') else () ,
		if( fn:exists($col/@label)) then xqgraph:json-member( 'label' , $col/@label , 'string'  ) else () ,
		if( fn:exists($col/@pattern)) then xqgraph:json-member( 'pattern' , $col/@pattern , 'string' ) else (),
		if( fn:exists($col/@p)) then xqgraph:json-member( 'p' , $col/@p) else ()
     	)
	)


};




(: Format a cols element as JSON :)

declare function xqgraph:json-cols( $cols as element(cols) ) as xs:string 
{
	xqgraph:json-member( 'cols',
		xqgraph:json-array( 
			for $col in $cols/col
			return
				xqgraph:json-col( $col )
		)
	)
};


declare function xqgraph:json-c( $c as element(c) , $type as xs:string  ) as xs:string 
{
	xqgraph:json-object( 
	( 
		if( fn:exists( $c/@v ) ) then  xqgraph:json-member( 'v' , $c/@v , $type ) else (),
		if( fn:exists( $c/@f ) ) then  xqgraph:json-member( 'f' , $c/@f , 'string' ) else (),
		if( fn:exists( $c/@p ) ) then  xqgraph:json-member( 'p' , $c/@p , 'none' ) else ()
	) )



};


declare function xqgraph:json-row( $row as element(row) , $types as xs:string* ) as xs:string
{
  xqgraph:json-object(
	(
	xqgraph:json-member( 'c' ,
		xqgraph:json-array( 
			for $c at $pos in $row/c 
				return xqgraph:json-c( $c , $types[$pos] )
		)
	),
	if( fn:exists( $row/@p ) ) then xqgraph:json-member('p' , $row/@p , 'none' ) else () 
 ))

};

declare function xqgraph:json-rows( $rows as element(rows) , $types as xs:string*  ) as xs:string 
{
	xqgraph:json-member( 'rows' ,
		xqgraph:json-array(
			for $row in $rows/row 
			return xqgraph:json-row( $row , $types )
		)
	)

};

declare function xqgraph:json-table( $table as element(table) ) as xs:string
{
	let $cols := $table/cols,
		$rows := $table/rows,
		$types := $cols/col/@type/fn:string()
	return
	xqgraph:json-member( 'table' ,
		xqgraph:json-object( (
			xqgraph:json-cols( $cols ) ,
			xqgraph:json-rows( $rows , $types ) 
			) )
		)
};



declare function xqgraph:data-table-json( $tqx as xs:string , $status as xs:string , $table as element(table)? ) as xs:string
{
	let $responseHandler := xqgraph:txq_entry( $tqx , 'responeHandler' ),
		$reqId := xqgraph:txq_entry( $tqx , 'reqId' )
	return
 	 
		fn:concat(
		if( $responseHandler ) then $responseHandler else 'google.visualization.Query.setResponse' ,
		'(',
			xqgraph:json-object( (
				if( fn:exists($reqId) ) then xqgraph:json-member( 'reqId' , $reqId , 'string' ) else () ,
				xqgraph:json-member( 'status' , $status , 'string' ),
				if( $status eq 'ok' and fn:exists( $table) ) then
					xqgraph:json-table( $table ) else ()
				)
			),
		')'
	)
	
		
};





declare function xqgraph:data-table-html(  $table as element(table)? ) 
{
	<html><body>
		<table>
		<tr>
		{
			for $col in $table/cols/col 
			return	<TH>{fn:string($col/@label)}</TH>
		}
		</tr>
		{
			for $row in $table/rows/row
			return	
			<tr>
			{
				for $col in $row/c
				return
					<TD>{fn:string($col/@v)}</TD>
			}
			</tr>

		}
		</table>
		</body>
		</html>
};





declare function xqgraph:csv-format-datetime( $value as xs:dateTime ) as xs:string 
{
	let $sec := fn:seconds-from-dateTime( $value ) 
	return 
	

	fn:concat( 
			xs:string(xqgraph:zero4(fn:year-from-dateTime( $value ))) , "-" , 
			xs:string(xqgraph:zero2(fn:month-from-dateTime( $value ) - 1)) , "-",
			xs:string(xqgraph:zero2(fn:day-from-dateTime( $value ))) , " ",
			xs:string(xqgraph:zero2(fn:hours-from-dateTime( $value ))) , ":",
			xs:string(xqgraph:zero2(fn:minutes-from-dateTime( $value ))) ,  ":",
			xs:string(xqgraph:zero2(fn:floor($sec))) , "." , 
			xs:string( $sec - fn:floor($sec ) )
			
			
			) 
		
};



declare function xqgraph:csv-format-date( $value as xs:date) as xs:string 
{

	fn:concat( 
			xs:string(xqgraph:zero4(fn:year-from-date( $value ))) , "-" , 
			xs:string(xqgraph:zero2(fn:month-from-date( $value ) - 1)) , "-",
			xs:string(xqgraph:zero2(fn:day-from-date( $value ))) )
};


declare function xqgraph:csv-format-timeofday( $value as xs:time ) as xs:string 
{

	let $sec := fn:seconds-from-time( $value ) 
	return 

	fn:concat( 
			xs:string(xqgraph:zero2(fn:hours-from-time( $value ))) , ":",
			xs:string(xqgraph:zero2(fn:minutes-from-time( $value ))) ,  ":",
			xs:string(xqgraph:zero2(fn:floor($sec))) , "." , 
			xs:string( $sec - fn:floor($sec ) ) )
		
};



(: encode a value into a string intended for CSV. :)
declare function xqgraph:csv-value( $value , $type as xs:string? )
{
	(: no type output literally without quoting :)
	if( fn:empty($type) or $type eq '' ) then 
		xs:string($value) 
	else

	if( $type eq 'boolean' ) then xs:string($value)  
	else
 	if( $type eq 'number'  ) then xs:string( $value ) 
	else
	if( $type eq 'string' ) then xqgraph:quote-csv( $value ) 
	else
	if( $type eq 'date' ) then xqgraph:csv-format-date( xs:date( $value ) )
	else
	if( $type eq 'datetime' ) then xqgraph:csv-format-datetime( xs:dateTime( $value ) )
	else
	if( $type eq 'timeofday' ) then xqgraph:csv-format-timeofday( xs:time( $value ) )
	else
	(: no type output literally without quoting :)
 	if( $type eq 'none' ) then xs:string($value) 
	else 
		xs:string( $value ) 

};




declare function xqgraph:data-table-csv(  $table as element(table)? ) as xs:string
{
	let $cols := $table/cols,
		$rows := $table/rows,
		$types := $cols/col/@type/fn:string()
	return
	fn:string-join(
	(
		fn:string-join(
			for $col in $cols/col 
			return
				xqgraph:quote-csv( $col/@label ) ,
				"," ) ,
	
		for $row in $rows/row
		return	
			fn:string-join(
				for $col at $pos in $row/c
				return
					xqgraph:csv-value( $col/@v ,$types[$pos] ) ,
				"," )
	)
	, 
	$xqgraph:lf )

};


declare function xqgraph:parse-query( $query as xs:string? , $default as xs:string* ) as xs:string* 
{
	if( fn:empty($query) or $query eq '' ) then $default else

	let $vals := fn:tokenize( $query , "[ ,]" )
	return $vals[ fn:position() > 1 ]


};
