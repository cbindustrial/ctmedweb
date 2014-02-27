onmessage = function(e) {
	var registro = e.data;
	var xmlHttp = null;
	xmlHttp = new XMLHttpRequest();
	xmlHttp.open( "GET", "/cgi-bin/impressora.pl?x="+registro, false );
	xmlHttp.send( null );
	postMessage(xmlHttp.responseText);
};