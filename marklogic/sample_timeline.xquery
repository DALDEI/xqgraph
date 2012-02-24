

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
)