  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, Qrctrls, QuickRpt, ExtCtrls, Db, ZAbstractRODataset,
  ZAbstractDataset, ZDataset, ADODB, IdTCPConnection, IdTCPClient,
  IdExplicitTLSClientServerBase, IdMessageClient, IdSMTPBase, IdSMTP,
  IdComponent, IdRawBase, IdRawClient, IdIcmpClient, IdBaseComponent, IdMessage,
  ZConnection, IniFiles, OleCtrls, SHDocVw, IdHTTP,jpeg, DBClient,PRINTERS,
  QRWebFilt, QRExport, dbxjson,httpapp, iduri, CPort, CPortCtl;

var
  Fm_Principal : TFm_Principal;
  lista1 : TStringList;
  difmaior,scrap, qtdpc, qtdimp,iIdReg,quantidade_faturada,iTipoOp:integer;
  WS:string='http://10.0.0.50:8888/cdcf/';
  sql,url: string;
  rPeso : Real;
  cItem,cItemTab,cTipoProd,cLocal:string;
  cUsuario,cHostName:string;
  dtini,dtfim:string;
  sChaveAcesso:WideString;
  IniFile : TIniFile;
  FIniFileName : ShortString;
  posicao:string;
  v_total_estoque, preco_de_custo:real;
  jo : TJSONObject;
  jp: TJSONPair;
  SS: TStringStream;
  Response: AnsiString;
  ZC : TZConnection;
  ZQ : TZQuery;
  function DataValida(StrD: string): Boolean;
  
uses UnitV2produto;

function Mydata(mcad: string):string ;
var
  data:tdatetime;
begin
  result := '';
  if trystrtodate(mcad,data) then
    result:= formatdatetime('yyyy-mm-dd', data)
      else showmessage('Atenção! a data é inválida!');
end;

function TFm_Principal.id_usuario(id:integer):Boolean;
begin
	//IDENTIFICAR O USUARIO QUE VAI REGISTRAR A ENTRADA...
  result := false;
  cUsuario:='';
  repeat
    if not InputQuery('IDENTIFIQUE-SE!', 'Digite seu código ou passe o crachá pelo leitor de barras.', cUsuario) then
    begin
      cUsuario:='0';
      break;
    end;
  until cUsuario <> '';

  if strtointdef(cUsuario,0)=0 then begin
    SB.Panels[0].text:= 'Código inválido, o programa será encerrado!';
    showmessage('Código inválido!!!');
    exit;
  end;

  if length(cUsuario)=4 then begin
    if ((strtointdef(cUsuario,0)>0) and (strtointdef(cUsuario,0)<9999)) then begin
      sql := 'select nomecracha from cracha where nrocracha='+cUsuario;
      url := TidURI.URLEncode(Ws+'my_squery.php?sql='+sql);
      try
        IdHTTP.ConnectTimeout := 1000;
        IdHTTP.Get(url , SS);
      finally
        cUsuario := UTF8Encode(SS.DataString);
        SS.Clear;
      end;
      if cUsuario = '' then begin
        SB.Panels[0].text:= 'Código inválido, o programa será encerrado!';
        exit;
      end;
    end
      else
    begin
      SB.Panels[0].text:= 'Código inválido, o programa será encerrado!';
      showmessage('Código inválido!!!');
      exit;
    end;
  end;
  result := true;
end;

procedure limpa_tela();
begin
	cItem:= ''; cItemTab:='';
  Fm_Principal.Edit_OP.Clear;
  Fm_Principal.lbItem.Caption:='';
  Fm_Principal.lbDescricao.Caption:='';
  Fm_Principal.lbAcabadas.Caption:='';
  Fm_Principal.lbEstoque.Caption:='';
  Fm_Principal.lbItem.Caption:='';
  Fm_Principal.lbLote.Caption:='';
  Fm_Principal.lbScrap.Caption:='';
  Fm_Principal.lbVendidas.Caption:='';
  Fm_Principal.lbCadastro.Caption:='';
  Fm_Principal.Img1.hide;
  
end;

Function DataValida(StrD: string): Boolean;
var
  D : TDateTime;
