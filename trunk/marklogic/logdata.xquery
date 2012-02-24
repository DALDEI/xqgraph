

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
 
 xquery version "1.0-ml";
import module namespace common = "http://calldei.com/modules/xqgraph/marklogic/common" at "common.xquery" ;

declare namespace test="http://www.epocrates.com/schemas/test";
(: Test :)
declare variable $url := xdmp:get-request-field("url");
declare variable $tq := xdmp:get-request-field("tq");
declare variable $tqx := xdmp:get-request-field("tqx");

declare function local:seconds( $d as xs:dayTimeDuration ) as xs:decimal
{
	xs:dayTimeDuration($d) div xs:dayTimeDuration("PT1S")
};


(: Create sample data 
	<data>
		<sample time="timestamp" value

:)

declare variable $start_date := xs:dateTime( '2012-01-01T10:00:00Z' );

declare variable $sample_data := 
<data>
{
	for $i in 1 to 500
	return 
	let	
		$date := $start_date + xs:dayTimeDuration( concat("PT" , $i , "M" )),
		$value := $i mod 10 
	return
		<sample time="{$date}" value="{$value}" />

		
}
</data> ;




let $table :=
<table>
				<cols>
					<col id='A' label='Date' type='datetime' />
					<col id='B' label='Duration' type='number' />


				</cols>
				<rows >
				{
					for $sample in $sample_data/sample
					return
						<row>
								<c v="{ $sample/@time }"/>
								<c v="{ $sample/@value }"/>
						</row>
					
				}
				</rows>
			</table>
return common:google-data( $tqx , $table )
