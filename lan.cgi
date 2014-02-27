#!/bin/bash

echo "content-type: text/html"
echo ""
echo ""
echo "
 <html><head><title>Monitoramento da LAN</title>"
 # Descomente se quiser auto refresh
 # echo "<meta http-equiq='refresh' content='10;url=localhost:7777/cgi-bin/lan.cgi'>"
 echo "</head>"
 echo "<body bgcolor='white'>
 <div align='right'>Usuário: <b>$SERVER_NAME</b></div>
 <center><h2>Máquinas da LAN</h2>
 <form method='post' action='lan_info.cgi'>
 <table widthborder=0 cellpadding=2>"
	# arquivo contendo o nome dos host a monitorar
	FILE_host="host"
	maxcol=4
	numcol=1
  for host in $(cat "$FILE_host" | sort -g -tl -k2);do
    [ $numcol = 1 ] && echo "<tr>"
    # depedendo da versao do ping existe a opcao -w, que especifica quantos
    # segundo o ping deve esperar por resposta. coloque -w1 para agilizar o
    # tempo de resposta
    ping -w1 "$host" > /dev/null 2>&1

    if [ $? -eq 0 ];then
      echo "<td align='center'><img src='online.png' alt='$host OK' border=0></a></td>"
      echo "<td><input type=radio name=host value='$host'><br>$host</td>"
    elif [ $? -eq 1 ] ;then
      echo "<td align='center'><img src='offline.png' alt='Sem reposta da $host' border=0></a></td>"
          echo "<td><br>$host</td>"
    elif [ $? -eq 2 ] ;then 
      echo "<td align='center'><img src='offline.png' alt='$host nao existe' border=0></a></td>"
          echo "<td><br>$host</td>"
    fi

    [ $numcol = 4 ] && { echo "</tr>"; numcol=1; } || numcol=$(($numcol+1))
  done
echo "
</table><br>
<input type=submit name='botao' value='info'> 
<input type=submit name='botao' value='processos'>
</form>
</center>
</body></html>"