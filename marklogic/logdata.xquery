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