begin
  Result := True;
  try
    D := StrToDate(StrD);
  except
    on EConvertError do Result:=False;
  end;
end;

///////////// EVENTOS DO FORM
procedure TFm_Principal.FormCreate(Sender: TObject);
var
  posicao,cPorta:string;
begin
  Lista1 := Tstringlist.Create;
  cUsuario:='';
  SS := TStringStream.Create('', TEncoding.UTF8);
  Height:=640;
  Width:=1024;
  if screen.Height > 640 then top:=round((Screen.Height-640)/2) else top:=0;
	if Screen.width > 1024 then left:= round((Screen.width-1024)/2) else left:=0;
  ZC := TZConnection.Create(ZC);
  ZC.User := 'Exped';
  ZC.HostName := '10.0.0.50';
  ZC.protocol := 'mysql-5';
  ZC.Password := 'ss';
  ZC.Port := 3306;
  ZC.Database := 'cb';
  ZQ := TZquery.Create(ZQ);
  ZQ.Connection := ZC;
end;

procedure TFm_Principal.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (key = 27) then close;
  if key = vK_F2 then
  begin
    Application.CreateForm(TForm_V2Produtos, form_V2produtos);{Carrega form na memória}
    Form_V2produtos.ShowModal;{Mostra form em modo exclusivo}
    if Form_V2produtos.ModalResult = mrOk then
    begin
      Edit_Op.text:= Form_V2produtos.ZQ1.FieldbyName('codprod').AsString;
      Edit_Op.SetFocus;
    end;
    Form_V2produtos.Free;{Qdo retorna, libera memória}
  end;
end;

/////EVENTOS DOS EDITS

procedure TFm_Principal.Edit_OPExit(Sender: TObject);
var
  i : integer; requer,med:boolean;
  mensagem,ultima_operacao, dt:string;
