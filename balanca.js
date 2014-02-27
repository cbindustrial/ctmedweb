function lerserial() {
	
	var xmlHttp = null;
	xmlHttp = new XMLHttpRequest();
	xmlHttp.open( "GET", "/cgi-bin/balanca.pl", false );
	xmlHttp.send( null );
	
	postMessage(xmlHttp.responseText);
	
	setTimeout('lerserial()', 5000);
}
lerserial();
