function init() {
	var ok=0; var datai="";
	while (ok==0) {
		datai=prompt('Data Inicial: ','DD/MM/AAAA');
		if (datai.length!=10){alert('Tamanho da data inválido!'); continue;}
		if (datai.substring(2,3)!="/" || datai.substring(5,6)!="/"){alert('Formato de data inválido!'); continue;}
		if (isNaN(datai.substring(0,2)) || parseFloat(datai.substring(0,2))<0 || parseFloat(datai.substring(0,2))>31){alert('Dia da data inválido!'); continue;}
		if (isNaN(datai.substring(3,5)) || parseFloat(datai.substring(3,5))<0 || parseFloat(datai.substring(3,5))>12){alert('Mes da data inválido!'); continue;}
		if (isNaN(datai.substring(6)) || parseFloat(datai.substring(6))<2010 || parseFloat(datai.substring(0,2))>2013){alert('Ano da data inválido!'); continue;}
		ok=1;
	}
	datai = "'"+datai.substring(6)+"-"+datai.substring(3,5)+"-"+datai.substring(0,2)+"'";
	ok=0; var dataf="";
	while (ok==0) {
		dataf=prompt('Data Final: ','DD/MM/AAAA');
		if (dataf.length!=10){alert('Tamanho da data inválido!'); continue;}
		if (dataf.substring(2,3)!="/" || dataf.substring(5,6)!="/"){alert('Formato de data inválido!'); continue;}
		if ((isNaN(dataf.substring(0,2))) || (parseFloat(dataf.substring(0,2))<0) || (parseFloat(dataf.substring(0,2))>31) ){alert('Dia da data inválido!'); continue;}
		if ((isNaN(dataf.substring(3,5))) || (parseFloat(dataf.substring(3,5))<0) || (parseFloat(dataf.substring(3,5))>12) ){alert('Mes da data inválido!'); continue;}
		if ((isNaN(dataf.substring(6))) || (parseFloat(dataf.substring(6))<2010) || (parseFloat(dataf.substring(0,2))>2013) ){alert('Ano da data inválido!'); continue;}
		ok=1;
	}
	dataf = "'"+dataf.substring(6)+"-"+dataf.substring(3,5)+"-"+dataf.substring(0,2)+"'";
	
	var sql = "select data,hora,op,item,qtd,usuario from entprodest where data>="+datai+" and data<="+dataf+" order by data desc, hora desc";
	//alert (sql);
	var ajax = null;
	ajax=new XMLHttpRequest();
	ajax.onreadystatechange=function() {
		if((this.readyState==4)&&(this.status==200)) {
			var data = this.responseText; // ou  responseXML
			if (data=="X") { 
				alert('X erro no acesso!');
				close();
			}
			var cel = data.split("&");
			var miolo = "";
			cel.forEach( function(linha) { 
				var i=0;
				miolo = miolo + "<tr>";
				var reg = linha.split("|");	
				reg.forEach( function(cpos) {
					if (i==4){
						miolo = miolo + "<td align='right'>" + cpos + "</td>";
					}	else {
						if (i==3 || i==5){
							miolo = miolo + "<td align='left'>" + cpos + "</td>";
						} else {
							miolo = miolo + "<td align='center'>" + cpos + "</td>";
						}
					}
					i++;
				});
				miolo=miolo+"</tr>";
			});
			document.getElementById("tbody").innerHTML=miolo;
		}
	};
	var url = "http://10.0.0.50:8888/connections/my_tquery.php?sql="+sql;
	ajax.open("GET", url, false);//true async false sync
	ajax.send();
}
