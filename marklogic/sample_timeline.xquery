xquery version "1.0-ml";
import module namespace common = "http://calldei.com/modules/xqgraph/marklogic/common" at "common.xquery" ;



common:head_html( "Sample Timeline" , 
(

	common:script-var("test_url" , "'logdata.xquery'" ),
    
	common:script( attribute {"src"} { "http://www.google.com/jsapi"} ) ,

	common:script( "google.load('visualization', '1', {packages: ['annotatedtimeline']}); " ) ,
	common:script("

		   function draw() {
      			drawVisualization();
      			drawToolbar();
    		}


        function drawVisualization() {
  			var query = new google.visualization.Query( test_url );
		    query.send(handleQueryResponse);
        }

		 function drawToolbar() {
		      var components = [
		          {type: 'html', 	 datasource:  	test_url },
		          {type: 'csv', 	 datasource:  	test_url }
		      ];
		      var container = document.getElementById('toolbar_div');
		      google.visualization.drawToolbar(container, components);
		};


		function handleQueryResponse(response) {
		  if (response.isError()) {
		    alert('Error in query: ' + response.getMessage() + ' ' + response.getDetailedMessage());
		    return;
		  }

		  var data = response.getDataTable();
		  // Create and draw the visualization.
          var chart = new google.visualization.AnnotatedTimeLine(document.getElementById('visualization'));
          chart.draw(data, {
		  	displayAnnotations: true ,

			displayExactValues : true ,
			displayZoomButtons : false , 
			displayAnnotations: false ,
			displayAnnotationsFilter : false
			}
         );
		}

      google.setOnLoadCallback(draw);
	")
   )
   , 
  (
 	<div id="visualization" style="width: 1000px; height: 600px;">&nbsp;</div>,
	<HR/>,
	<div id="toolbar_div">&nbsp;</div>
  )
)(: Stylus Studio meta-information - (c) 2004-2009. Progress Software Corporation. All rights reserved.

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