begin
 requer := true;
  med := True; // inicializa com true;
  if (Edit_OP.Text = '') or (Edit_OP.Text = '000000') then begin
    SB.Panels[0].text := cUsuario + ' é preciso digitar o código da ordem de produção para iniciar !';
    limpa_tela;
    exit;
  end;
  (*especificar quais campos dever ser lidos e atribuir a variaveis*)
  //mensagem:= IdHTTP.Get(Ws+'pesquisa_op.php?cod='+Edit_OP.Text);

  //mensagem:= Idhttp.Get(Ws+'pesquisa_op2.php?cod='+Edit_OP.Text);
       sql := 'select codigo_interno, v_total_estoque, preco_de_custo, quantidade_faturada, item, descricao, lote, estoque, '+
       'acabadas, scrap, tipoop, local, cadastro from produtos where codprod='+quotedstr(edit_op.text);
      url := TidURI.URLEncode(Ws+'my_query.php?sql='+sql);
      try
        IdHTTP.ConnectTimeout := 100;
        IdHTTP.Get(url,SS);
      finally
        response := UTF8Encode(SS.DataString);
        SS.Clear;
      end;
      if response='X' then begin showmessage('Ocorreu um erro ao pesquisar a OP!'); cUsuario:=''; exit; end;
  if response = '' then
  begin
    SB.Panels[0].text:= cUsuario + ' ' + 'Atenção!! OP NÃO encontrada, redigite-a!!';
    lbDescricao.Caption := '   A T E N Ç Ã O... OP INVÁLIDA!!!   ';
    limpa_tela;
    exit;
  end;

  SB.Panels[0].text:= cUsuario + ' ' +  'OP ENCONTRADA!!';
  response:= stringreplace(response,'[','',[]);
  response:= stringreplace(response,']','',[]);
  jo := TJSONObject.Create;
  jo := TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes(response), 0) as TJSONObject;
  response:='';
  v_total_estoque := strtofloat( StringReplace( jo.Get(1).JsonValue.Value, '.', ',',[rfReplaceAll, rfIgnoreCase]));
  preco_de_custo := strtofloat( StringReplace( jo.Get(2).JsonValue.Value,'.',',',[rfReplaceAll, rfIgnoreCase]));
  quantidade_faturada :=  strtoint(jo.Get(3).JsonValue.Value);
  cItemTab :=  jo.Get(4).JsonValue.Value;
  cItem := '';
  for i:=1 to length(cItemTab) do
    if (copy(cItemTab,i,1) <> '.') and
       (copy(cItemTab,i,1) <> '-') and
       (copy(cItemTab,i,1) <> '/') then
          cItem := cItem + copy(cItemTab,i,1);
	{item sem pontos é usado para achar a foto E CTMED_ITM}

  carrega_foto('http://10.0.0.50:8888/ctmed/fotos/FotosInt_Acabamento/'+cItem+'.jpg');
  lbItem.caption := cItemTab;
  if lbItem.caption = '2RD805333' then
  Edit_QTD.readonly:=false else Edit_QTD.readOnly:=true;
  lbDescricao.Caption := jo.Get(5).JsonValue.Value;
  lbLote.Caption := jo.Get(6).JsonValue.Value;
  lbEstoque.Caption := jo.Get(7).JsonValue.Value;
  lbAcabadas.Caption := jo.Get(8).JsonValue.Value;
  lbScrap.Caption := jo.Get(9).JsonValue.Value;
  lbVendidas.Caption := inttostr(quantidade_faturada);
  iTipoOp := strtoint(jo.Get(10).JsonValue.Value);
  iIdReg := strtoint(jo.Get(0).JsonValue.Value);
  cLocal:= jo.Get(11).JsonValue.Value;
  Edit_Local.text := jo.Get(11).JsonValue.Value;
  mensagem := '';
  dt:= jo.Get(12).JsonValue.Value;
  dt:= copy(dt,9,2)+'/'+copy(dt,6,2)+'/'+copy(dt,1,4);
  lbCadastro.Caption:= dt;

  {se é produção eventual(1) ou protótipo(2): sai... se não eventual ou pré lançamento analisa regs qualidade}
  if ( iTipoOp = 0 ) or ( iTipoOp  = 2 )  then begin
    requer:=false;
    Edit_scrap.setfocus;
    Exit;
  end;
    //***>>> VERIFICAÇÃO PEPS
    // se encontrou op... verifica pelo codigo do item quais ops existem pelo f2.
    // se encontrou so um item com op aberta libera... se mais... trata as informações.
    Application.CreateForm(TForm_V2Produtos, form_V2produtos);{Carrega form na memória}
    try
      Form_V2produtos.Show;{Mostra form em modo exclusivo}

      Form_V2produtos.ZQ1.Close;
      Form_V2produtos.ZQ1.Sql.text:=  ' Select CODPROD, item, codigo, ano, descricao, estoque, local, scrap, preco_de_custo, acabadas, Quantidade_Faturada, cadastro, grupo, item '+
                          ' from produtos '+
                          ' where item = '+QuotedStr(cItemTab)+ ' and estoque > 0 '+
                          ' Group by CODPROD, item, codigo, ano, descricao, estoque, local, preco_de_custo, acabadas, Quantidade_Faturada, scrap, cadastro, grupo '+
                          ' Order by ano desc,codigo desc';
      Form_V2produtos.ZQ1.Open;
      //**>>>  se recordcount = 1 continua sem tratar
      Form_V2produtos.ZQ1.First;
      if Form_V2produtos.ZQ1.recordcount > 1 then
      begin
        Form_V2produtos.ZQ1.Last;
        if (Form_V2produtos.ZQ1estoque.AsFloat - Form_V2produtos.ZQ1acabadas.asfloat) > 0 then
        begin
          showmessage('Atenção, existem OPs não concluídas!! Verifique junto a produção!');
          exit;
        end;
        while (Form_V2produtos.ZQ1.RecNo > 1) do
        begin
          Form_V2produtos.ZQ1.prior;
          if (Form_V2produtos.ZQ1estoque.AsFloat - Form_V2produtos.ZQ1acabadas.asfloat) > 0 then
          begin
            showmessage('Atenção, existem OPs não concluídas!! Verifique junto a produção!');
            break;
            exit;
          end;
        end;
      end;
    finally
      Form_V2produtos.Free;{Qdo retorna, libera memória}
    end;
    //***>>> FIM VERIFICAÇÃO PEPS

