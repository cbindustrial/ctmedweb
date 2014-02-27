function lanAtiva() {
	
	var xmlHttp = null;
	xmlHttp = new XMLHttpRequest();
  xmlHttp.onreadystatechange = function() {
    if(this.readyState == 4  && this.status == 200) {
      var data = this.responseText; // ou  responseXML
      if (data != "OK"){ postMessage("X");} else {postMessage("OK");}
    }
   }
	xmlHttp.open( "GET", "http://10.0.0.50:8888/ativo.php", false );
	xmlHttp.send( null );
	setTimeout('lanAtiva()', 5000);
}
lanAtiva();