end;

procedure TFm_Principal.Edit_QTDKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if key = 13 then fechar.setfocus;
end;

procedure TFm_Principal.Edit_QTDKeyPress(Sender: TObject; var Key: Char);
begin
  If not(key in['0'..'9',#8]) then
		key:= #0;
end;

procedure TFm_Principal.Edit_QTDEnter(Sender: TObject);
begin
  SB.Panels[0].text:= cUsuario + ' ' + 'Digite a quantidade para armazenamento!';
end;

procedure TFm_Principal.Edit_QTDExit(Sender: TObject);
begin
  SB.Panels[0].text:= cUsuario + ' ' +  ' Aguarde... !!';

end;

procedure TFm_Principal.Edit_PesoKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if key = 13 then  edit_scrap.setfocus;
end;


procedure TFm_Principal.btQtdClick(Sender: TObject);
var
  acabadas, Uop, Ano, pergunta, cont1, cont2, i, opc, excedeu : integer;
  mensagem, item, codprod, locpad, ultima_operac,uo,dataprot:string;
begin
  //Edit_QTD.Text := '10';
  if Edit_OP.text='' then begin
    SB.Panels[0].text:= 'Digite o código da OP para inciar!';
    exit;
  end;

  if cUsuario='' then
    if not id_usuario(0) then begin
      SB.Panels[0].text:= 'Identifique-se para poder registrar!';
      exit;
    end;
  SB.Panels[0].text:= cUsuario + ' Aguarde! Registrando informação!';
  Application.ProcessMessages;
  cont1 := 0; cont2 := 0; opc := 0; locpad := '';
  if MessageDlg('Confirma entrada de '+Edit_qtd.text+' pçs. acabadas!' ,
    mtconfirmation, [mbYes,mbNo], 0, mbNo)= mrNo then begin
    limpa_tela;
    exit;
  end;

  // VALIDACAO CONTROLE MEDIDAS... SE FORAM TODAS INSPECIONADAS
  sql:= 'select operac from ctmed_itm where item='+QuotedStr(cItem)+' group by operac desc limit 1';
  //showmessage(sql);
  url:= TidURI.URLEncode(Ws+'my_squery.php?sql='+sql);
  try
    IdHTTP.ConnectTimeout := 500;
    IdHTTP.Get(url,SS);
  finally
    response := UTF8Encode(SS.DataString);
    SS.Clear;
  end;
  if response='X' then begin
    showmessage('Erro ao consultar a tabela ctmed_itm!'); cUsuario:=''; limpa_tela;
    exit;
  end;
  //showmessage(response);
  if strtointdef(response,0) > 0 then ultima_operac:= response else begin
    showmessage('Erro ao consultar a ultima operacao na tabela ctmed_itm!'); cUsuario:=''; limpa_tela;
    exit;
  end;

  // VALIDAR ULTIMA OPERACAO TEM CONTROLE MEDIDAS REGISTRADO.
  response:='';
  sql := 'select count(*) from ctmed_reg where codprod = '+quotedstr(edit_op.Text)+
         ' and operac = '+quotedstr(ultima_operac)+' and etapa = '+quotedstr('F')+' limit 1';
  url := TidURI.URLEncode(Ws+'my_squery.php?sql='+sql);
  try
    IdHTTP.ConnectTimeout := 500;
    IdHTTP.Get(url , SS);
  finally
    response := UTF8Encode(SS.DataString);
    SS.Clear;
  end;
  if response='X' then begin showmessage('Erro ao consultar a finalização na tabela ctmed_reg!'); cUsuario:=''; limpa_tela; exit; end;
  if strtointdef(response,0)=0 then begin
    showmessage('Nao encontrei registro de Finalização na ULTIMA OPERAÇÃO [ '+ultima_operac+' ], verifique!'); cUsuario:=''; limpa_tela; exit;
  end;
  Application.ProcessMessages;
  acabadas := ( strtoint(lbAcabadas.Caption) + strtoint(edit_qtd.text) );
  scrap := strtoint( lbscrap.caption );
  // VALIDAÇÃO QUANTIDADE DE ENTRADA ESTOQUE.
  if ((acabadas + scrap) > (strtoint(lbLote.Caption) * 1.1)) then begin
    Showmessage(' QUANTIDADE INVÁLIDA!!!'+#13+'A quantidade total é superior a 10% do lote da O.P.'+#13+
                ' Procure o PCP para adequar as quantidades e gerar a entrada!!');
    limpa_tela;
    exit;
  end;
//*************
  if ((acabadas + scrap) > (strtoint(lbLote.Caption))) then begin
    excedeu := (acabadas + scrap) - strtoint(lbLote.Caption);
    sql := 'update produtos set estoque='+QuotedStr(inttostr(excedeu))+
           ' where codigo_interno='+inttostr(iIdReg);
    url := TidURI.URLEncode(Ws+'my_exec.php?sql='+sql);
    try
      IdHTTP.ConnectTimeout := 500;
      IdHTTP.Get(url , SS);
    finally
      response := UTF8Encode(SS.DataString);
      SS.Clear;
    end;
    if response='X' then begin showmessage('Erro ao gravar quantidade na tabela produtos!'); cUsuario:=''; limpa_tela; exit; end;
  end;
  response:='';
  Application.ProcessMessages;
  sql := 'update produtos set acabadas='+QuotedStr(inttostr(acabadas ))+
				 ' where codigo_interno='+inttostr(iIdReg);
  url := TidURI.URLEncode(Ws+'my_exec.php?sql='+sql);
  try
    IdHTTP.ConnectTimeout := 500;
    IdHTTP.Get(url , SS);
  finally
    response := UTF8Encode(SS.DataString);
    SS.Clear;
  end;
  if response='X' then begin showmessage('Erro ao gravar quantidade na tabela produtos!'); cUsuario:=''; limpa_tela; exit; end;
//**************
Application.ProcessMessages;
  sql :='insert into entprodest set data='+quotedstr(mydata(datetostr(Date)))+
                ', hora='+quotedstr(timetostr(Time))+
                ', op='+quotedstr(Edit_OP.text)+
                ', qtd='+quotedstr(edit_qtd.text)+
                ', usuario='+quotedstr(cUsuario)+
                ', item='+quotedstr(cItemTab)+
                ', unit='+quotedstr(trim(copy(lbPeso.caption,1,length(lbPeso.caption)-2)))+
                ', liq='+quotedstr(trim(copy(lbPliquido.caption,2,length(lbpliquido.caption)-3)))+
                ', emb='+quotedstr(trim(copy(lbembala.caption,2,length(lbembala.caption)-3)))+
                ', tot='+quotedstr(trim(copy(lbBruto.caption,2,length(lbBruto.Caption)-3)));
  url := TidURI.URLEncode(Ws+'my_exec.php?sql='+sql);

  response := IdHTTP.Get(url);

  if response='X' then begin showmessage('Erro ao gravar registro na tabela entprodest!');  end;
//**************
Application.ProcessMessages;
  sql := ' insert into log_sis (data,hora,Usuario,Atividade) values('+
               QuotedStr(Mydata(DatetoStr(date())))+','+QuotedStr(TimeToStr(Time))+','+
               QuotedStr(cUsuario)+','+QuotedStr('Armazenou '+ edit_qtd.text +' pçs da Op-'+ Edit_OP.Text)+')';
  url := TidURI.URLEncode(Ws+'my_exec.php?sql='+sql);
  try
    IdHTTP.ConnectTimeout := 500;
    IdHTTP.Get(url , SS);
  finally
    response := UTF8Encode(SS.DataString);
    SS.Clear;
  end;
  if response='X' then begin showmessage('Erro ao gravar registro na tabela log_sis!');  end;
//***********
  Application.ProcessMessages;
//  sql:= ' INSERT INTO ZA2010 '+
//  '(R_E_C_N_O_, ZA2_OPCB, ZA2_DATREG, ZA2_HORREG, ZA2_QTDPRO, ZA2_SCRAP) '+
//  ' SELECT COUNT(*), '+quotedstr(Edit_OP.text)+', '+
//  QuotedStr(MyDataProt(datetostr(date())))+', '+
//  QuotedStr(timetostr(now()))+', '+
//  QuotedStr(edit_qtd.text)+', '+
//  quotedstr('0')+' FROM ZA2010';
//  //showmessage(sql);
//  url:= TidURI.URLEncode(Ws+'ms_exec.php?sql='+sql);
  url:= TidURI.URLEncode('http://10.0.0.50:8888/cbindw/Ent_QtdEst.php?op='+ Edit_OP.text +
                          '&pc='+ edit_qtd.text +'&scp='+ Edit_Scrap.Text );
  try
    IdHTTP.ConnectTimeout:= 500;
    IdHTTP.Get(url, SS);
  finally
    response:= UTF8Encode(SS.DataString);
    SS.Clear;
  end;
  if response='X' then begin showmessage('Erro ao gravar registro na tabela ZA2010!');  end;
//************************
  SB.Panels[0].text:= cUsuario + ' OP atualizada nas bases!! clique em FECHAR para sair!';
  cUsuario:='';
end;

procedure TFm_Principal.btScrapClick(Sender: TObject);
var
  iScrap, iScrap_atual:integer;
  scrap_ant:string;
begin
  if Edit_OP.text='' then begin
    SB.Panels[0].text:= 'Digite o código da OP para inciar!';
    exit;
  end;
  if cUsuario='' then
    if not id_usuario(0) then begin
      SB.Panels[0].text:= 'Identifique-se para poder registrar!';
      exit;
    end;
  SB.Panels[0].text:= cUsuario + ' ' + ' Aguarde! Registrando informação!';
  // SOMAR AO SCRAP AS PEÇAS LANCADAS... SE NEGATIVA REDUZIR O SCRAP;
  iScrap:= strtointdef(edit_scrap.Text,0);
  if iScrap=0 then begin
    SB.Panels[0].text:= cUsuario + ' Digite uma quantidade válida para o scrap!';
    exit;
  end;
  scrap_ant:= lbScrap.Caption;
  iScrap_atual := strtointdef(lbScrap.Caption,0);
  iScrap_atual := iScrap_atual + iScrap;
  if iScrap_atual < 0 then iScrap_atual:=0;
  lbScrap.Caption:= inttostr(iScrap_atual);
  if messagedlg('Confirma o ajuste na quantidade de SCRAP para '+lbScrap.Caption+' peças?',mtConfirmation,[mbYes,mbNo],0,mbNo )=mrNo then exit;
  sql := 'update produtos set scrap = '+QuotedStr(lbScrap.Caption)+' where codprod=' + QuotedStr(Edit_op.text);
  url := TidURI.URLEncode(Ws+'my_exec.php?sql='+sql);
  try
    IdHTTP.ConnectTimeout := 500;
    IdHTTP.Get(url , SS);
  finally
    response := UTF8Encode(SS.DataString);
    SS.Clear;
  end;
  if response='X' then begin showmessage('Ocorreu um erro ao tentar gravar o SCRAP!'); cUsuario:=''; exit; end;
  SB.Panels[0].text:= cUsuario + ' Scrap! Registrado!';
  sql := ' insert into log_sis (data,hora,Usuario,Atividade) values('+
               QuotedStr(Mydata(DatetoStr(date())))+','+QuotedStr(TimeToStr(Time))+','+
               QuotedStr(cUsuario)+','+QuotedStr('ALTEROU SCRAP op:'+edit_op.text+' de: '+ scrap_ant +' pçs para: '+lbScrap.Caption+' pçs.')+')';
  url := TidURI.URLEncode(Ws+'my_exec.php?sql='+sql);
  try
    IdHTTP.ConnectTimeout := 500;
    IdHTTP.Get(url , SS);
  finally
    response := UTF8Encode(SS.DataString);
    SS.Clear;
  end;
  if response='X' then begin showmessage('Ocorreu um erro ao tentar gravar o log do sistema!'); end;
  cUsuario:='';
//  sql:= ' INSERT INTO ZA2010 '+
//  '(R_E_C_N_O_, ZA2_OPCB, ZA2_DATREG, ZA2_HORREG, ZA2_QTDPRO, ZA2_SCRAP) '+
//  ' SELECT COUNT(*), '+quotedstr(Edit_OP.text)+', '+
//  QuotedStr(MyDataProt(datetostr(date())))+', '+
//  QuotedStr(timetostr(now()))+', '+
//  QuotedStr('0')+', '+
//  quotedstr(Edit_Scrap.text)+' FROM ZA2010';
//  //showmessage(sql);
//  url:= TidURI.URLEncode(Ws+'ms_exec.php?sql='+sql);
  url:= TidURI.URLEncode('http://10.0.0.50:8888/cbindw/Ent_QtdEst.php?op='+ Edit_OP.text +
                          '&pc='+ edit_qtd.text +'&scp='+ Edit_Scrap.Text );
  try
    IdHTTP.ConnectTimeout:= 500;
    IdHTTP.Get(url, SS);
  finally
    response:= UTF8Encode(SS.DataString);
    SS.Clear;
  end;
  if response='X' then begin showmessage('Erro ao gravar registro na tabela ZA2010!');  end;

end;


////////////BOTOES

procedure TFm_Principal.BtnOrdenProdClick(Sender: TObject);
//var op : integer;
begin
  (*
  if autorizado('OrdensdeProduo1') then
  begin
    //Application.CreateForm(TDB_PCP, DB_PCP);
    Application.CreateForm(TForm_OrdemProducao, Form_OrdemProducao);{Carrega form na memória}
    try
      Form_OrdemProducao.ShowModal;{Mostra form em modo exclusivo}
    finally
      if Form_OrdemProducao.ModalResult = mrOk then
      begin
        op := Form_OrdemProducao.SG1.Row;
        Edit_OP.Text := Form_OrdemProducao.SG1.Cells[3,op];
        Edit_OP.SetFocus;
      end;
      Form_OrdemProducao.Free; {Libera Memória}
      //DB_PCP.destroy;
    end;
  end else showmessage('Sua Chave de Acesso não permite esta operação!');
  *)
end;

procedure TFm_Principal.btGravaLocalClick(Sender: TObject);
begin
  if Edit_OP.text='' then begin
    SB.Panels[0].text:= 'Digite o código da OP para inciar!';
    exit;
  end;
  if cUsuario='' then
    if not id_usuario(0) then begin
      SB.Panels[0].text:= 'Identifique-se para poder registrar!';
      exit;
    end;
  SB.Panels[0].text:= cUsuario + ' ' + ' Aguarde! Registrando informação!';

      sql := 'update produtos set local = '+QuotedStr(Edit_Local.text)+' where codigo_interno=' + inttostr(iIdReg);
      url := TidURI.URLEncode(Ws+'my_exec.php?sql='+sql);
      try
        IdHTTP.ConnectTimeout := 500;
        IdHTTP.Get(url , SS);
      finally
        response := UTF8Encode(SS.DataString);
        SS.Clear;
      end;
      if response='X' then begin showmessage('Ocorreu um erro ao gravar o local!'); close; end;
  SB.Panels[0].text:= cUsuario + ' ' + ' Local! Registrado!';
  sql := ' insert into log_sis (data,hora,Usuario,Atividade) values('+
               QuotedStr(Mydata(DatetoStr(date())))+','+QuotedStr(TimeToStr(Time))+','+
               QuotedStr(cUsuario)+','+QuotedStr('ALTEROU LOCAL op:'+edit_op.text+' de: '+ cLocal +' pçs para: '+Edit_Local.text+' pçs.')+')';
  url := TidURI.URLEncode(Ws+'my_exec.php?sql='+sql);
  try
    IdHTTP.ConnectTimeout := 10000;
    IdHTTP.Get(url , SS);
  finally
    response := UTF8Encode(SS.DataString);
    SS.Clear;
  end;
  if response='X' then begin showmessage('Ocorreu um erro ao tentar gravar o log do sistema!'); end;
  cUsuario:='';
end;

procedure TFm_Principal.Button2Click(Sender: TObject);
begin
  Application.CreateForm(Tform_V2produtos, form_V2produtos);{Carrega form na memória}
  try
    form_V2produtos.ShowModal;{Mostra form }
    if form_V2produtos.ModalResult = mrOk then
    begin
      Edit_Op.text:= form_V2produtos.ZQ1codprod.AsString;
      Edit_Op.SetFocus;
    end;
  finally
    Form_V2produtos.Free;{Qdo retorna, libera memória}
  end;

end;

procedure TFm_Principal.btConfigGdeClick(Sender: TObject);
begin
  ComPort2.ShowSetupDialog;
end;

procedure TFm_Principal.btConfigPeqClick(Sender: TObject);
begin
  ComPort1.ShowSetupDialog;
  ComPort1.StoreSettings(stRegistry, 'HKEY_LOCAL_MACHINE\Software\Dejan1');
end;


procedure TFm_Principal.btImpEtiquetaClick(Sender: TObject);
var
	pergunta:integer;
begin
  SB.Panels[0].text:= 'Identifique-se!';
  if not id_usuario(0) then begin
    SB.Panels[0].text:= 'Aguardando...';
    exit;
  end;
  ZC.connect;
  try
    if (Edit_QTD.Text = '') then begin
      ShowMessage('Preencha corretamente as informações para imprimir a etiqueta!!!');
      Exit;
    end else begin
      if messagedlg('Confirma a impressão de etiquetas!',mtconfirmation,
          [mbYes,mbNo],0,mbNo)=mrNo then exit;
      pergunta := 0; qtdpc := 0; qtdimp := 0;
      qtdpc := StrToInt(Edit_QTD.Text);
      while pergunta = 0 do begin
        qtdimp := StrToInt(InputBox('Plano de Embalagem','Digite a quantidade por EMBALAGEM.',Edit_QTD.Text));
        if qtdimp = 0 then ShowMessage('O preenchimento da quantidade é obrigatório!')
          else pergunta := 1;
      end;
      pergunta := 0;
      qtdpc := StrToInt(Edit_QTD.Text);
      ZQ.SQL.Text := 	' select cli.nominho, prod.item, itpre.descricao, prod.codprod, itpre.peso as BLK, emb.peso as PesoEmb, '+
                      ' emb.peso '+
                      ' from produtos as prod, itensprecos as itpre, clientes as cli, embalagem as emb '+
                      ' where prod.codprod = '+
                      QuotedStr(Edit_OP.Text)+
                      ' and cli.codigo = prod.cliente '+
                      ' and itpre.codigo = prod.item ';
      ZQ.Open;
      while pergunta = 0 do begin //Achar o numero de copias que devem ser efetuadas
        if QtdPc >= qtdimp then qtdpc := qtdpc - QtdImp
          else begin
            QtdImp := StrToInt(InputBox('Plano de Embalagem RESTANTES','Digite a quantidade por EMBALAGEM.',IntToStr(qtdpc)));
            if QtdPc >= qtdimp then qtdpc := qtdpc - QtdImp
               else begin QtdImp := qtdpc;  pergunta := 1; end;
          end;
        if qtdpc = 0 then pergunta := 1;
        QRLbQtd.Caption := IntToStr(QtdImp);
        QRLabel29.Caption := FloatToStr((QtdImp * ZQ.FieldByName('blk').AsFloat)+ZQ.FieldByName('pesoemb').AsFloat);
        QRDBText6.DataSet:= ZQ;
        QRDBText7.DataSet:= ZQ;
        QRDBText8.DataSet:= ZQ;
        QRDBText13.DataSet:= ZQ;
        Qrlabel29.caption:= copy(lbBruto.caption,2,length(lbBruto.caption));
        Qrlabel23.caption:= copy(lbEmbala.caption,2,length(lbEmbala.caption));
        Qrlabel24.caption:= copy(lbPliquido.caption,2,length(lbPliquido.caption));
        QrLabel5.caption := cUsuario;
        QREtiqueta.Print;
      end;
    end;
  finally
  	Edit_OP.setfocus;
    ZQ.close;
    ZC.Disconnect;
  end;
end;

end.
