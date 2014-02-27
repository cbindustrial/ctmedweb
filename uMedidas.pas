unit Umedidas;
interface

type
  PtrPessoa = ^TPessoa; {ponteiro para a estrutura da Pessoa}
  Tpessoa = record   {Estrutura da Pessoa}
    controle : integer;
    cota : real;
  end;

  procedure FormShow(Sender:TObject);
  procedure FormClose(Sender:TObject; var Action:TCloseAction);
  procedure bt_CancelarClick(Sender:TObject);
  procedure ed_Entra_DadosKeyDown(Sender:TObject; var Key:Word; Shift:TShiftState);
  procedure ed_Entra_DadosKeyPress(Sender:TObject; var Key:Char);
  procedure tm_descarteTimer(Sender:TObject);
  procedure BuscaOP;
  procedure GeraIA;
  procedure LerMedida;
  procedure PecaMorta;
  procedure ImpressaoAvulsa;
  procedure ajusta_label(mostrar:boolean);
  procedure registra_pecas;
  procedure envia_mensagem(de,para,mensagem:widestring);
  procedure avisa_ok(texto:string);
  procedure avisa_erro(texto:string);
  procedure totais_atuais();
  procedure encerramento;
  function Imprimir():boolean;
  function Buscanome():boolean;
  function registra_medidas():boolean;
  function inicia_medidas():boolean;
  function Conclui_Etapa():Boolean;
  function especialista():boolean;
  function MatrizVersatilidade():boolean;
  function FechaIA():boolean;
  function FormulaEC(cotacalc:string):double;
  function FormulaCB(cotacalc:string):double;
  function ChamaLider():boolean;
  function StrToReal(inString:String):Real;
  function fez_liberacao():boolean;
  function BuscaFoto(numero:string):string;
  function fez_auditoria_finalizacao():boolean;
  function esta_isento():boolean;
  function Mydata(mcad: string):string ;
  function plano_embalagem():boolean;
  function sem_acento(txt:string):string;
  function completa_dados():boolean;
  function operacao_existe_ctmed():boolean;
  function define_proxima_operacao():boolean;
  function digita_etapa():boolean;
  function encontrou_impressora_lpt():boolean;
  function supervisor_medidas():boolean;
  function Existem_IA():boolean;
  //24/02/2012 10:23
  private
    { Private declarations }
    function maquina_liberando():boolean;
    function maquina_finalizando():boolean;
    procedure abre_plano_acao;
  public
    { Public declarations}
    QtdPeca, DispoIA, IdIA, CodFunc, med, crm, item,
    Fechar_retrabalho, Formula, TipoMed, sOmf : string;
    QtdImp, Fase, codcli, msg : integer;
    Ponteiro : PtrPessoa;   {Variavel do tipo ponteiro}
    tabela : Tlist;   {Classe TList armazena os dados}
  end;

var
  F_Medidas : TF_Medidas;
  impressora, arq :textfile;
  VarEtiq : TStringList;
  erro_grave : boolean = false;
  hora_inicio,hora_termino,tempo_decorrido : Tdatetime;
  rMin, rMax, rLido, rErro, rCotRep, rCotLider : real;
  mensagem,sql,uri:widestring;
  Node : IXMLNode;
  SS: TStringStream;
  Response: AnsiString;
  APROVADO_REPROVADO,controles_reprovados, sLocalArq, sLinha, Imp, nome, status,
  retrabalho,codint1,codint2, planoemb, etapa,desc_proxima_operacao,desc_operacao_atual,
  equipamento_op_anterior, equipamento_op_atual, et, pesq, url,qtdatu,nroplano_acao,
  linkFoto,sPrgVisual,NroCmed, versatUser, dt : string;
  Cont, J, K, I , y, pergunta, ret, total, lote, qtd_prod_atu, Lido, Apv,
  Proxima_Operacao, Operacao_anterior, Operacao_atual,Ultima_Operacao,
  total_acumulado: integer;

implementation

uses Uprincipal, Uetapa;

{$R *.DFM}

//************** EVENTOS DO FORM

Function centro(str:string):string;
 var tam,depois,antes : integer;
begin
  str:= copy(trim(str),1,24);
  tam:= length(str);
  antes:= round((24-tam)/2);
  depois:= 24 - (antes+tam);

  result:= StringOfChar('.',antes)+ str +StringOfChar('.',depois);
end;

procedure TF_Medidas.FormShow(Sender: TObject);
begin
  
  if not Servidor_OnLine then begin
    ShowMessagepos('Erro de conexão! Problema com cabos ou roteadores! Comunique TI! ou tente a cada 30 segs. até reiniciar!',0,0);
    erro_grave := true;
    close;
  end;
  
  linkFoto:= 'http://10.0.0.50:8888/ctmed/fotos/Vista.JPG';
  controles_reprovados:='';
  SBm.SimpleText:= ' AGUARDE... ';
  if EtiqAvulsa=1 then begin
    Label1.Caption := 'REIMPRESSÃO';
    Label1.Color:= clYellow;
    Label1.Font.Color:= clRed;
  end;
  tabela := TList.Create; //Cria tabela record
  hora_inicio:= now();
  Top:= 0;
  Left:= 0;
  Width:= Screen.Width;
  Height:= Screen.Height;
  //******Ajustar o tamanho da foto a resolução da tela (P/ usar o mesmo prog. no PC e no Note)
  if Screen.Height > 600 then begin
    Panel3.Height := 482;
    Panel3.Width := 642;
  end  else  begin
    Panel3.Height := 360;
    Panel3.Width := 450;
  end;
  Panel3.Top:=41;
  Panel3.Left:=(Screen.Width - Panel3.Width );
  // inicializa variaveis
  Panel_cota.visible:=False;
  Panel_ler.visible:=false;
  ed_Entra_Dados.text:= '';
  lb_amostras.caption:= '';
  lb_Cliente.caption:= '';
  ajusta_label(false);
  Fase := 0;
  avisa_ok('Identifique-se! Passe o Código de Barras do Crachá pelo Leitor ');
  // seta o foco e aguarda o inicio de operação
  Label16.Color := clRed;
  ed_Entra_Dados.setfocus;
  erro_grave:= false;
  sOmf := 'N'; //Não deve gerar OMF caso "S" sim deve gerar
end;

procedure TF_Medidas.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  tabela.Free;
  action := caFree;
end;
procedure TF_Medidas.bt_CancelarClick(Sender: TObject);
begin
  Close;
end;

procedure TF_Medidas.ed_Entra_DadosKeyPress(Sender: TObject; var Key: Char);
begin
  if (Fase=0) then
    ed_Entra_Dados.PasswordChar:= '®' else ed_Entra_Dados.PasswordChar := #0;
end;

procedure TF_Medidas.tm_descarteTimer(Sender: TObject);
begin   {timer de descarte do apontamento por ficar inativo +5 minutos.}
  F_Medidas.close;
end;


procedure TF_Medidas.ed_Entra_DadosKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var ent, lot : real;
begin
  ent := 0; lot := 0;
  if erro_grave then begin
    key:=0;
    Fase:=0;
    erro_grave:= false;
    close;
  end;
  { define inicialmente que é uma operação de medição e não um fechamento de retrabalho }
  {????????}
  { Busca nome do FUNCIONARIO APONTADOR DA MEDIÇÃO }
  if (key=VK_RETURN) and (Fase = 0) then begin
    key:= 0;
    if (ed_Entra_Dados.Text = '') then begin ed_entra_dados.Clear; ed_entra_dados.SetFocus; exit; end;
    if (length(ed_Entra_Dados.Text)>4) then begin ed_entra_dados.Clear; ed_entra_dados.SetFocus; exit; end;
    if (strtointdef(ed_Entra_Dados.Text,0)<100) or (strtointdef(ed_Entra_Dados.Text,0)>8000) then begin ed_entra_dados.Clear; ed_entra_dados.SetFocus; exit; end;
    avisa_ok('Aguarde! Procurando o nome do responsável pelos apontamentos...');

    if not Buscanome() then begin {procura o nome do apontador da medida}
      lb_Apontador.Caption:= 'INVÁLIDO!' ;
      CodFunc := '';
      ed_Entra_Dados.setFocus;
      avisa_erro(' ATENÇÃO!!! Erro de leitura ou usuário não é cadastrado! Passe o crachá novamente.' );
      key:=0;
      Exit;
    end;
    Label16.Color := clSilver;
    Label27.Color := clRed;
    ed_Entra_Dados.Top:= Label27.Top-7;
    avisa_ok(' Passe o Código de Barras da Ordem de Produção(OP) Sobre  o Leitor ou Digite-o!');
    ed_Entra_Dados.setFocus;
    Fase:= 1;
    key:=0;
  end;
  {Busca item, cliente e total do lote DA ORDEM DE PRODUÇÃO DIGITADA}
  if (key = VK_RETURN) and (Fase = 1) then begin
    key:=0;
    if (ed_Entra_Dados.Text = '') then begin
      ed_entra_dados.Clear;
      ed_entra_dados.SetFocus;
      exit;
    end;
    if (length(ed_Entra_Dados.Text)>6) then begin
      ed_entra_dados.Clear;
      ed_entra_dados.SetFocus;
      exit;
    end;
    if (strtointdef(ed_Entra_Dados.Text,0)<10) or (strtointdef(ed_Entra_Dados.Text,0)>999820) then begin
      ed_entra_dados.Clear;
      ed_entra_dados.SetFocus;
      exit;
    end;
    avisa_ok('Aguarde! Procurando a OP e o ITEM no cadastro...');
    //*****
    dt := ''; //zera variavel que valida a data da OP
    BuscaOP;
    //*****
    key:=0;
    if item='ERRO' then begin
      avisa_erro('OP não encontrada! Repita a operação!');
      exit;
    end;
    if item = 'AUSENTE' then begin
      avisa_erro('CODIGO DO ITEM NÃO FOI PREENCHIDO!');
      ShowMessagePos(' Atenção! A OP foi encontrada porém o campo ITEM na tabela PRODUTOS está vazio...'+#13+
                   '                     AVISE seu Lider!'+#13+
                   ' Código do item ausente não permite processar os registros de medidas!',0,0);
      erro_grave:=true;
      close;
    end else begin
      lb_Item.Caption:= ''; {limpa o codigo item para busca do arquivo de fotos}
      for i:=1 to length(item) do
        if ( (copy(item,i,1) <> '.') and
             (copy(item,i,1) <> '-') and
             (copy(item,i,1) <> '/') and
             (copy(item,i,1) <> ' ') ) then
                lb_Item.caption:= lb_Item.caption + copy(item,i,1);
    end;
    Label27.Color:= clSilver;
    Fase:= 2;
    Label5.Color := clRed;
    ed_Entra_Dados.Top:= label5.Top-7;
    ed_entra_dados.Width:=30;
    ed_entra_dados.Left:=235;
    avisa_ok(' Digite o Número da Operação e tecle [Enter]');
    key:=0;
    ed_Entra_Dados.setfocus;
  end;

  {VALIDA A OPERAÇÃO DIGITADA PARA O ITEM}
  if (key=VK_RETURN) and (Fase=2) and (ed_Entra_Dados.Text <> '') then begin
    {Valida o numero e o operador}
    //Verificação para não permitir a entrada de OPs antigas
    if ((strtodate(dt) < (Date() - 60)) and  (ed_Entra_Dados.Text = '1')) then
    begin
      ShowMessage('O.P. encerrada!!!'+#13+'A data da OP deve ser maior que '+ DateToStr(Date() - 30) +#13+'Data da OP:'+ dt);
      erro_grave:= true;
      bt_CancelarClick(Self);
    end;
    key:=0;
    lb_operacao.caption:= F_Medidas.ed_Entra_Dados.Text;
    ed_Entra_Dados.Clear;
    avisa_ok(' Aguarde! Validando a operação digitada...');
    if ( (strtoint(lb_operacao.caption)< 1) or ( strtoint(lb_operacao.caption) > 20) ) then begin
      {VALIDA SE NRO ENTRE 1 E 19(MAX DE OPERAÇÕES)}
      lb_operacao.caption:= '';
      avisa_erro(' Operação Invalida! A Operação deve ser > 0 e < 20');
      ed_Entra_Dados.setfocus;
      exit;
    end;
    {se operação não existe em ctmed_itm... avisa e sai}
    if not operacao_existe_ctmed  then begin
      key:= 0;
      lb_operacao.Caption:= '';
      avisa_erro(' ATENÇÃO!!! Erro: não encontrei controles de medidas para esta operação! Confirme o número!');
      ed_Entra_Dados.setfocus;
      exit;
    end;
    if (EtiqAvulsa=1) then begin
      { SE REIMPRESSÃO ENVIA PARA ALGORITIMO PRÓPRIO }
      desc_proxima_operacao:= '';
      {pegar a proxima operação em procesprod... se não tem... avisa qualidade e não sai.}
      avisa_ok(' Aguarde! Definindo Proxima Operação...');
      if not define_proxima_operacao() then begin
        erro_grave:=true;
        exit;
      end;
      plano_embalagem;
      completa_dados;
      ImpressaoAvulsa;
      avisa_ok(' Tecle [Enter] para concluir!');
      key:=13;
      Fase:=5;
      exit;
    end;
    {se o funcionario tem a permição de realizar esta medição... se não sai}
    avisa_ok(' Aguarde! Verificando se item exige especialista...');
    if not especialista() then begin
      key:= 0;
      avisa_erro(' ATENÇÃO!!! Você não está autorizado a proceder esta medição! ');
      ShowMessagePos(' Este ITEM, nesta OPERAÇÃO, exige ESPECIALISTAS '+#13+
                     ' para efetuar o contrele de medidas.'+#13+
                     ' Informe-se com o responsável por QUALIDADE ou chame seu Lider !'+#13#13+
                     ' ESPECIALISTAS:'+#13#13+pesquisa.text,0,0);
      ed_Entra_Dados.setfocus;
      erro_grave:= true;
      exit;
    end;
   (* //Verifica se o calaborador tem o trinamento adequado para realizar esta operação
    if not MatrizVersatilidade() then begin
      key:= 0;
      avisa_erro(' ATENÇÃO!!! Você não está autorizado a proceder esta medição! ');
      ShowMessagePos(' Esta OPERAÇÃO, exige treinamento. '+#13+
                     ' Para efetuar o contrele de medidas.'+#13+
                     ' Informe-se com o responsável por QUALIDADE ou chame seu Lider !',0,0);
      ed_Entra_Dados.setfocus;
      erro_grave:= true;
      exit;
    end; *)
    key:=0;
    if not erro_grave then begin {1}
      desc_proxima_operacao:= '';
      {pegar a proxima operação em procesprod... se não tem... avisa qualidade e não sai.}
      avisa_ok(' Aguarde! Definindo Proxima Operação...');
      if not define_proxima_operacao() then begin
        erro_grave:=true;
        exit;
      end;
      label5.Color:= clSilver;
      label22.Color := clred;
      ed_Entra_Dados.Top:= label22.Top-7;
      Avisa_ok(' Tecle      [1]Liberação - [2]Auditoria - [3]Finalização');
      ed_Entra_Dados.setfocus;
      totais_atuais;{fazer independente da etapa}

      if not digita_etapa then begin erro_grave:= true; exit; end;

      if not erro_grave then begin {2}
        {uma vez a etapa identificada... se liberação/finalização busca nos cdcfs o apontamento }
        {se não tem pede retornar a maquina e apontar... se auditoria deixa mesmo sem apontamento}
        if (
              (equipamento_op_atual<>'AUSENTE')
          and (equipamento_op_atual<>'MANUAL')
          and (equipamento_op_atual<>'TERCEIRO')
          and (equipamento_op_atual<>'N/A')
          and (equipamento_op_atual<>'NA')
          and (equipamento_op_atual<>'ACABAMENTO')
          and (equipamento_op_atual<>'RETRABALHO') ) then begin
          if (etapa='L')then
            if not maquina_liberando then erro_grave:=true;
          if (etapa='F')then
            if not maquina_finalizando then erro_grave:=true;
        end;
        if not erro_grave then
          if esta_isento() then begin
            {SE NÃO REQUER NNN ENTÃO NÃO EFETUA}
            ShowMessagePos( ' Atenção: A ETAPA de apontamentos de '+
                            lb_etapa.caption+', do item: '+lb_Item.caption+#13+
                            ' está liberada. Não serão gerados apontamentos/etiquetas!',0,0);
            erro_grave:=true;
          end;
        if not erro_grave then begin {3}
          if not Conclui_etapa then begin {verifica se tem IA em aberto...}
            erro_grave:=true;
            exit;
          end;
          {Se existe IA em aberto de operações igual ou  anteriores... sai.}
          {se é auditoria não fizaliza instruções de acabamento}
          {   PROVISORIAMENTE.... ATÉ CAIO RESOLVER.
          avisa_ok('Aguarde! Verifica se existe Instrução de acabemento...');
          if (etapa<>'A') then begin

            if existem_IA() then begin
              if not FechaIA() then begin
                // NAO SEI O QUE FAZER
                //
                erro_grave:=true;
                exit;
              end;
            end;
          end;
          }
          if not erro_grave then begin
            if ((etapa='F') ) then begin
              Fase:=3;
              ed_Entra_Dados.Top:= lb_produzidas.Top;
              label25.color:= clred;
              ed_entra_dados.Left:=200;
              ed_entra_dados.Width:=65;
              avisa_ok(' Digite a quantidade TOTAL de peças produzidas, para a OPERAÇÃO !! ');
              ed_Entra_dados.SetFocus;
            end;
            if ((etapa='A') or (etapa='L'))  then encerramento;
          end;{end do if não tem erro grave 4}
        end;{end do if não tem erro grave 3}
      end;{end do if não tem erro grave 2}
    end; {end do if não tem erro_grave 1}
  end; {end do if KEYDOWN ENTER}

  {AVALIA AS QUANTIDADES PRODUZIDAS boas}
  if (key = VK_RETURN) and (Fase = 3) and (ed_Entra_Dados.Text <> '') then begin
    {Pede o total produzido para impressão na etiqueta só se for finalização}

  { 
  A PEDIDO DO EDBRAN 08/03/2012==>> NÃO PERMITIR FINALIZAÇÃO SE O TOTAL PRODUZIDO FOR INFERIOR
  *  A 60% DO LOTE.
  *  SE FOR INFERIOR PEDIR PARA JUSTIFICAR COM DUAS POSSIBILIDADES
  *   A)FERRAMENTA QUEBRADA.=> ENTÃO => ABRIR OMF PARA BLOQUEAR A PRODUÇÃO FUTURA DO ITEM
  *  ATE O CONSERTO DA FERRAMENTA E FECHAMENTO DA OMF
  *   B) MAQUINA QUEBRADA => ENTÃO => ABRAR OSM PARA BLOQUEAR A PRODUÇÃO FUTURA DO ITEM
  *  ATE O CONSERDO DA MAQUINA E FECHAMENTO DA OMM
  }

  key:=0;
    QtdPeca := '0';
    lb_produzidas.Caption := ed_Entra_Dados.Text;
    ed_entra_dados.Clear;
    QtdPeca:=  lb_produzidas.Caption;
    if ( lb_etapa.Caption = 'FINALIZAÇÃO' ) then begin
      if ( QtdPeca = '0' ) then
      begin
        if MessageDlgPos( 'Atenção! a quantidade é zero... esta hipótese só é admitida '+
        'para lançamentos de sucatas! Tem certeza que deseja continuar?',mtConfirmation,mbYesNo,0,0,0,mbNo )=mrNo then
        begin
          //avisa_erro(' A quantidade de Peça é Obrigatória!');
          //ShowMessagePos('A quantidade de Peça é Obrigatória!',0 0);
          ed_entra_dados.clear;
          ed_Entra_Dados.SetFocus;
          exit;
        end;
      end;
    end;
    // VALIDAÇÃO QUANTIDADE DE ENTRADA ESTOQUE.
    ent := (strtoint(QtdPeca) + strtoint(lb_Qtd_total.Caption));
    lot := strtoint(lb_Qtd_Lote.Caption);
    lot := lot * 1.05;
    if (ent > lot) then begin
      Showmessage(' QUANTIDADE INVÁLIDA!!!'+#13+'A quantidade total é superior a 5% do lote da O.P.'+#13+
                ' Procure o PCP para adequar as quantidades e gerar a entrada!!');
      ed_entra_dados.clear;
      ed_Entra_Dados.SetFocus;
      exit;
    end;
    // FIM ** VALIDAÇÃO QUANTIDADE DE ENTRADA ESTOQUE.
    label25.color:= clSilver;
    label10.Color:= clred;
    ed_Entra_dados.Top := label10.Top;
    begin
      avisa_ok(' Digite a quantidade de peças sucateadas...');
      Fase:=4;
      ed_Entra_Dados.SetFocus;
    end;

  end;

  {AVALIA A QUANTIDADE DE PEÇAS SUCATEADAS}
  if (key = VK_RETURN) and (Fase = 4) and (ed_Entra_Dados.Text <> '') then  begin
    key:=0;
    Fase:=6;
    lb_sucateadas.Caption:= ed_Entra_Dados.Text;
    ed_Entra_dados.Clear; ed_entra_dados.SetFocus;
    {Se a quantidade de peças sucateadas é > 0 então chama procedure pecamorta}

    if (strtointdef(lb_sucateadas.Caption,0)>0) then begin
      //definir qtd peças boas para aprovar e imprimir nas etiquetas
      lb_qtd_p_aprovar.Caption:= inttostr(strtoint( lb_produzidas.Caption) - strtoint(lb_sucateadas.Caption));

    end else lb_qtd_p_aprovar.Caption:= lb_produzidas.Caption;
    //se lb_qtd_p_aprovar + total já produzido for maior que 10% do lote não continuar... mandar reimprimir
    if (strtoint(lb_qtd_p_aprovar.caption) + strtoint(lb_qtd_total.caption)) >
        round(strtoint(lb_qtd_lote.caption) * 1.1) then begin
          showmessagepos('ATENÇÃO! o total que você está finalizando mais a quantidade que já foi finalizada é superiror ao permitido!!!'+#13+
                         ' Se precisa de etiquetas de identificação, reimprima um fechamento anterior!',0,0);
          erro_grave:=true;
          key:=13;
          exit;
    end;
    if not completa_dados then exit;
    // SE EXISTE PEÇA MORTA REGISTRA NNC E IMPRIME ETIQ REFUGO
    if (strtointdef(lb_sucateadas.Caption,0)>0) then  Pecamorta;
    label10.Color:= clSilver;
    encerramento;
  end;

  if (key = VK_RETURN) and (Fase = 5) then erro_grave:=true;

  if erro_grave then begin
    key:=0;
    erro_grave:= false;
    close;
  end;

  if (key = VK_DIVIDE) and (ed_Entra_Dados.text = '') then begin
    key:=0;
    close;
  end;

  if (key = VK_DIVIDE) and (ed_Entra_Dados.text<>'') then begin
    Key := 0;
    ed_Entra_Dados.Clear;
  end;

end;

// *************  FUNÇÕES ***********

function TF_Medidas.Buscanome():boolean; {procura pelo operador e atualiza caption com o nome}
begin
  result:= false;
  CodFunc:= ed_Entra_Dados.text;
  ed_Entra_Dados.Clear;
  sql:=  'select if(count(*)=0,'+quotedstr('X')+
         ',nomecracha) as nomecracha,versatilidade from cracha where nrocracha='+
         Quotedstr(CodFunc) ;
  if ((not Qrytab(sql)) or (Cpo[0]='X')) then exit;
  lb_Apontador.Caption:= Cpo[0];
  versatUser := Cpo[1];
  result:= true;
end;

procedure TF_Medidas.BuscaOP;
begin
  lb_OP.caption:= ed_Entra_Dados.Text;  ed_entra_dados.Clear;
  sql:='select item,lote,cliente,cadastro from produtos where codprod='+quotedstr(lb_op.caption)+ ' limit 1';
  if not Qrytab(sql) then begin item:='ERRO!'; exit; end;
  if cpo[0]='' then item:='AUSENTE' else item:= cpo[0];
  if cpo[1]='' then lb_Qtd_Lote.Caption:= '000' else lb_Qtd_Lote.Caption:= cpo[1];
  if cpo[2]='' then codcli:= 0 else codcli:= strtointdef(cpo[2],0);
  dt := cpo[3];
  dt:= copy(dt,9,2)+'/'+copy(dt,6,2)+'/'+copy(dt,1,4);
end;

function TF_Medidas.operacao_existe_ctmed():boolean;
var i : integer;
begin
  result:= false;
  {verifica se operacao existe no cadastro de itm e carrega formula se existir}
  sql:= 'select instrum from ctmed_itm where item='+
        Quotedstr(lb_item.caption)+' and operac='+quotedstr(lb_operacao.caption)+
        ' order by item, operac limit 25';
  if not Qrytab(sql) then exit;
  for i:=0 to tab.rowcount - 1 do begin
    if (copy(tab.Cells[1,i],1,7)='FORMULA') then begin
      Formula :=  tab.Cells[1,i];
    end;
  end;
  operacao_atual := strtoint(lb_operacao.caption);
  operacao_anterior:= operacao_atual - 1;
  proxima_operacao:= operacao_atual + 1;
  result:= true;
end;

function TF_Medidas.especialista():boolean;
var  i : integer;
begin {Verificar se o funcionario tem a permição de realizar esta medição}
  Result:= true;
  sql:='select count(*) from ctmed_blq where item='+quotedstr(lb_item.caption)+' and operacao='+quotedstr(lb_Operacao.caption)+' limit 10';
  if not Qrytab(sql) then begin
    showmessage('Erro ao consultar a tabela ctmed_blq para saber se existem especialisatas!');
    Result:= false;
    exit;
  end;
  if (cpo[0]='0') then exit; {se não tem especialistas para o item sai true}
  {lista quem são os especialistas}
  sql:='select nomefunc from ctmed_blq where item='+Quotedstr(lb_item.caption)+' and operacao='+quotedstr(lb_Operacao.caption)+' limit 10';
  if not Qrytab(sql) then begin
    showmessage('Erro ao consultar a tabela ctmed_blq para saber se existem especialisatas!');
    Result:= false;
    exit;
  end;
  Pesquisa.Clear;
  for i:=0 to tab.rowcount - 1 do begin
    if lb_apontador.caption=tab.cells[1,i] then exit; {se era um dos especilistas sai true}
    Pesquisa.Add(tab.cells[1,i]); {se não saiu carrega pesquisa com a lista de operadores para o showmessage}
  end;
  result:=false;
end;

function TF_Medidas.MatrizVersatilidade():boolean;
var
  grau, newVersat : string;
begin //Verifica se o calaborador tem o trinamento adequado para realizar esta operação
  Result:= false; grau := ''; newVersat := '';
  sql:='SELECT vers.codigo, vers.versatilidade FROM versatilidade AS vers, procesprod as prod WHERE (vers.versatilidade = prod.versatilidade)'+
       'AND (prod.codigo = '+QuotedStr(lb_Item.Caption)+' AND prod.operacao = '+quotedstr(lb_Operacao.Caption)+')';
  if not Qrytab(sql) then begin //Se ocorrer erro na base de dados...Avisa e sai forra da função
    showmessage('Erro ao consultar a tabela versatilidade X procesprod!');
    Result:= false;
    exit;
  end;

  if (cpo[1] = '') or (cpo[1] = 'N/A') then begin //Se for igual a N/A ou "" então so avissa que não tem versatilidade para esta operação.
    showmessage('Não existe versatilidade para este controle!'+#13+'Se for necessário uma versatilidade, Cadastre-a no processo produtivo.');
    Result:= true;
    exit;
  end;

  if (Copy(versatUser,strtoint(cpo[0]),1) = '0') then //Colaborador sem treinamento teórico, não autorizado a realizar esta operação
  begin
    showmessage('Colaborador sem treinamento '+cpo[1]+' para realizar esta processo!');
    Result:= false;
    exit;
  end;

  if strtoint(Copy(versatUser,strtoint(cpo[0]),1)) < 4 then //Analisa o grau de conhecimento de cada colaboraldor
  begin
    newVersat := versatUser;
    if Copy(versatUser,strtoint(cpo[0]),1) = '1' then begin newVersat[strtoint(cpo[0])] := '2'; grau := 'Under Job 1 '; end;
    if Copy(versatUser,strtoint(cpo[0]),1) = '2' then begin newVersat[strtoint(cpo[0])] := '3'; grau := 'Under Job 2 '; end;
    if Copy(versatUser,strtoint(cpo[0]),1) = '3' then begin newVersat[strtoint(cpo[0])] := '4'; grau := 'Aprovação do Under Job 1 e 2 '; end;
    if MessageDlg('Este colaborador está apto a/ao '+grau+' na versatilidade '+cpo[1]+'?', mtConfirmation,[mbYes, mbNo], 0) = mrYes then
    begin //Se selecionar SIM, então é alterada a MV para o novo valor
      SQL:= 'update cracha as cr set cr.versatilidade = ('+QuotedStr(newVersat)+') where cr.NomeCracha = '+QuotedStr(lb_Apontador.Caption) ;
      Result:= QryExec(sql); //Se update for realizado sem problemas libera o colaborador para realizar a operação
      exit;
    end;
  end else begin //Se não cair nas opção anteriores é porque o colaborador tem o treinamento necessáiro para realisar esta operação
    Result:= true;
    exit;
  end;
end;

function TF_Medidas.define_proxima_operacao(): boolean;
var mensagem : string; {abre procesprod e xml traz base completa para o item.}
begin
  result:= false;
  avisa_ok('Buscando a Ultima Operação...');
  sql:='select operacao,descoper,equipo,planoemb,versatilidade from procesprod where codigo='+
         Quotedstr(item)+' order by operacao';
  {item = item com acentos e pontos lb_item está limpa de acentos}
  if not Qrytab(sql) then begin
    avisa_erro('  Não encontrei a última operação!,'+#13+
               '  ou existe problemas no formato do código do item. '+#13+
               '  Verifique com Daniel Mira!');
    exit;
  end;
  {neste caso retorna a tabela de processo... campos e registros usar tab.cell}
  ultima_operacao:= strtointdef(tab.Cells[1,tab.RowCount-1],0);
  if ultima_operacao = 0 then ultima_operacao := 1;
  Planoemb:= tab.Cells[4,tab.RowCount-1];
  if planoemb = '' then planoemb:= 'INDEFINIDO' else planoemb:= sem_acento(planoemb);
  if (operacao_atual=ultima_operacao) or (operacao_atual=(ultima_operacao - 1)) then
    lb_planoembalagem.Caption:= planoemb;
  equipamento_op_atual:= tab.Cells[3,operacao_atual-1];
  desc_operacao_atual:= tab.Cells[2,operacao_atual-1];
  if ((equipamento_op_atual='') or (equipamento_op_atual='0')) then equipamento_op_atual:= 'AUSENTE';

  if ( tab.Cells[2,operacao_atual]<>'' ) then
  begin
    desc_proxima_operacao:= tab.Cells[2,operacao_atual];
  end else begin
    showmessagepos(' Não encontrei a descrição da operação '+inttostr(proxima_operacao)+'. '+#13+
                   ' Chame seu Lider! A tabela de PROCESSOS precisa ser ajustada!',0,0);
    desc_proxima_operacao := ' Procurar Sr. Renato! ';
    proxima_operacao:= 99;
    {se o operador tem certeza então falta a proxima operacão...}
    //  Envia menssagem avisando que não foi encontrado a operação de ARMAZENAR.
    mensagem:= DateToStr(date())+'-'+TimetoStr(now())+#13+#10+
      'Não foi encontrada a próxima operação para destinação do item:'+F_Medidas.lb_Item.Caption+#13+#10+
      'Favor inserir esta operação no Processo Produtivo, URGENTE. '+#13+#10+
      'Att.:';
    envia_mensagem('Controle Medidas', 'Daniel Mira',mensagem);
    envia_mensagem('Controle Medidas', 'Renato Bueno',mensagem);
  end;
  Result:=true;
end;

procedure TF_Medidas.totais_atuais();
var resp:string;
begin
  sql:='select sum(qtd), sum(sucata) from ordem_producao where op='+quotedstr(lb_op.caption)+' and operacao='+quotedstr(lb_operacao.caption)+' group by op';
  if not Qrytab(sql)then begin
    lb_qtd_total.caption:='0';
    lb_tot_sucatas.caption:='0';
    lb_retrabalho.caption:='0';
    exit;
  end;
  if cpo[0]='' then lb_qtd_total.caption:='0' else lb_qtd_total.caption:= cpo[0];
  if cpo[1]='' then lb_tot_sucatas.caption:='0' else lb_tot_sucatas.Caption:= cpo[1];
  sql:='select sum(qtd_op_ret) from ctmed_nnc where ordprod='+quotedstr(lb_op.caption)+' and opdetectora='+quotedstr(lb_operacao.caption);
  if not Qrytab(sql)then begin
    lb_retrabalho.caption:='0';
    exit;
  end;
  if cpo[0]='' then lb_retrabalho.caption:='0' else lb_retrabalho.caption:=cpo[0];
end;

function TF_Medidas.digita_etapa():boolean;
begin
  result:= false;
  Application.CreateForm(TF_Etapa, F_Etapa);
  try    {abre tela de escolha}
    F_Etapa.Height := 399;
    F_Etapa.Width := 380;
    F_Etapa.Left := 376;
    F_Etapa.Top := ((Screen.Height - F_Etapa.Height) div 2); //139;
    etapaok := false;
    F_Etapa.PanelEtapa.Visible := true;
    F_Etapa.Caption := ' DEFINA A ETAPA DO CONTROLE DE MEDIDAS ';
    F_Etapa.Showmodal;
  finally
    F_Etapa.Free;
  end;
  if not etapaOK then exit;
  if etapa='L' then lb_etapa.caption:='LIBERAÇÃO';
  if etapa='A' then lb_etapa.caption:='AUDITORIA';
  if etapa='F' then lb_etapa.Caption:='FINALIZAÇÃO';
  lb_etapa.font.Color:= clRed;
  avisa_ok(lb_etapa.caption);
  digita_etapa:= true;
end;

function TF_Medidas.maquina_liberando():boolean;
{ desativado temporariamente até que máquinas cdcf apontem 100%}
begin
  result := false;
  {
  sql:='select count(*) from cdcf_apontamentos where ordem='+quotedstr(lb_op.Caption)+' and operacao='+
        quotedstr(lb_operacao.Caption)+' and status='+quotedstr('LIBERANDO')+' and timestampdiff(minute,DTInicial,now())<20';
  if not qrytab(sql) then exit;
  if strtointdef(cpo[0],0)=0 then begin
    showmessage(' Antes de comparecer a sala de metrologia,'+#13+
                ' atualize o equipamento de acompanhamento de produção,'+#13+
                ' apertando o botão LIBERAÇÃO!!! Retorne a sua máquina e atualize!');
    exit;
  end;
  }
  result := true;
end;

function TF_Medidas.maquina_finalizando():boolean;
{destivado temporariamente até que máquinas cdcf apontem 100%}
var achou:string;
begin
  result:= false; {se retorna um é pq está apontando... se zero não encontrou a maquina}
  {
  sql:='select count(*) from cdcf_apontamentos where ordem='+quotedstr(lb_op.caption)+' and operacao='+quotedstr(lb_operacao.caption)+
       ' and status='+quotedstr('FINALIZANDO')+' and timestampdiff(minute,DTInicial,now())<16';
  if not Qrytab(sql) then exit;
  achou:= stringReplace(Pesquisa.strings[0],'|','',[rfReplaceAll]);

  if strtointdef(achou,0)=0 then begin
    showmessage(' Antes de comparecer a sala de metrologia,'+#13+
                ' atualize o equipamento de acompanhamento de produção,'+#13+
                ' apertando o botão FINALIZAÇÃO!! Retorne a sua máquina e atualize!');
    exit;
  end;
  }
  result:= true;
end;

function TF_Medidas.esta_isento():boolean;  {esta função usa HTTP por se tratar de um único registro}
var
  letra,pos: string;
begin
  result:=false;
  letra:= copy(lb_etapa.caption,1,1);
  if letra='L' then pos:= '1'
    else if letra='A' then pos:= '2'
      else if letra='F' then pos:= '3';
  sql:='select substring(med,'+pos+',1) from ctmed_itm where item='+quotedstr(lb_item.caption)+' and operac='+quotedstr(lb_operacao.caption)+
       ' order by nroctrl limit 1';
  if not Qrytab(sql) then exit;
  if (cpo[0] = letra)or(letra='A')then exit; {se X ou N isento se igual letra não é isenta}
  result := true;
end;

function TF_Medidas.Conclui_Etapa():Boolean; { Identifica a operação e a etapa que sera realizada }
begin
  result:= false;

  if (etapa='L') then begin {se liberação ver se tem auditoria/finalização da oper anterior}
    {se primeira operação não procura por A ou F na anterior}
    if operacao_atual>1 then begin
      avisa_ok('Aguarde! Procurando Auditoria/Finalização na OP anterior...');
      if not fez_auditoria_finalizacao then begin
        ShowMessagePos(' Não encontrei registros de AUDITORIA/FINALIZAÇÃO,'+#13+
                       ' do item: '+lb_Item.caption+' na operação anterior ! VERIFIQUE!',0,0);
        exit;
      end;
    end;
  end;
  {se ctmed_itm na etapa está N não precisa de fazer L A ou F}
  {se Auditoria ou Finalização verifica se houve Liberação na operação atual}
  if (etapa='F') then begin
    avisa_ok('Aguarde! Procurando a liberação da OP na operação atual...');
    if not fez_liberacao then begin
      ShowMessagePos('Erro: não encontrei registros de medidas de liberação,'+#13+
                     'do item: '+lb_Item.caption+' ! VERIFIQUE!',0,0);
      exit;
    end;
  end;
  result:=true;
end;

function TF_Medidas.Existem_IA():boolean;
begin
  result:=true;
  Fechar_retrabalho:= 'N';
  sql:= 'select count(*) from ctmed_nnc where ordprod='+quotedstr(lb_op.caption)+' and opdetectora <='+
  quotedstr(lb_operacao.caption)+' and concluido='+quotedstr('N');
  if not Qrytab(sql) then begin showmessage('Erro ao consultar Instruções de acabamento em aberto!'); erro_grave:=true; exit; end;
  if (strtointdef(cpo[0],0)>0) then begin
    result:=true;
    exit;{retorna 0 ou o nro de nnc em aberto, no caso de 0 sai false ou seja não tem}
  end;
  result:= false;
end;

function TF_Medidas.FechaIA():boolean;     //////ERRO REPASSAR ROTINA.
var pergunta : integer; resp:string; dt:string; nro_reg:string;
    function Update_NNC(reg:string; campo:string; vlr:string):boolean;
    begin
      result:=false;
      TRY
          try
            sql:= 'update_nnc.php?reg='+quotedstr(reg)+'&campo='+Quotedstr(campo)+'&vlr='+quotedstr(vlr);
            if QryExec(sql) then exit;
          except
            exit;
          end;
      FINALLY
        RESP:='';
      END;
      result:=true;
    end;
begin
  result:= false;
  {se continua é porque tem ia em aberto de operacoes anteriores e vai fazer o
      fechamento da mesma...}
  sleep(100);
  memo1.Text:= F_Principal.idhttp1.Get(WEBSERVICE+'select_nnc?nnc='+lb_OP.caption);
  XML1.Active:= false;
  try
    XML1.LoadFromXML(memo1.text);
    XML1.Active:= true;
    if XML1.IsEmptyDoc then begin
      {se for vazio ou memo1 sem xml retornar mensagem erro não encontrada... }
      showmessagepos('Erro ao obter os registros de instrução de acabamento!Chame o Lider!',0,0);
      exit;
    end;
    Node := XML1.DocumentElement.ChildNodes.FindNode('row');
    nro_reg:= Node.ChildNodes['incremento'].Text;
  except
    on EX:  EDOMParseError do begin
      exit;
    end;
  end;
  avisa_Ok('EXISTE INSTRUÇÃO DE ACABAMENTO EM ABERTO... FECHE-A PARA PROSSEGUIR!');
  if messagedlg('Deseja, Liberar/Fechar o Retrabalho?',mtconfirmation,[mbYes,mbNo],0,mbYes)= mrNo  then
    exit
  else begin  // ajusta a operação para a anterior que tinha o retrabalho....
    lb_Operacao.caption := Node.ChildNodes['opdetectora'].Text;
    operacao_atual := strtoint(lb_operacao.caption);
    operacao_anterior:= operacao_atual - 1;
    proxima_operacao:= operacao_atual + 1;
    {Rotina de liberação/fechamento de IA}
    //sERGIO: RESOLVI NÃO VERIFICAR ISSO...
    pergunta:= 0;
    while pergunta = 0 do begin //Referente a etapa do retrabalho
      Application.CreateForm(TF_Etapa, F_Etapa);
      try
        F_Etapa.Height := 399;
        F_Etapa.Width := 380;
        F_Etapa.Left := 376;
        F_Etapa.Top := ((Screen.Height - F_Etapa.Height) div 2); //139;
        etapaok := false;
        F_Etapa.PanelEtapa.Visible := true;
        F_Etapa.Caption := ' DEFINA A ETAPA DO RETRABALHO ';
        F_Etapa.Showmodal;
      finally
        F_Etapa.Free;
      end;

      if (etapa = 'L') and (Node.ChildNodes['etapa'].Text = 'L') then begin
        ShowMessagePos('Já existe uma Liberação em aberto!',0,0);
        pergunta:=1;
        erro_grave:=true;
        break;
        exit;
      end;

      if (etapa = 'F') and (Node.ChildNodes['etapa'].Text = 'F') then begin
        ShowMessagePos('Já existe uma Finalização para esta Instrução de Acabamento!',0,0);
        pergunta:=1;
        erro_grave:=true;
        break;
        exit;
      end;
      if (etapa = 'F') and (Node.ChildNodes['etapa'].Text = '') then begin
        ShowMessagePos('Não é permitido Finalizar o retrabalho sem Liberação!',0,0);
        pergunta:=1;
        erro_grave:=true;
        break;
        exit;
      end;
      pergunta:=1;
    end;

    pergunta:= 0;
    while pergunta = 0 do begin//Referente ao Disposição da não conformidade

      if Etapa = 'L' then SBm.Panels[0].Text := 'Liberação do Retrabalho!';
      if Etapa = 'F' then SBm.Panels[0].Text := 'Fechamento do Retrabalho!';
      Application.CreateForm(TF_Etapa, F_Etapa);  //Abrir form etapa mostrando o PanelFechaRetrabalho
      try
        F_Etapa.Height := 252;
        F_Etapa.Width := 407;
        F_Etapa.Left := 5;
        F_Etapa.Top := ((Screen.Height - F_Etapa.Height) div 2); //480;
        F_Etapa.PanelFechaRetrabalho.Visible := true;
        if Etapa = 'L' then F_Etapa.Label4.Caption := 'Liberação do Retrabalho!';
        if Etapa = 'F' then F_Etapa.Label4.Caption := 'Fechamento do Retrabalho!';
        F_Etapa.PanelFechaRetrabalho.Top := 0;
        F_Etapa.PanelFechaRetrabalho.Left := 0;
        F_Etapa.EdtCodigo.Text := Node.ChildNodes['codigo'].Text;
          dt:=Node.ChildNodes['data'].Text;
        F_Etapa.EdtData.Text := copy(dt,9,2)+'/'+copy(dt,6,2)+'/'+copy(dt,1,4);
        F_Etapa.EdtHora.Text := Node.ChildNodes['hora'].Text;
        F_Etapa.EdtOP.Text := Node.ChildNodes['ordprod'].Text;
        F_Etapa.EdtItem.Text := Node.ChildNodes['item'].Text;
        F_Etapa.EdtOpAtu.Text := Node.ChildNodes['opdetectora'].Text;
        F_Etapa.EdtQtdOpAtu.Text := Node.ChildNodes['qtd_op_ret'].Text;
        F_Etapa.EdtOperador.Text := Node.ChildNodes['operador'].Text;
        F_Etapa.EdtResponsavel.Text := Node.ChildNodes['responsavel'].Text;
        F_Etapa.EdtMotivoOpAtu.Text := Node.ChildNodes['obs'].Text;
        F_Etapa.Caption := 'Fechamento/Liberação da Disposição da não Conformidade';
        F_Etapa.Showmodal;
      finally //Se os campos não estiverem cadastrados corretamente entrar na rotina a baixo
        if (F_Etapa.ModalResult = mrCancel) then begin
          avisa_ok('Clique em SIM para repetir esta operação ou Clique em Não para sair.');
          if ( MessageDlgPos('Os campos não foram preenchidos corretamente. Deseja Preenchelos?',
               MtConfirmation, mbYesNo,0,0,0) = mrNo ) then pergunta := 1 else pergunta := 2;
        end;
        if pergunta = 0 then begin
        // eliminar a função interna update_nnc e postar uma string com todas as updates de uma única vez.

          pergunta := 1;
          update_nnc(nro_reg, 'etapa', Etapa);
          if (F_Etapa.EdtPcMorta.Text <> '') or (F_Etapa.EdtPcMorta.Text <> '0') then begin
            update_nnc(nro_reg,'qtd_op_atu',inttostr( strtoint(Node.ChildNodes['qtd_op_atu'].Text)+StrToInt(F_Etapa.EdtPcMorta.Text)));
            update_nnc(nro_reg, 'qtd_op_ret', inttostr(strtointdef(Node.ChildNodes['qtd_op_ret'].Text,0)+StrToIntdef(F_Etapa.EdtPcMorta.Text,0)));
          end;
          if (Etapa = 'L') then begin
            update_nnc(nro_reg,'operador_retrabalho',Node.ChildNodes['operador_retrabalho'].Text+'; '+lb_apontador.caption);
            if Node.ChildNodes['datainiret'].Text = '' then begin
              update_nnc(nro_reg,'datainiret',mydata(datetostr(date())));
              update_nnc(nro_reg, 'horainiret', timetostr(time()));
            end;
          end else begin
            if (Etapa = 'F') and (strtoint(Node.ChildNodes['qtd_op_ret'].Text)<=StrToInt(F_Etapa.EdtPcMorta.Text) + StrToInt(F_Etapa.EdtQtdOpAtu.Text)) then begin
              update_nnc(nro_reg,'concluido','S');
              update_nnc(nro_reg,'datafimret',mydata(datetostr(date())));
              update_nnc(nro_reg, 'horafimret', timetostr(time()));
              update_nnc(nro_reg, 'qtd_parc_ret',inttostr(strtointdef(Node.ChildNodes['qtd_op_ret'].Text,0) + strtointdef(Node.ChildNodes['qtd_parc_ret'].text,0)));
            end else begin
              update_nnc(nro_reg, 'concluido','N');
              update_nnc(nro_reg, 'qtd_parc_ret',inttostr(strtointdef(Node.ChildNodes['qtd_parc_ret'].text,0) + StrToIntdef(F_Etapa.EdtQtdOpAtu.Text,0)));
              update_nnc(nro_reg, 'qtd_op_ret', inttostr(strtointdef(Node.ChildNodes['qtd_op_ret'].text,0) - strtointdef(Node.ChildNodes['qtd_parc_ret'].text,0)));
            end;
          end;
        end;
      end;
      if pergunta = 2 then pergunta := 0;
      F_Etapa.Free;//Dar um free no form etapa
    end;
    if Etapa = 'L' then ShowMessagePos('A Instrução de Acabamento foi Liberada com sucesso.',0,0);
    if Etapa = 'F' then ShowMessagePos('A Instrução de Acabamento foi Fechado com sucesso.',0,0);
    Fechar_retrabalho := 'S';
    if not Imprimir() then exit;
    Exit;
  end;
  XML1.Active:= false;
  Result:= true;
end;

function TF_medidas.fez_auditoria_finalizacao():boolean;
begin
  result:= false;
  {Abrir a tabela ctmed_reg e verificar se na operacao anterior foi realizado ao menos uma AUDITORIA/FINALIZAÇÃO}
  {rotina também usada para reimprimir etiqueta}
  sql:='select etapa from ctmed_reg where codprod='+quotedstr(lb_op.caption)+' and operac='+quotedstr(inttostr(operacao_anterior))+
       ' and etapa='+quotedstr('F')+' limit 1';
  if not Qrytab(sql) then begin
    showmessage('Atenção! Erro ao consultar a tabela ctmed_reg para saber se existe Auditoria ou Finalização.');
    exit;
  end;
  if cpo[0]='N' then exit;
  result:=true;
end;

function TF_Medidas.BuscaFoto(numero: string):string;
var
  ImageMem : TMemoryStream;
  Jpimg : TJPEGImage;
begin   {esta função usa http com stream para receber imagem}
  ImageMem := TMemoryStream.Create;
  JPimg := TJPEGImage.Create;
  try
    try
      linkFoto:= 'http://10.0.0.50:8888/ctmed/fotos/'+lb_Item.caption+'-'+lb_operacao.caption+'-'+ numero+'.jpg';
      F_Principal.IdHttp1.Get('http://10.0.0.50:8888/ctmed/fotos/'+lb_Item.caption+'-'+lb_operacao.caption+'-'+ numero+'.jpg', ImageMem);
    except on e: EIdHTTPProtocolException do begin
        if e.ErrorCode = 404 then begin// código de página não encontrada
          // Não achou!
          if fileexists(Pchar(GetCurrentdir()+'\Vista.jpg')) then begin
            Imagem_Foto.Picture.LoadFromFile(Pchar(GetCurrentdir()+'\Vista.jpg'));
            linkFoto:= 'http://10.0.0.50:8888/ctmed/fotos/Vista.JPG';
          end;
          Exit;
        end;
        Exit;
      end;
    end;
    ImageMem.Seek(0,soFromBeginning);
    JPimg.LoadFromStream(ImageMem);
    Imagem_Foto.Picture.Assign(JPimg);
  finally
    ImageMem.free;
    Jpimg.Free;
  end;
end;

//******************* PROCEDURES  *************


procedure mandaEmail;
var
  Hwd:THandle;
  Arq_email: TextFile;
begin
  // grava arquivo vbs no disco e executa o vbs direto... lembrar de instalar o IIS na maq em questão.
  F_Medidas.avisa_ok('Aguarde envio do e-mail aos responsáveis...');
  AssignFile(Arq_email, 'emailpa.vbs');
  Rewrite(Arq_email);
  WriteLn(Arq_email,'Const cdoBasic = 1' );
  WriteLn(Arq_email,'Const cdoNTLM = 2');
  WriteLn(Arq_email,'Const cdoSendUsingPickup = 1');
  WriteLn(Arq_email,'Const cdoSendUsingPort = 2');
  WriteLn(Arq_email,'Const cdoDSNDefault = 0');
  WriteLn(Arq_email,'Const cdoDSNNever = 1');
  WriteLn(Arq_email,'Const cdoDSNFailure = 2');
  WriteLn(Arq_email,'Const cdoDSNSuccess = 4');
  WriteLn(Arq_email,'Const cdoDSNDelay = 8');
  WriteLn(Arq_email,'Const cdoDSNSuccessFailOrDelay = 14');
  WriteLn(Arq_email,'Dim strMsg');
  WriteLn(Arq_email,'Dim strAssunto');
  WriteLn(Arq_email,'set objMsg = CreateObject("CDO.Message")');
  WriteLn(Arq_email,'set objConf = CreateObject("CDO.Configuration")');
  WriteLn(Arq_email,'Set objFlds = objConf.Fields');
  WriteLn(Arq_email,'With objFlds');
  WriteLn(Arq_email,'  .Item("http://schemas.microsoft.com/cdo/configuration/sendusing") = cdoSendUsingPort');
  WriteLn(Arq_email,'  .Item("http://schemas.microsoft.com/cdo/configuration/smtpserver") = "smtp.terra.com.br"');
  WriteLn(Arq_email,'  .Item("http://schemas.microsoft.com/cdo/configuration/smtpauthenticate") = cdoBasic');
  WriteLn(Arq_email,'  .Item("http://schemas.microsoft.com/cdo/configuration/smtpserverport") = 587');
  WriteLn(Arq_email,'  .Item("http://schemas.microsoft.com/cdo/configuration/sendusername") = "sergio.silvestre@cbind.com.br"');
  WriteLn(Arq_email,'  .Item("http://schemas.microsoft.com/cdo/configuration/sendpassword") = "cb147258"');
  WriteLn(Arq_email,'  .Update');
  WriteLn(Arq_email,'End With');
  WriteLn(Arq_email,'strAssunto = "Plano de acao Controle Medidas: '+F_Medidas.lb_Item.caption+'"');
  WriteLn(Arq_email,'strMsg = " SR. '+responsavel+'" & vbCRLF & vbCRLF & "'+
                    'Plano de ação: '+nroplano_acao+'" & vbCRLF & "Item/OP: '+F_Medidas.lb_Item.caption+' / '+
                    F_Medidas.lb_OP.caption+'" & vbCRLF & "Operação: '+
                    F_medidas.lb_Operacao.caption+'" & vbCRLF & "Nro. Controle de medidas: '+
                    F_Medidas.label24.caption+'" & vbCRLF & "'+
                    '  Este Plano de ação foi aberto neste momento e requer  sua atenção para seu prosseguimento.'+
                    '" & vbCRLF & " Dentro da CB Industrial acesse o link: http://10.0.0.50:8888/ctmed/plano_acao/mostra_plano.php?pa='+nroplano_acao+
                    '" & vbCRLF & " Em campo, acesse o link: http://201.27.22.186:8888/ctmed/plano_acao/mostra_plano.php?pa='+nroplano_acao+
                    '" & vbCRLF & "   Grato."');
  WriteLn(Arq_email,' ');
  WriteLn(Arq_email,'With objMsg');
  WriteLn(Arq_email,'  Set .Configuration = objConf');
  WriteLn(Arq_email,'  .To = "'+email+'" ');
  WriteLn(Arq_email,'  .Cc = "assistenciatecnica@cbind.com.br"');
  WriteLn(Arq_email,'  .From = "sergio.silvestre@cbind.com.br"');
  WriteLn(Arq_email,'  .Subject = strAssunto');
  WriteLn(Arq_email,'  .TextBody = strMsg ');
  WriteLn(Arq_email,'  .DSNOptions = cdoDSNSuccessFailOrDelay');
  WriteLn(Arq_email,'  .Fields.update');
  WriteLn(Arq_email,'  .Send');
  WriteLn(Arq_email,'End With');
  CloseFile(Arq_email);
  ShellExecute(Hwd, 'open', 'emailpa.vbs',nil,nil,SW_HIDE);
end;

procedure TF_Medidas.avisa_ok(texto:string);
begin  {mensagem de aviso em statusbar}
  SBm.Color := clgreen;
  sleep(200);
  SBm.Color := clyellow;
  SBm.Font.color := clblue;
  SBm.Panels[0].Text := texto;
  Application.ProcessMessages;{usada em loops longos para liberação do processador}
end;

procedure TF_Medidas.avisa_erro(texto:string);
begin    {mensagem de erro em statusbar}
  SBm.Color:= clyellow;
  sleep(200);
  SBm.Color:= clred;
  SBm.Font.color:= clwhite;
  SBm.Panels[0].Text:= texto;
  sleep(1000);
  Application.ProcessMessages;{usada em loops longos para liberação do processador}
end;

procedure TF_Medidas.abre_plano_acao;
var
  ListaCausa : TStringList;
  prazo, prevista : Tdatetime;
  cp_prazo,cp_prevista, codomf, codomfp : string;
begin
  ListaCausa:= TStringList.Create;
  try
    ctrl:=0; resp := ''; codomf :='0'; codomfp:='0';
    if sOmf = 'N' then //Gera Plano de ação do item
    begin
      //ListaCausa.Add(' 1 - A cota SEMPRE sai fora do especificado;');  //conf renato
      //ListaCausa.Add(' 2 - ;');     //conf renato
      ListaCausa.Add(' 1 - É dificil entender e aplicar a instrução para medição;');
      ListaCausa.Add(' 2 - O PROCESSO não permite a cota correta;');
      // ListaCausa.Add(' 5 - MATÉRIA-PRIMA apresenta problemas;'); //conf renato
      // ListaCausa.Add(' 6 - MATÉRIA-PRIMA fora do especificado;');  //conf renato
      ListaCausa.Add(' 3 - O Operador não soube medir a peça;');
      ListaCausa.Add(' 4 - O Operador não soube produzir a peça;');
      //  ListaCausa.Add(' 9 - Ajuste de set-up.'); //conf renato
      while ctrl = 0 do begin
      if InputQuery('Causa do problema.', 'Qual foi a causa do problema detectado na inspeção?'+#13+#13+ListaCausa.Text,resp) then
        ctrl := strtoint(resp) else ctrl := 99;
      end;
      causa:= inttostr(ctrl);
      case ctrl of
        //1:begin responsavel:= 'Daniel Mira'; email:='qualidade@cbind.com.br'; assunto:='' end;
        // 2:begin responsavel:= 'Daniel Mira'; email:='qualidade@cbind.com.br'; end;
        1:begin responsavel:= 'Daniel Mira'; email:='qualidade@cbind.com.br'; end;
        2:begin responsavel:= 'Daniel Mira'; email:='qualidade@cbind.com.br'; end;
        //5:begin responsavel:= 'Ronaldo Alves'; email:='engenharia@cbind.com.br'; end;
        //6:begin responsavel:= 'Daniel Mira'; email:='qualidade@cbind.com.br'; end;
        3:begin responsavel:= 'Fabio Lopes'; email:='fabio.lopes@cbind.com.br'; end;
        4:begin responsavel:= 'Fabio Lopes'; email:='fabio.lopes@cbind.com.br'; end;
        //9:begin responsavel:= 'Fabio Lopes'; email:='fabio.lopes@cbind.com.br'; end;
      end;
    end else begin //Se for ferramental inserir nova ordem e pegar o seu codigo
      sql := 'select * from ferr_OMF where item ='+quotedstr(lb_item.caption)+' and operacao='+quotedstr(lb_Operacao.caption)+' and dttermino = 0';
      if not Qrytab(sql) then begin showmessage('Houve erro na inserção! Verifique!');  exit; end;
      if cpo[0] = '' then//verificar se ja existe omf em aberto
      begin
        causa := '5';
        supervisor := 'SISTEMA';
        sql := 'insert into ferr_OMF (item, operacao, critico, dtCadastro,dtPrevista,supervisor) values '+
        '('+quotedstr(lb_item.caption)+', '+quotedstr(lb_Operacao.caption)+', 1, now(), timestampadd(day,5,now()), '+
        quotedstr(supervisor)+')';
        if not QryExec(sql) then begin showmessage('Houve erro na inserção! Verifique!');  exit; end;
        sql := 'insert into ferr_OMF_prob (inc_ferr, cod_problema) values '+
                '((select inc from ferr_OMF order by inc desc limit 1),21)';
        if not QryExec(sql) then begin showmessage('Houve erro na inserção! Verifique!');  exit; end;

        sql := 'select MAX(inc) from ferr_OMF_prob'; //grava no PA o inc do problema
        if not Qrytab(sql) then begin showmessage('Houve erro na seleção! Verifique!');  exit; end;
        codomf := cpo[0];//salva o codigo da ofm
        sOmf := 'N'; //Desmarca opção de gerar OMF
      end else begin //Caso já exista, apenas é gravado o problema
        sql := 'insert into ferr_OMF_prob (inc_ferr, cod_problema) values '+
                '('+QuotedStr(cpo[0])+',21)';
        if not QryExec(sql) then begin showmessage('Houve erro na inserção! Verifique!');  exit; end;
        sql := 'select MAX(inc) from ferr_OMF_prob'; //grava no PA o inc do problema
        if not Qrytab(sql) then begin showmessage('Houve erro na seleção! Verifique!');  exit; end;
        codomf := cpo[0];//salva o codigo da ofm
      end;
    end;
    if causa <> '99' then
    begin
      Pesquisa.Clear;
      Pesquisa.Text:= F_Principal.idhttp1.Get(WEBSERVICE+
        '/plano_acao/consulta_reinc.php?item='+
        quotedstr(lb_item.caption)+'&operac='+
        quotedstr(lb_Operacao.caption)+'&ctrl='+
        quotedstr(label24.caption));
      // se já existe o mesmo em aberto lança reincidencia caso contrario lança novo plano
      if (Strtointdef(Pesquisa.strings[0],0) > 0) then begin    {existe então grava reincidencia}
        sql:='insert into ctmed_pa_reincF (abertura,causa,supervisor,responsavel,Operador,item,'+
            'operac,nroctrl,codomf,Min,Max,cotlider,Med) values (now(),'+
        quotedstr(causa)+','+
        quotedstr(supervisor)+','+
        quotedstr(responsavel)+','+
        quotedstr(lb_Apontador.caption)+','+
        quotedstr(lb_item.caption)+','+
        quotedstr(lb_Operacao.caption)+','+
        quotedstr(label24.caption)+','+
        quotedstr(codomf)+','+
        quotedstr(FloatToStr(rMin))+','+
        quotedstr(FloatToStr(rMax))+','+
        quotedstr(FloatToStr(rCotLider))+','+
        quotedstr(FloatToStr(rLido))+')';
        if not QryExec(sql) then begin showmessage('Houve erro na inserção da reincidência! Verifique!');  exit; end;
      end;
      prazo:= now() + 7; //edbran 08/03 pre estabelece 7 dias porem pode mudar uma vez a prevista
      cp_prazo:= Mydata(Datetostr(prazo));
      prevista:= now() + 7;
      cp_prevista:= Mydata(Datetostr(prevista));
      // registra o novo plano de ação ...
      sql:='insert into ctmed_p_acao (causa,supervisor,apontador,responsavel,operador,data_prazo,'+
           'data_prevista,item,codprod,operac,nroctrl,codomf,min,max,cotlider,med) values ('+
        quotedstr(causa)+','+
        quotedstr(supervisor)+','+
        quotedstr(lb_apontador.caption)+','+
        quotedstr(responsavel)+','+
        quotedstr(lb_Operador.caption)+','+
        quotedstr(cp_prazo)+','+
        quotedstr(cp_prevista)+','+
        quotedstr(lb_item.caption)+','+
        quotedstr(lb_OP.caption)+','+
        quotedstr(lb_Operacao.caption)+','+
        quotedstr(label24.caption)+','+
        quotedstr(codomf)+','+
        quotedstr(FloatToStr(rMin))+','+
        quotedstr(FloatToStr(rMax))+','+
        quotedstr(FloatToStr(rCotLider))+','+
        quotedstr(FloatToStr(rLido))+')';
      // envia e-mail para o responsavel...
      if not QryExec(sql) then  begin showmessage('não gravei o plano de ação na tabela.. houve erros.'); exit; end;
      sql:='select inc from ctmed_p_acao order by inc desc limit 1';
      Qrytab(sql);
      nroplano_acao:= StringReplace(pesquisa.Strings[0],'|','',[rfReplaceAll]);
      if sOmf = 'N' then mandaEmail;
    end;
  finally
    ListaCausa.Free;
  end;
  avisa_ok('Reinsira a cota encontrada!');
end;

procedure TF_Medidas.ajusta_label(mostrar:boolean);
begin
  label11.Visible:= mostrar;
  lb_equipo_aval.visible:= mostrar;
  label13.visible:= mostrar;
  lb_amostras.Visible:= mostrar;
  label15.Visible:= mostrar;
  lb_frequencia.Visible:= mostrar;
  label17.Visible:= mostrar;
  lb_metodo.visible:= mostrar;
  label18.Visible:= mostrar;
  lb_plano_reacao.Visible:= mostrar;
end;

function TF_Medidas.FormulaEC(cotacalc: string): double; {Calcula formula de Entre-Centro}
var C1, C2, C3 : string;
    res : Double;
begin
  if tabela.Count = 3 then begin
    Ponteiro := tabela.Items[ 0 ];
    C1 := FloatToStr(Ponteiro^.cota);
    Ponteiro := tabela.Items[ 1 ];
    C2 := FloatToStr(Ponteiro^.cota);
    Ponteiro := tabela.Items[ 2 ];
    C3 := FloatToStr(Ponteiro^.cota);
    res := (StrToFloat(C1) - StrToFloat(C2));
    Result := (StrToFloat(C3) - res);
  end
    else result:=0;
end;

function TF_Medidas.FormulaCB(cotacalc: string): double; {Calcula formula de Centro-Base}
var c1, c2 : string;
begin
  c1 := ''; c2 := '';
  if tabela.Count = 2 then begin
    Ponteiro := tabela.Items[ 0 ];
    C1 := FloatToStr(Ponteiro^.cota);
    Ponteiro := tabela.Items[ 1 ];
    C2 := FloatToStr(Ponteiro^.cota);
    result := (StrToFloat(C1) + StrToFloat(C2));
  end
    else result := 0;
end;


function TF_Medidas.fez_liberacao():boolean;
var resp:string;
begin
  result := false;  {se auditoria ou finalização e a liberação não é requerida sai true }
  sql:='select substring(med,1,1) from ctmed_itm where item='+quotedstr(lb_item.Caption)+
  ' and operac='+quotedstr(lb_operacao.Caption)+' limit 1';
  Qrytab(sql);
  if Pesquisa.Strings[0]='N|' then  begin result:= true; exit;  end;
  {se finalização a liberação é necessária e se não foi executada, sai false}
  sql:='select count(*) from ctmed_reg where codprod='+quotedstr(lb_op.Caption)+' and operac='+quotedstr(lb_operacao.caption)+' and etapa='+
        quotedstr('L')+' and timestampdiff(minute, timestamp(data,hora), now() ) > 10 ';
  Qrytab(sql);
  if Pesquisa.Strings[0]='0|' then exit;
  result:= true;
end;

function TF_Medidas.Mydata(mcad: string):string ;
var
  ts1,ts2,ts3,tsdat : string ;
begin
  ts1 := copy(mcad,1,2) ;
  ts2 := copy(mcad,4,2);
  ts3 := copy(mcad,7,4) ;
  tsdat := ts3+'-'+ts2+'-'+ts1;
  result := tsdat;
end;

function TF_Medidas.sem_acento(txt:string):string;
var
  txt2 : string;
  i : integer;
begin
  txt2:='';
  for i := 1 to length(txt) do
  begin
    txt2 := txt2 + copy(txt,i,1);
    if (copy(txt2,i,1)='á')  then txt2 := copy(txt2,1,(i-1)) + 'a';
    if (copy(txt2,i,1)='Á')  then txt2 := copy(txt2,1,(i-1)) + 'A';
    if (copy(txt2,i,1)='à')  then txt2 := copy(txt2,1,(i-1)) + 'a';
    if (copy(txt2,i,1)='À')  then txt2 := copy(txt2,1,(i-1)) + 'A';
    if (copy(txt2,i,1)='ã')  then txt2 := copy(txt2,1,(i-1)) + 'a';
    if (copy(txt2,i,1)='Ã')  then txt2 := copy(txt2,1,(i-1)) + 'A';
    if (copy(txt2,i,1)='â')  then txt2 := copy(txt2,1,(i-1)) + 'a';
    if (copy(txt2,i,1)='Â')  then txt2 := copy(txt2,1,(i-1)) + 'A';
    if (copy(txt2,i,1)='é')  then txt2 := copy(txt2,1,(i-1)) + 'e';
    if (copy(txt2,i,1)='É')  then txt2 := copy(txt2,1,(i-1)) + 'E';
    if (copy(txt2,i,1)='ê')  then txt2 := copy(txt2,1,(i-1)) + 'e';
    if (copy(txt2,i,1)='Ê')  then txt2 := copy(txt2,1,(i-1)) + 'E';
    if (copy(txt2,i,1)='í')  then txt2 := copy(txt2,1,(i-1)) + 'i';
    if (copy(txt2,i,1)='Í')  then txt2 := copy(txt2,1,(i-1)) + 'I';
    if (copy(txt2,i,1)='ó')  then txt2 := copy(txt2,1,(i-1)) + 'o';
    if (copy(txt2,i,1)='Ó')  then txt2 := copy(txt2,1,(i-1)) + 'O';
    if (copy(txt2,i,1)='õ')  then txt2 := copy(txt2,1,(i-1)) + 'o';
    if (copy(txt2,i,1)='Õ')  then txt2 := copy(txt2,1,(i-1)) + 'O';
    if (copy(txt2,i,1)='ô')  then txt2 := copy(txt2,1,(i-1)) + 'o';
    if (copy(txt2,i,1)='Ô')  then txt2 := copy(txt2,1,(i-1)) + 'O';
    if (copy(txt2,i,1)='ú')  then txt2 := copy(txt2,1,(i-1)) + 'u';
    if (copy(txt2,i,1)='Ú')  then txt2 := copy(txt2,1,(i-1)) + 'U';
    if (copy(txt2,i,1)='ç')  then txt2 := copy(txt2,1,(i-1)) + 'c';
    if (copy(txt2,i,1)='Ç')  then txt2 := copy(txt2,1,(i-1)) + 'C';
  end;
  result := txt2;
end;

Function TF_Medidas.StrToReal(inString :String): Real;
{converte um número em Float}
var
  sInt, sDec : string;
  Int, Dec : integer;
  rDec : real;
  i,j : Integer;
begin
  sInt := '';
  sDec := '';
  j := 1;
  while ( (copy(inString,j,1) = '0') or
         (copy(inString,j,1) = '1') or
         (copy(inString,j,1) = '2') or
         (copy(inString,j,1) = '3') or
         (copy(inString,j,1) = '4') or
         (copy(inString,j,1) = '5') or
         (copy(inString,j,1) = '6') or
         (copy(inString,j,1) = '7') or
         (copy(inString,j,1) = '8') or
         (copy(inString,j,1) = '9') ) and (j <= length(inString)) do begin
    sInt := sInt + copy(inString,j,1);
    j := j + 1;
  end;
  j := j + 1;
  while ( (copy(inString,j,1) = '0') or
         (copy(inString,j,1) = '1') or
         (copy(inString,j,1) = '2') or
         (copy(inString,j,1) = '3') or
         (copy(inString,j,1) = '4') or
         (copy(inString,j,1) = '5') or
         (copy(inString,j,1) = '6') or
         (copy(inString,j,1) = '7') or
         (copy(inString,j,1) = '8') or
         (copy(inString,j,1) = '9') ) and
         (j <= length(inString)) do  begin
    sDec := sDec + copy(inString,j,1);
    j := j + 1;
  end;
  Int := strtoint(sint);
  if sdec<>'' then Dec := strtoint(sdec) else dec := 0;
  i := 1;
  for j := 1 to length(sdec) do i := i * 10;
  if Dec > 0 then rdec := (dec/i) else rdec := 0;
  Result := (int + rdec);
End;



function TF_Medidas.supervisor_medidas():boolean;
begin
  result:= false;
  pesquisa.clear;
  pesquisa.Text:=stringreplace(F_Principal.idhttp1.Get(
        WEBSERVICE+'select_04.php?cod='+CodFunc),'&',#13#10,[rfreplaceAll]);  //select4  busca chave acesso
  if pesquisa.Strings[0]='X' then exit;
  Supervisor:= pesquisa.Strings[0];
  showmessage('supervisor é : '+Supervisor);
  sChaveAcesso:= pesquisa.Strings[1];
  if not autorizado('SupervisorControleMedidas') then begin Supervisor:=''; Exit; end;
  result:= true;
end;



Function TF_Medidas.ChamaLider():boolean;
begin
  Result := False;
  ShowMessagePos('Chame o Líder/Qualidade!',0,0);
  Application.CreateForm(TF_Etapa, F_Etapa);
  try
    F_Etapa.Height := 148;
    F_Etapa.Width := 238;
    F_Etapa.PanelPedSenha.Top := 0;
    F_Etapa.PanelPedSenha.Left := 0;
    F_Etapa.Left := 75;
    F_Etapa.Top := Panel2.Top;
    Supervisor:='';
    F_Etapa.PanelPedSenha.Visible := true;
    F_Etapa.Edit2.Clear;
    F_Etapa.Edit2.text := '';
    F_Etapa.Caption := 'Restrição de Acesso';
    F_Etapa.Showmodal;
  finally
    F_Etapa.Free;
  end;
  if SenhaOk then begin
    msg := 0;
    msg := MessageDlgPos('Foi evidenciado a Não Conformidade?', MtConfirmation, mbYesNo, 0,0,0);
    if msg = mrYes then begin
      GeraIA;   {REPROVOU}
      ShowMessagePos('ATENÇÃO!!!'+#13+' 1 - Identificar o Material!!!'+#13+' 2 - Enviar para o retrabalho!',0,0);
      APROVADO_REPROVADO:= 'R';
      Apv:=2;
      if not registra_medidas() then exit;
      if not Imprimir() then exit;

    end else begin
      abre_plano_acao;  {aprovou... mas abre plano para não acontecer novamente}
      APROVADO_REPROVADO:= 'A';  {procede registro da inspeção como liberado}
      Apv:=3;
      if not registra_medidas() then exit;
    end;
    result:=true;
  end else begin
    ShowMessagePos('Senha Inválida, Apontamento descartado!'+#13+'  Reinicie a operação!',0,0);
    Apv:=0;
    Result := False;
  end;
end;






procedure TF_Medidas.LerMedida;
begin
  Application.CreateForm(TF_Etapa, F_Etapa);
  try
    //Se existe formula para este controle então jogar a cota automaticamente.
    F_Etapa.Height := 132;
    F_Etapa.Width := 219;
    F_Etapa.PanelLer.Top := 0;
    F_Etapa.PanelLer.Left := 0;
    F_Etapa.Left := 75;
    F_Etapa.Top := panel2.top;
    Lido := mrCancel;
    F_Etapa.PanelLer.Visible := true;
    F_Etapa.Edit1.text := '';
    F_Etapa.Caption := '>> '+lb_equipo_aval.caption+' <<';
    F_Etapa.Showmodal;
  finally
    F_Etapa.Free;
  end;
end;

function TF_Medidas.encontrou_impressora_lpt():boolean;
var
  ts:TStrings;
  J,I:integer;
begin
  Result:=false;
  if Screen.Height <= 600 then winexec('c:\cbindw\imp.bat', SW_HIDE);
  TS := Printer.Printers;
  J := -1;
  For I := 0 to TS.Count -1 do begin
    Imp := copy(TS.Strings[I],1,7);
    If uppercase(copy(TS.Strings[I],1,7)) = 'GENERIC' then J := I;
  end;
  Printer.PrinterIndex := J;
  If (J = -1) then Exit;
  Result:=true;
end;



procedure TF_Medidas.PecaMorta;
var  {registra as peças declaradas como sucatas em nnc e produtos}
  i, pergunta : integer;
  sql,mot_atual, mot_anterior,  QtdAnt, DescMotivo_atual, DescMotivo_anterior: string;
  lista:TStringlist;  variaveis : TStringList;
  Function NovoInputBox(const TituloJanela: TCaption; const TituloLabel: TCaption; var S: String): string;
  var
    Form: TForm; Edt: TEdit;
  begin
    Result := '0';
    Form := TForm.Create(Application);
    try
      Form.BorderStyle := bsDialog;
      Form.Caption := TituloJanela;
      Form.Position := poScreenCenter;
      Form.Width := 350;
      //Form.Height := 120;
      Form.Height := 100+( Lista.Count * 16);//nro de linhas x 16pixels
      with TLabel.Create(Form) do
      begin
        Parent := Form;
        Caption := TituloLabel;
        Left := 10;
        Top := 10;
      end;
      Edt := TEdit.Create(Form);
      with Edt do
      begin
        Parent := Form;
        Left := 10;
        Top := Form.Height - 55;
        Width := 50;
      end;
      with TBitBtn.Create(Form) do
      begin
        Parent := Form;
        Left := trunc((Form.ClientWidth)/2)-100;
        Top := Form.Height - 55;
        Kind := bkOK;
      end;
      if Form.ShowModal = mrOK then
      begin
        Result := Edt.Text;
      end;

      finally
      Form.Free;
    end;
  end;
  function imprime_refugo():integer;
    Function centraliza(str:string):string;
    var tam, vazio : integer;
    begin
      str:= copy(str,1,22);
      tam:= length(str);
      vazio:= round((22-tam)/2);
      result:= StringOfChar(' ',vazio)+str;
    end;
  begin
    AssignFile(IMPRESSORA, '/dev/usb/lp0');
    Rewrite(IMPRESSORA);
      Writeln(Impressora,#27#87#1#27#67#10);
     Writeln(Impressora,centro('REFUGO')+#10);
     Writeln(impressora,DateToStr(Now)+' - '+TimeToStr(Time) + #10);
     Writeln(Impressora, centro(lb_Cliente.Caption)+ #10);
     Writeln(Impressora,'ITEM: '+copy(trim(item),1,18));
     Writeln(Impressora,copy(trim(lb_descr_item.caption),1,24));
     Writeln(Impressora,'OPER: '+trim(lb_Operacao.caption));
     Writeln(Impressora,'DESCR: '+sem_acento(trim(desc_operacao_atual)));
     Writeln(impressora,'O.P.: '+lb_OP.caption+' Qtd.: '+lb_sucateadas.Caption);
     Writeln(Impressora,'MOTIVO: ');
     Writeln(Impressora,copy(trim(DescMotivo_atual),1,24)+#10);
     Writeln(Impressora,'APONTADOR:');
     Writeln(impressora,copy(sem_acento(trim(lb_apontador.caption)),1,24));
     Writeln(Impressora,'MAQ-OPERADOR:');
     Writeln(impressora,copy(trim(lb_maquina.caption+'-'+sem_acento(lb_Operador.caption)),1,24)+ #10);
      Writeln(Impressora,'........................'+#10#10#10#10#10#10#10#10#10);
      Writeln(Impressora,#27#87#0);
    CloseFile(Impressora);
  end;

begin
  QtdAtu := ''; QtdAnt := ''; Mot_atual:= ''; Mot_anterior:= ''; DescMotivo_atual := ''; DescMotivo_anterior := '';
  QtdAtu:=lb_sucateadas.Caption;
  //lb_tot_sucatas.Caption:= inttostr( strtoint(lb_tot_sucatas.Caption) + strtoint(lb_sucateadas.Caption) );
  Lista:= TStringList.Create;
  Pesquisa.Clear;
  Pesquisa.Text:= stringreplace(F_Principal.idhttp1.Get(WEBSERVICE+'select_motivo.php'),'&',#13#10,[rfreplaceAll]); //se_operacao_existe
  try
    for i:=0 to Pesquisa.Count-1 do {popular lista com a tabela de motivos para scrap}
      Lista.Add(inttostr(i+1)+' - '+Pesquisa.Strings[i]);
    pergunta := 0;
    if (QtdAtu <> '') and (QtdAtu <> '0') then begin
      avisa_ok(' Digite o numero correspondente ao motivo e tecle ENTER.');
      while pergunta=0 do begin
        mot_atual := Novoinputbox('Motivo da não Conformidade.','Qual foi o motivo da não conformidade?'+
                                 #13+#13+Lista.Text,mot_atual);
        if (strtointdef( mot_atual,0)>0) and (strtointdef(mot_atual,0)<=Lista.Count) then
          pergunta:=1;
      end;
      DescMotivo_atual := Lista.Strings[strtoint(mot_atual)-1];
    end;
    if QtdAnt = '' then QtdAnt := '0';
    if QtdAtu = '' then QtdAtu := '0';

    imprime_refugo();

      SQL:='insert into ctmed_nnc (codigo) values('+Quotedstr(lb_OP.Caption + lb_operacao.caption)+')';
      sql:= TIdURI.URLEncode(WEBSERVICE+'inserts.php?sql='+sql);
      Pesquisa.Clear;
      Pesquisa.Text:= F_Principal.idhttp1.Get(sql);
      variaveis:= TStringList.Create;
      try
        variaveis.Add('ano='+FormatDateTime('yy',date));
        variaveis.Add('data='+FormatDateTime('yyyy-mm-dd',date));
        variaveis.Add('hora='+timetostr(Time));
        variaveis.Add('ordprod='+lb_OP.caption);
        variaveis.Add('codcli='+inttostr(codcli));
        variaveis.Add('item='+lb_item.Caption);
        variaveis.Add('opdetectora='+lb_operacao.Caption);
        variaveis.Add('operador='+lb_apontador.Caption);
        variaveis.Add('qtd_op_atu='+QtdAtu);
        variaveis.Add('motivo_atu='+DescMotivo_atual);
        variaveis.Add('disposicao=SUCATA');
        variaveis.Add('concluido=S');
        //F_Principal.IdHttp.Request.ContentType := 'application/x-www-form-urlencoded';
        resp:= F_Principal.idhttp1.Post(WEBSERVICE+'update_nnc_post.php',variaveis);
        if resp='X' then showmessage('Houve erro na atualização do ctmed_nnc! Repita!');
      finally
        variaveis.Free;
      end;

    // aumenta o scrap em produtos... só na entrada em estoque... O TOT SCRAP AQUI É O DESTA OPERAÇÃO.

    SQL:='update produtos set scrap=(scrap+'+QtdAtu+') where codprod='+quotedstr(lb_OP.Caption); //%2B é o codigo para + que o URIencode não trata.
    if not qryExec(sql) then begin showmessage('Houve erro ao gravar scrap na tabela produtos!'); end;

//    sql:= ' INSERT INTO ZA2010 '+
//    '(R_E_C_N_O_, ZA2_OPCB, ZA2_DATREG, ZA2_HORREG, ZA2_QTDPRO, ZA2_SCRAP) '+
//    ' SELECT COUNT(*), '+quotedstr(lb_OP.Caption)+', '+
//    QuotedStr(copy(datetostr(date()),7,4)+copy(datetostr(date()),4,2)+copy(datetostr(date()),1,2))+', '+
//    QuotedStr(timetostr(now()))+', '+
//    QuotedStr('0')+', '+
//    quotedstr(QtdAtu)+' FROM ZA2010';
//    showmessage(sql);
    url:= TidURI.URLEncode('http://10.0.0.50:8888/cbindw/Ent_QtdEst.php?op='+ lb_OP.Caption+
                            '&pc=0&scp='+QtdAtu);

    Pesquisa.clear;
    Pesquisa.text:= F_Principal.IdHTTP1.Get(url);
    if pesquisa.Strings[0]='X' then begin showmessage('Erro ao gravar registro na tabela ZA2010!');  end;

  finally
    lista.Free;
  end;
end;

procedure TF_Medidas.GeraIA;
var pergunta : integer;
    disposicao,cp_concluido,cp_codigo,cp_data,cp_hora,cp_ano,cp_ordprod,
    cp_item,cp_opdetectora,cp_responsavel,cp_operador,cp_qtd_op_ret,
    cp_disposicao,cp_codcli, cp_motivo_atu,cp_obs, resp,sql : string;
    variaveis : TStringList;
begin
   IdIA := ''; DispoIA := '';
  cp_codigo:= lb_OP.Caption + lb_operacao.caption;
  pergunta:= 0;
  while pergunta = 0 do begin {Referente ao Motivo da Reprovação}
    avisa_ok('Digite o motivo e a quantidade para RETRABALHAR e tecle [ENTER]!');
    try
      Application.CreateForm(TF_Etapa, F_Etapa);  //Abrir form etapa mostrando o panelIA
      F_Etapa.Height := 192;
      F_Etapa.Width := 314;
      F_Etapa.Left := 5;
      F_Etapa.Top := ((Screen.Height - F_Etapa.Height) div 2); //480;
      F_Etapa.PanelIA.Visible := true;
      F_Etapa.PanelIA.Top := 0;
      F_Etapa.PanelIA.Left := 0;
      F_Etapa.Edit3.Text:= lb_retrabalho.caption;
      F_Etapa.Caption := 'Formulário de Retrabalho';
      F_Etapa.Showmodal;
    finally //Se os campos não estiverem cadastrados corretamente entrar na rotina a baixo
      if ((F_Etapa.CheckBox1.Checked = false) or (F_Etapa.CheckBox2.Checked = false) or (F_Etapa.CheckBox3.Checked = false)
        or (F_Etapa.CheckBox4.Checked = false) or (F_Etapa.CheckBox5.Checked = false)) and
        ((F_Etapa.Edit3.Text = '0') or (F_Etapa.Edit3.Text = '')) then
          avisa_erro('Dados incompletos... preencha como requisitado!')
          else pergunta:=1;
      if pergunta = 1 then begin
        IdIA := cp_codigo;
        cp_ano:= FormatDateTime('yy',date);
        cp_data:= mydata(datetostr(Date));
        cp_Hora:= timetostr(Time);
        cp_ordprod:= lb_OP.caption;
        cp_item:= lb_Item.Caption;
        cp_opdetectora:= lb_operacao.Caption;
        cp_operador:= lb_apontador.caption;
        cp_responsavel:= Supervisor;
        cp_qtd_op_ret:= F_Etapa.Edit3.Text; {o total informado no edit}
        cp_disposicao:= 'RETRABALHO';
        cp_codcli:= inttostr(codcli);
        cp_motivo_atu:='';
        if F_Etapa.CheckBox1.Checked = True then
          cp_motivo_atu:= F_Etapa.CheckBox1.Caption;
        if F_Etapa.CheckBox2.Checked = True then
          cp_motivo_atu:= cp_motivo_atu+' '+F_Etapa.CheckBox2.Caption;
        if F_Etapa.CheckBox3.Checked = True then
          cp_motivo_atu:= cp_motivo_atu+' '+F_Etapa.CheckBox3.Caption;
        if F_Etapa.CheckBox4.Checked = True then
          cp_motivo_atu:= cp_motivo_atu+' '+F_Etapa.CheckBox4.Caption;
        if F_Etapa.CheckBox5.Checked = True then
          cp_motivo_atu:= cp_motivo_atu+' '+F_Etapa.CheckBox5.Caption;
      end;
      F_Etapa.Free;{Liberar a memória RAM}
    end;
  end;

  pergunta := 0;
  while pergunta = 0 do begin {Referente ao Disposição da não conformidade}
    avisa_ok('Digite a Disposição da não conformidade!');
    Application.CreateForm(TF_Etapa, F_Etapa);  //Abrir form etapa mostrando o PanelDispoDaNaoConformidade
    try
      Application.CreateForm(TF_Etapa, F_Etapa);  //Abrir form etapa mostrando o panelIA
      F_Etapa.Height := 444;
      F_Etapa.Width := 315;
      F_Etapa.Left := 5;
      F_Etapa.Top := ((Screen.Height - F_Etapa.Height) div 2); //300;
      F_Etapa.PanelDispoDaNaoConformidade.Visible := true;
      F_Etapa.PanelDispoDaNaoConformidade.Top := 0;
      F_Etapa.PanelDispoDaNaoConformidade.Left := 0;
      F_Etapa.Edit4.Text := cp_qtd_op_ret;
      F_Etapa.Caption := 'Disposição da não Conformidade';
      F_Etapa.Showmodal;
    finally //Se os campos não estiverem cadastrados corretamente entrar na rotina a baixo
      if ((F_Etapa.CheckBox6.Checked = false) or (F_Etapa.CheckBox7.Checked = false)
         or (F_Etapa.CheckBox8.Checked = false) or (F_Etapa.CheckBox9.Checked = false)
         or (F_Etapa.CheckBox10.Checked = false) or (F_Etapa.CheckBox11.Checked = false)
         or (F_Etapa.CheckBox12.Checked = false) or (F_Etapa.CheckBox13.Checked = false)
         or (F_Etapa.CheckBox14.Checked = false) or (F_Etapa.CheckBox15.Checked = false)
         or (F_Etapa.CheckBox16.Checked = false) or (F_Etapa.CheckBox17.Checked = false)
         or (F_Etapa.CheckBox18.Checked = false)) and (F_Etapa.Edit4.Text = '0') then
      begin
        avisa_erro('Dados incompletos... preencha como requisitado!');
      end else pergunta:=2;
      if pergunta = 2 then begin
        disposicao := '';
        if F_Etapa.CheckBox6.Checked = true then disposicao := disposicao + F_Etapa.CheckBox6.Caption+' ';
        if F_Etapa.CheckBox7.Checked = true then disposicao := disposicao + F_Etapa.CheckBox7.Caption+' ';
        if F_Etapa.CheckBox8.Checked = true then disposicao := disposicao + F_Etapa.CheckBox8.Caption+' ';
        if F_Etapa.CheckBox9.Checked = true then disposicao := disposicao + F_Etapa.CheckBox9.Caption+' ';
        if F_Etapa.CheckBox10.Checked = true then disposicao := disposicao + F_Etapa.CheckBox10.Caption+' ';
        if F_Etapa.CheckBox11.Checked = true then disposicao := disposicao + F_Etapa.CheckBox11.Caption+' ';
        if F_Etapa.CheckBox12.Checked = true then disposicao := disposicao + F_Etapa.CheckBox12.Caption+' ';
        if F_Etapa.CheckBox13.Checked = true then disposicao := disposicao + F_Etapa.CheckBox13.Caption+' ';
        if F_Etapa.CheckBox14.Checked = true then disposicao := disposicao + F_Etapa.CheckBox14.Caption+' ';
        if F_Etapa.CheckBox15.Checked = true then disposicao := disposicao + F_Etapa.CheckBox15.Caption+' ';
        if F_Etapa.CheckBox16.Checked = true then disposicao := disposicao + F_Etapa.CheckBox16.Caption+' ';
        if F_Etapa.CheckBox17.Checked = true then disposicao := disposicao + F_Etapa.CheckBox17.Caption+' ';
        if F_Etapa.CheckBox18.Checked = true then  begin
          disposicao := disposicao + F_Etapa.CheckBox18.Caption+' ';
        end;
        cp_obs:= cp_obs + disposicao;
        DispoIA := cp_obs;
        cp_qtd_op_ret:= F_Etapa.Edit4.Text;
        qtdatu:= cp_qtd_op_ret;
        variaveis:= TStringList.Create;
        try
          variaveis.Add('ano='+cp_ano);
          variaveis.Add('data='+cp_data);
          variaveis.Add('hora='+cp_hora);
          variaveis.Add('ordprod='+cp_ordprod);
          variaveis.Add('codcli='+cp_codcli);
          variaveis.Add('item='+cp_item);
          variaveis.Add('opdetectora='+cp_opdetectora);
          variaveis.Add('operador='+cp_operador);
          variaveis.Add('qtd_op_atu='+cp_qtd_op_ret);
          variaveis.Add('motivo_atu='+cp_motivo_atu);
          variaveis.Add('disposicao='+disposicao);
          resp:= F_Principal.idhttp1.Post(WEBSERVICE+'retrabalho.php',variaveis);
          if resp='X' then showmessage('Houve erro na atualização do ctmed_nnc! Repita!');
        finally
          variaveis.Free;
        end;
      end;
      F_Etapa.Free;{Liberar a memória RAM}
    end;
  end;

end;

function TF_Medidas.plano_embalagem():boolean;
var resp:string;
begin  {rotina também usada para reimprimir etiqueta}
  planoemb:= '';
  avisa_ok(' Buscando o plano de embalagem... ');
  resp:= F_Principal.idhttp1.Get(WEBSERVICE+'select_planoemb.php?item='+item+'&operac='+lb_operacao.caption);
  if length(resp) <=1 then begin
      planoemb:= 'S/PLANO';
  end else begin
      planoemb := resp;
      planoemb := sem_acento(planoemb);
  end;
  lb_planoembalagem.Caption:= planoemb;{qualquer que seja carrega aqui.}
  Result:=true;
end;


function TF_Medidas.Imprimir():boolean;
var
  i,QtdEmb:integer;
  emb:real;
  cliente : string;
  Function centraliza(str:string):string;
  var tam, vazio : integer;
  begin
    str:= copy(str,1,22);
    tam:= length(str);
    vazio:= round((22-tam)/2);
    result:= StringOfChar(' ',vazio)+str;
  end;
begin
  Result:= false;
  pergunta:= 0; nome:= ''; status:= ''; retrabalho:= ''; ret:= 0; total:= 0;
  codint1 := ''; codint2 := ''; QtdPeca:='0';
  if (etapa <> 'F') then exit;  {só finalização imprime}
  //if (etapa = 'F') and (Fechar_retrabalho = 'N') then begin
  if etapa = 'F' then begin

    if (strtointdef(lb_retrabalho.Caption,0) > 0) then
      QtdPeca:= lb_retrabalho.Caption;
    if (strtointdef(lb_qtd_p_aprovar.Caption,0) > 0) then
      QtdPeca:= lb_qtd_p_aprovar.Caption;
    if (strtointdef(QtdPeca,0)=0) then begin
      ShowMessagePos('Quantidades para impressão nulas!',0,0);
      exit;
    end;
    if (StrToIntdef(lb_operacao.caption,0) = ultima_operacao) then  begin
      i:= 0;  {se ultima operação define quantidade de peças por embalagem}
      while i = 0 do begin
        QtdEmb := strtointdef(InputBox('Peças por embalagem',
                    'Digite a quantidade de peças por EMBALAGEM!',QtdPeca),0);
        if (QtdEmb = 0) then begin
          ShowMessagePos('O preenchimento da quantidade é obrigatório!',0,0);
          i:=0;
        end;
        {SE QTD ETIQUETA MAIOR QUE 5... PEDE CONFIRMAÇÃO.}
  			emb:= (strtointdef(QtdPeca,0)/QtdEmb);
        if ((emb - trunc(emb)) > 0) then
          total := (trunc(emb) + 1)
            else total := trunc(emb);
  			if (total > 5) then  begin
    			if mrNo=messagedlg('CONFIRMA a impressão de '+
             inttostr(total)+' ETIQUETAS?', mtconfirmation, [mbYes,mbNo], 0, mbYes)
               then i:=1;
        end else i:=1;
      end;
    end else total:=1;
  end else exit;{FIM IF ETAPA = F}
  //{SE RETRABALHO}
  //if APROVADO_REPROVADO='R' then begin QtdPeca:=qtdatu; lb_qtd_p_aprovar.caption:= QtdPeca; end;
  //if ((QtdPeca = '') or (QtdPeca='0')) then begin QtdPeca := 'S/Quant.'; total:=0; end
  //  else  total:= strtoint(lb_qtd_p_aprovar.caption);
  while total > 0 do begin
    desc_proxima_operacao := sem_acento(desc_proxima_operacao);
    nome := copy(lb_operador.caption,1,21);
      AssignFile(IMPRESSORA, '/dev/usb/lp0');
      Rewrite(IMPRESSORA);
    Writeln(Impressora,#27#87#1#27#67#10); //Velocidade baixa
    if IdIA <> '' then begin {Se algum controle estava Reprovado}
      if controles_reprovados = 'CTRL' then
        controles_reprovados := '';
      Writeln(Impressora,centro('REPROVADO'));
      Writeln(Impressora, centro(controles_reprovados)+#10);
      Writeln(impressora, 'OS:'+ trim(IdIA)+ #10);
      Writeln(Impressora,'Retrabalho:');
      DispoIA := stringreplace(DispoIA,'[',#10+'[',[rfreplaceAll]);
      Writeln(impressora,trim(DispoIA)+ #10);
    end
      else Writeln(Impressora,centro('APROVADO')+#10);
    cliente:= lb_Cliente.Caption;
    Writeln(Impressora, centro(cliente)+#10);
    Writeln(Impressora,'ITEM: '+copy(trim(item),1,18));
    Writeln(Impressora,copy(trim(lb_descr_item.caption),1,24));
    if (strtoint(QtdPeca) > QtdEmb)  then begin
      Writeln(impressora,'OP:'+trim(lb_OP.caption)+' Qtd. '+inttostr(QtdEmb));
      QtdPeca:= inttostr(strtoint(QtdPeca) - QtdEmb);
    end else Writeln(impressora,'OP:'+lb_OP.caption+' Qtd. '+QtdPeca);
     total:=total-1;

    Writeln(Impressora,'QTD. LOTE:'+lb_Qtd_Lote.Caption);
    Writeln(impressora,copy('PO:'+IntToStr(proxima_operacao)+'-'+trim(desc_proxima_operacao),1,24)+#10);
    Writeln(impressora,DateToStr(Now)+' - '+TimeToStr(Time));
    Writeln(impressora,copy(trim(sem_acento(lb_apontador.caption)),1,24));
    Writeln(impressora,copy(trim(lb_maquina.caption)+'-'+sem_acento(trim(lb_Operador.caption)),1,24));
    Writeln(Impressora,'Plano de Embalagem: ');
    Writeln(Impressora,copy(trim(planoemb),1,24));
    Writeln(Impressora,'........................'+#10#10#10#10#10#10#10#10#10);
    Writeln(Impressora,#27#87#0);
    CloseFile(Impressora);
  end;
  Result := true;
  erro_grave:=true;{para forçar o fechamento da unit medidas}
end;

procedure TF_Medidas.registra_pecas;
var
  resp, sql : string;
begin
    {soma o total de peças ate o momento com o total em lb_qtd_p_aprovar
    atribui valores de scr ret e qtdpecas e total em novo registro}
    if (strtointdef(lb_qtd_p_aprovar.Caption,0) > 0) or (Fechar_retrabalho = 'S') then begin
      //****Atualizar a tabela de ordem_producao
      resp:= F_Principal.idhttp1.Get(WEBSERVICE+'select_totalop.php?ordem='+lb_op.caption+'&operac='+lb_operacao.caption);
      if resp='X' then
        total:=strtoint(lb_qtd_p_aprovar.caption)
          else total:= strtoint(resp)+strtoint(lb_qtd_p_aprovar.caption);
       SQL:= ' insert into ordem_producao (op, operacao, qtd, qtd_total, '+
            'sucata, retrabalho, data, hora) values ('+
       quotedstr(lb_OP.Caption)+', '+
       quotedstr(lb_operacao.caption)+', '+
       quotedstr(lb_qtd_p_aprovar.caption)+', '+
       quotedstr(inttostr(total))+', '+
       quotedstr(lb_sucateadas.caption)+', '+
       quotedstr(lb_retrabalho.caption)+', '+
       quotedstr(mydata(datetostr(Date)))+', '+
       quotedstr(timetostr(Time))+')';
      sql:= TIdURI.URLEncode(WEBSERVICE+'inserts.php?sql='+sql);
      resp:= F_Principal.idhttp1.Get(sql);
      //****Fim da rotina Atualizar a tabela de ordem_producao
      if resp='X'  then showmessage('Houve erro na gravação da ordem_produção... Repita!');
    end;

end;

procedure TF_Medidas.ImpressaoAvulsa;
var
  resp: string;
  lista:TStringlist;
  Tab:TStringGrid;
  i,lin,col : integer;
  ct,fieldname,fieldvalue:string;

Function NovoInputBox(const TituloJanela: TCaption; const TituloLabel: TCaption; var S: String): string;
var
  Form: TForm;
  Edt: TEdit;
begin
  Result := '0';
  Form := TForm.Create(Application);
  try
    Form.BorderStyle := bsDialog;
    Form.Caption := TituloJanela;
    Form.Position := poScreenCenter;
    Form.Width := 350;
    //Form.Height := 120;
    Form.Height := 100+( Lista.Count * 16);//nro de linhas x 16pixels
    with TLabel.Create(Form) do
    begin
      Parent := Form;
      Caption := TituloLabel;
      Left := 10;
      Top := 10;
    end;
    Edt := TEdit.Create(Form);
    with Edt do
    begin
      Parent := Form;
      Left := 10;
      Top := Form.Height - 55;
      Width := 50;
    end;
    with TBitBtn.Create(Form) do
    begin
      Parent := Form;
      Left := trunc((Form.ClientWidth)/2)-100;
      Top := Form.Height - 55;
      Kind := bkOK;
    end;
    if Form.ShowModal = mrOK then
    begin
      Result := Edt.Text;
    end;

    finally
    Form.Free;
  end;
end;
begin
  Lista:= TStringList.Create;
  Tab:= TStringGrid.Create(Application);
  try
    memo1.Clear;
    memo1.Text:=
    F_Principal.idhttp1.Get(WEBSERVICE+'select_op_fechadas.php?ordem='+lb_op.caption+'&operac='+lb_operacao.caption);
    if memo1.Lines.Strings[0]='X' then begin
      avisa_erro('Atenção! Não encontrei finalizações para reimpressão!');
      exit;
    end;
    ct:= '';  i:= 0; lin:= 0; col:=0;
    ct:=copy(memo1.Text,i,1);
    while ct<>']' do begin
      if ct='{' then begin
        while ct<>'}' do begin
          i:=i+1;
          ct:=copy(memo1.Text,i,1);
          if ct='"' then begin
            i:=i+1;
            ct:=copy(memo1.Text,i,1);
            fieldname:='';
            while ct<>'"' do begin
              fieldname:= fieldname + ct;
              i:= i+1;
              ct:= copy(memo1.Text,i,1);
            end;// fim do while nome campo;
            i:=i+1;
            ct:= copy(memo1.Text,i,1);
            if ct=':' then
              if copy(memo1.Text,i+1,4)='null' then begin
                fieldvalue:= '';
                i:=i+5;
              end else begin
                i:=i+2;
                ct:= copy(memo1.Text,i,1);
                while ct<>'"' do begin
                  fieldvalue:= fieldvalue + ct;
                  i:= i+1;
                  ct:= copy(memo1.Text,i,1);
                end;//fim do while valor do campo;
              end;
            tab.Cells[col,lin]:= fieldvalue;
            col:=col+1;
            fieldvalue:='';
          end;// fim do if nome campo
               // volta para ler mais um
        end; //fim do while }
        lin:=lin+1;
        col:=0;
      end;
      i:=i+1;
      ct:=copy(memo1.Text,i,1);
    end;
    tab.rowcount:= lin;
    {select qtd,data,hora from ordem_producao}
    for i:=0 to tab.RowCount - 1 do {popular lista com a tabela de motivos para scrap}
      Lista.Add(inttostr(i+1)+' - Qtd: '+Tab.Cells[0,i]+' - '+tab.Cells[1,0]+' - '+tab.Cells[2,i]);

    avisa_ok(' Digite o numero correspondente a finalização para reimpressão!');
    resp:='0';
    resp:= Novoinputbox('REIMPRESSÃO-Digite 0 para cancelar!',
                        'Digite o número da finalização desejada!'+#13#10#13#10+
                          Lista.Text,resp);
  if ((resp='0') or (resp='')) then exit;
    Lista.Clear;
    total:= strtoint(tab.Cells[0,(strtoint(resp)-1)]);
    QtdPeca:='0'; {define quantas etiquetas imprimir }
    while ((QtdPeca='0') or (QtdPeca=''))  do  begin
        QtdPeca := Novoinputbox('Plano de embalagem','Digite a quantidade por EMBALAGEM!',QtdPeca);
        if (QtdPeca = '') or (QtdPeca = '0') then
          ShowMessagePos('O preenchimento da quantidade é obrigatório!',0,0);
    end;
    {SE QTD ETIQUETA MAIOR QUE 5... PEDE CONFIRMAÇÃO.}
    if (total/strtoint(QtdPeca))> 5 then
       if mrNo=messagedlg('CONFIRMA a impressão de '+
                        inttostr(round(total/strtoint(QtdPeca)))+
                        ' ETIQUETAS?', mtconfirmation, [mbYes,mbNo], 0, mbNo) then Exit;
    while total > 0  do begin
      if messagedlg('Imprime Etiqueta?',mtconfirmation,[mbYes,mbNo],0,mbYes)=mrNo then break;

      AssignFile(IMPRESSORA,'/dev/usb/lp0');
      Rewrite(IMPRESSORA);
      Writeln(Impressora,#27#87#1#27#67#10);
      Writeln(Impressora,centro('REIMPRESSAO')+#10);
      Writeln(Impressora,centro(lb_Cliente.caption)+#10);
      Writeln(Impressora,'ITEM: '+copy(trim(item),1,18));
      Writeln(Impressora,copy(trim(lb_descr_item.caption),1,24));

      if ( total >= strtoint(QtdPeca) ) then
        Writeln(impressora,'OP:'+lb_OP.caption+' QTD.:'+QtdPeca)
      else begin
        Writeln(impressora,'OP:'+lb_OP.caption+' QTD.:'+inttostr(total));
        total:=0;
      end;
      Writeln(Impressora,'PO:'+IntToStr(strtoint(lb_operacao.caption) + 1)+'-'+desc_proxima_operacao);
      Writeln(Impressora,#10+DateToStr(Now)+' - '+TimeToStr(Time));
      Writeln(Impressora,copy(sem_acento(trim(lb_apontador.caption)),1,24));
      Writeln(Impressora,copy(trim(lb_maquina.caption+'-'+sem_acento(lb_Operador.caption)),1,24));
      Writeln(Impressora,'Plano Embalagem:');
      Writeln(Impressora,copy(trim(planoemb),1,24));
      Writeln(Impressora,'........................'+#10#10#10#10#10#10#10#10#10);
      Writeln(Impressora,#27#87#0);
      CloseFile(Impressora);
      {imprime etiqueta até plano emb. acabar com a quantidade produzida}
      if ( total >= strtoint(QtdPeca) ) then total:= total - strtoint(QtdPeca);
    end;
  finally
    lista.Free;
    tab.Free;
  end;
end;

function TF_Medidas.registra_medidas():boolean;
var {variaveis para os campos...facilitar o entendimento}
  cp_operador, cp_codprod, cp_data, cp_hora, cp_etapa, cp_item, cp_operac,
  cp_nroctrl, cp_status, cp_cotamed, cp_superv, cp_obs, cp_crm,
  cp_produtor,resp : string;
  sql:widestring;
begin
  result:= false;
  if Apv = 0 then exit; {não apontou qualidade... erro de senhas}
  {atribui dados para as variaveis de campos do registro}
  cp_operador:= lb_apontador.caption;
  cp_codprod := lb_OP.caption;
  cp_data := mydata(datetostr(date()));
  cp_hora := timetostr(time());
  cp_etapa := etapa;
  cp_item := lb_Item.caption;
  cp_operac := lb_operacao.Caption;
  cp_nroctrl := Label24.caption;
  cp_status := APROVADO_REPROVADO;
  cp_produtor := lb_operador.caption;
  {se Aprov edit_ler se por supervisor edit_min}
  Case Apv of
  1: {aprovou visual direto sem chamar Lider}
    begin
      cp_cotamed:= '';
      cp_superv:= '';
      cp_obs:= 'VISUAL';
    end;
  2: {reprovou visual depois de chamar supervisor}
    begin
      cp_cotamed:= '';
      cp_superv:= Supervisor;
      cp_obs:= 'VISUAL';
    end;
  3: {aprovou visual depois de chamar supervisor}
    begin
      cp_cotamed:= '';
      cp_superv:= Supervisor;
      cp_obs:= 'VISUAL';
    end;
  4: {aprovou medição depois de chamar supervisor}
    begin
      cp_cotamed:= Edit_Ler.text;
      cp_crm:= Edit_Ler.Text;
      cp_superv:= Supervisor;
      cp_obs:='[ '+Edit_Min.text+' / '+Edit_Max.text+' ]';
    end;
  5:
    begin
      cp_cotamed:= Edit_Ler.text;
      cp_crm:= Edit_Ler.Text;
      cp_superv:= Supervisor;
      cp_obs:='[ '+Edit_Min.text+' / '+Edit_Max.text+' ]';
    end;
  6:
    begin
      cp_cotamed:= Edit_Min.text;
      cp_crm:= crm;
      cp_superv:= Supervisor;
      cp_obs:= med + ' [ '+Edit_Min.text+' / '+Edit_Max.text+' ]';
    end;
  end;
  //Grava dados na tabela record
  if (Formula = 'FORMULACB') and (strtoint(NroCmed) < 3) then begin
    Ponteiro := New( PtrPessoa );
    Ponteiro^.controle := strtoint(cp_nroctrl);
    if strtoint(cp_NroCtrl) = 1 then
      Ponteiro^.cota := strtofloat(cp_crm) / 2
        else Ponteiro^.cota := strtofloat(cp_crm);
    IntToStr( tabela.Add( Ponteiro ) );
  end;
  if (Formula = 'FORMULAEC') and (strtoint(cp_nroctrl) < 4) then begin
    Ponteiro := New( PtrPessoa );
    Ponteiro^.controle := strtoint(cp_nroctrl);
    if strtoint(cp_nroctrl) = 1 then
      Ponteiro^.cota := strtofloat(cp_crm) / 2;
    if strtoint(cp_nroctrl) = 2 then
      Ponteiro^.cota := strtofloat(cp_crm) / 2;
    if strtoint(cp_nroctrl) = 3 then
      Ponteiro^.cota := strtofloat(cp_crm);
    IntToStr( tabela.Add( Ponteiro ) );
  end;
  // atribuir variaveis dos campos ao registro.
  hora_termino:= now();
  tempo_decorrido:= hora_termino - hora_inicio;

  SQL:=  'insert into ctmed_reg (operador,codprod,data,hora,etapa,item,operac,nroctrl,'+
         'status,cotamed,superv,obs,crm,produtor,decorrido) values ('+
         Quotedstr(cp_operador)+', '+
         Quotedstr(cp_codprod)+', '+
         Quotedstr(cp_data)+', '+
         Quotedstr(cp_hora)+', '+
         Quotedstr(cp_etapa)+', '+
         Quotedstr(cp_item)+', '+
         Quotedstr(cp_operac)+', '+
         Quotedstr(cp_nroctrl)+', '+
         Quotedstr(cp_status)+', '+
         Quotedstr(cp_cotamed)+', '+
         Quotedstr(cp_superv)+', '+
         Quotedstr(cp_obs)+', '+
         Quotedstr(cp_crm)+', '+
         Quotedstr(cp_produtor)+', '+
         Quotedstr(timetostr(tempo_decorrido))+')';
  memo1.Clear;
  sql:=TIdURI.URLEncode(WEBSERVICE+'inserts.php?sql='+sql);
  resp:= F_Principal.idhttp1.Get(SQL);
  if resp = 'X' then showmessage('Atenção, erro ao gravar o registro de medidas!!!');
  //showmessage('');
  sleep(100);
  Supervisor:= '';
  result:= true;
end;

procedure pede_senha;
begin
  Application.CreateForm(TF_Etapa, F_Etapa);
  try
    F_Etapa.Height:= 148;
    F_Etapa.Width:= 238;
    F_Etapa.PanelPedSenha.Top:= 0;
    F_Etapa.PanelPedSenha.Left:= 0;
    F_Etapa.Left:= 75;
    F_Etapa.Top:= F_Medidas.panel2.top;
    F_Etapa.PanelPedSenha.Visible := true;
    F_Etapa.Edit2.Clear;
    F_Etapa.Edit2.text := '';
    F_Etapa.Caption := ' QUALIDADE ';
    F_Etapa.Showmodal;
  finally
    F_Etapa.Free;
  end;
end;

function TF_Medidas.inicia_medidas():boolean;
var
  i,j,lin,col : integer;
  Controles:Tstringgrid;
  ct,fieldname,fieldvalue:string;
  Hwd:THandle;
  Arq_email: TextFile;
begin
  result := false;
  erro_grave:=false;
  controles_reprovados:='CTRL ';
  Apv:=0;
  APROVADO_REPROVADO:= 'R';
  TipoMed := '';
  Controles:= TStringGrid.Create(Application);
  try
    memo1.Clear;
    memo1.Text := F_Principal.idhttp1.Get(WEBSERVICE+'select_medidas.php?item='+
                    lb_Item.Caption+'&operac='+lb_operacao.caption);
    controles.FixedCols:=0;
    controles.FixedRows:=0;
    if length(memo1.Lines.Strings[0]) <= 1 then exit;
    {destrincha o json e monta o stringgrid}
    ct:='';  i:=0; lin:=0; col:=0;
    ct:=copy(memo1.Text,i,1);
    while ct<>']' do begin
      if ct='{' then begin
        while ct<>'}' do begin
          i:=i+1;
          ct:=copy(memo1.Text,i,1);
          if ct='"' then begin
            i:=i+1;
            ct:=copy(memo1.Text,i,1);
            fieldname:='';
            while ct<>'"' do begin
              fieldname:= fieldname + ct;
              i:= i+1;
              ct:= copy(memo1.Text,i,1);
            end;
            i:=i+1;
            ct:= copy(memo1.Text,i,1);
            if ct=':' then
              if copy(memo1.Text,i+1,4)='null' then begin
                fieldvalue:= '';
                i:=i+5;
              end else begin
                i:=i+2;
                ct:= copy(memo1.Text,i,1);
                while ct<>'"' do begin
                  fieldvalue:= fieldvalue + ct;
                  i:= i+1;
                  ct:= copy(memo1.Text,i,1);
                end;
              end;
            Controles.Cells[col,lin]:= fieldvalue;
            col:=col+1;
            fieldvalue:='';
          end;
        end;
        lin:=lin+1;
        col:=0;
      end;
      i:=i+1;
      ct:=copy(memo1.Text,i,1);
    end;
    controles.rowcount:= lin;
    {lembrar que j=0 não tem... teria os nomes dos campos.Então total está acrescido de 1}
    for j:=0 to (controles.RowCount-1) do begin
      rMax:=0; rMin:=0; rLido:=0; sPrgVisual:='';
      // para cada controle da operação do item faz...
      tm_descarte.enabled:= false;
      tm_descarte.Enabled:= true;
      NroCmed:= IntToStr(j+1);
      Panel_cota.Visible:= false;
      Label24.Caption:= NroCmed;
      Label2.caption:= controles.Cells[8,j];
      lb_metodo.Caption:=controles.Cells[17,j];
      if controles.Cells[11,j] = '' then begin
        {se existe uma cota alternativa por parte da cb ela será usada}
        Edit_Min.Text:= controles.Cells[9,j];
        Edit_Max.Text:= controles.Cells[10,j];
      end else begin
        Edit_Min.Text:= controles.Cells[11,j];
        Edit_Max.Text:= controles.Cells[12,j];
      end;

      if controles.Cells[13,j] <> '' then begin
        rErro := strtoreal(controles.Cells[13,j]);
      end else rErro:= 0;

      lb_equipo_aval.Caption:=controles.Cells[14,j];
      lb_amostras.Caption:= controles.Cells[15,j];
      lb_frequencia.Caption:= controles.Cells[16,j];
      lb_plano_reacao.caption:= controles.Cells[18,j];
      ajusta_label(true); {torna visiveis os captions acima}
//****** AVISO - ALERTA DA QUALIDADE *** não reprova ou retrabalha.
      if (copy(lb_equipo_aval.caption,1,6)='ALERTA') then begin
        BuscaFoto(NroCmed);
        ShowMessagePos('          ATENÇÃO!!!           '+#13+
                       ' O Alerta de Qualidade deve estar '+#13+
                       ' disponível no posto de Trabalho!! ',0,0);
        continue;
      end;
//****** AVISO - FOLHA DE PROCESSO ***
      if (copy(lb_equipo_aval.caption,1,8)='PROCESSO') then begin
        BuscaFoto(NroCmed);
        ShowMessagePos('          ATENÇÃO!!!           '+#13+
                    ' A FOLHA DE PROCESSO deve estar '+#13+
                    ' disponível no posto de Trabalho!! ',0,0);
        continue;
      end;
//****** INSPEÇÃO VISUAL *** ROTINAS QUE REPROVAM PARA RETRABALHO.
      if (lb_equipo_aval.caption = 'VISUAL') or
         (lb_equipo_aval.caption = 'Visual') or
         (lb_equipo_aval.caption = 'visual') then begin

        Apv:=0;
        BuscaFoto(NroCmed);
        lb_metodo.caption:='VISUAL';
        {se campo com pergunta em branco avisar daniel mira e renato}
        {pergunta se ISENTA DE REBARBAS ETC SE SIM OK SE NAÕ CHAMA SUPERVISOR}
        sPrgVisual:=controles.Cells[19,j];
        if sPrgVisual='' then sPrgVisual:='PERGUNTA NÃO CADADASTRADA PELA QUALIDADE!!';
        if ( MessageDlgPos(sPrgVisual, MtConfirmation,mbYesNo,0,0,0) = mrYes ) then begin
        {aprovado}
          APROVADO_REPROVADO:='A';  Apv:=1;
          if not registra_medidas() then break;
          senhaOk:=true;
        end else begin
        {reprovado}
          if ChamaLider() then begin
            if (Apv=2) then begin{Lider reprovou}
              controles_reprovados:=controles_reprovados + '-'+ IntToStr(j+1);
              lb_retrabalho.caption:= lb_qtd_p_aprovar.caption;
              lb_qtd_p_aprovar.caption:='0';
              senhaOk:=true; // ao entrar em formetapa muda pra false.
            end;
          end else begin  {senha errada... cancela tudo.}
          	erro_grave:= true;
            Break;
          end;
        end;
        continue;
      end;

//****** Início da rotina CALIBRADOR ***
      if (copy(lb_equipo_aval.caption,1,10)='CALIBRADOR') then  begin
        TipoMed := 'CALIBRADOR';
        BuscaFoto(NroCmed);
        lb_metodo.caption:='USAR CALIBRADOR';
        if (MessageDlgPos('O CALIBRADOR ATRAVESSOU COMPLETAMENTE ?', MtConfirmation,mbYesNo,0,0,0)= mrYes) then begin
        {aprovado}
          APROVADO_REPROVADO:='A';  Apv:=1;
          TipoMed := '';
          if not registra_medidas() then break;
        end else begin
        {reprovado}
          if ChamaLider() then begin
            if (Apv=2) then begin
              controles_reprovados:=controles_reprovados + '-'+ IntToStr(j+1);
              lb_retrabalho.caption:= lb_qtd_p_aprovar.caption;
              lb_qtd_p_aprovar.caption:='0';
              senhaOk:=true; // ao entrar em formetapa muda pra false.
            end;
          end else begin // registra como visual aprovado.
           	erro_grave:= true;
            Break;
          end;
        end;
        continue;
      end;

//****** Início da rotina DISPOSITIVO ***
      if (copy(lb_equipo_aval.caption,1,10)='DISPOSITIV') then begin
        BuscaFoto(NroCmed);
        lb_metodo.caption:='USAR DISPOSITIVO';
        if (MessageDlgPos('A Peça se adaptou ao dispositivo de controle?',
          MtConfirmation, mbYesNo,0,0,0) = mrYes ) then begin
        {aprovado}
          APROVADO_REPROVADO:='A'; Apv:=1;
          if not registra_medidas then break;
        end else begin
          {reprovado}
          if ChamaLider() then begin
            if (Apv=2) then begin
              controles_reprovados:=controles_reprovados + '-'+ IntToStr(j+1);
              lb_retrabalho.caption:= lb_qtd_p_aprovar.caption;
              lb_qtd_p_aprovar.caption:='0';
              senhaOk:=true; // ao entrar em formetapa muda pra false.
            end;
          end else begin // registra como visual aprovado.
            erro_grave:= true;
            Break;
          end;
        end;
        continue;{não foi abortado antes. Logo: tudo ok! continua a medir!}
      end;

//****** Início da rotina TODOS OUTROS procedimentos

      BuscaFoto(NroCmed);
      //*** primeiro algoritimo de calculo de cotas automatico
      if (copy(lb_equipo_aval.caption,1,9)='FORMULACB') then begin
        Lido := mrOk;
        Edit_ler.text := FloatToStr(FormulaCB('0'));
      end;

      //*** segundo algoritimo de calculo de cotas automatico
      if (copy(lb_equipo_aval.caption,1,9)='FORMULAEC') then  begin
        Lido := mrOk;
        Edit_ler.text := FloatToStr(FormulaEC('0'));
      end;
      if (copy(lb_equipo_aval.caption,1,9) <> 'FORMULACB') and
         (copy(lb_equipo_aval.caption,1,9)<>'FORMULAEC') then
           lermedida;

      if Lido = mrOk then
      begin
        rLido:= StrToReal(Edit_ler.text);
        rMin:=strtoreal(Edit_Min.text);
        rMax:=strtoreal(Edit_Max.text);
      end else begin
        Apv:=0; APROVADO_REPROVADO:='R';
        erro_grave:=true;
        break;
      end;

      if (rLido >= 0) and ((rLido > (rMax + rErro)) or (rLido < (rMin - rErro))) then begin
        //*********REPROVADO 1.A VEZ ****************
        //ShowMessagePos('Atenção! Repita a medição!',0 0);
        avisa_erro('       ATENÇÃO!         '+
                   ' Verificar se o INSTRUMENTO de medição está correto e '+
                   '  Repetir a medição!   ');
        sleep(1000);
        rLido:=0;
        rMin:=0;
        rMax:=0;
        lermedida;
        if Lido = mrOk then  begin
          rLido:= StrToReal(Edit_ler.text);
          rMin:=strtoreal(Edit_Min.text);
          rMax:=strtoreal(Edit_Max.text);
        end else begin
          Apv:=0; APROVADO_REPROVADO:='R'; break;
        end;
      end;

      if (rLido >= 0) and ((rLido > (rMax + rErro)) or (rLido < (rMin - rErro))) then  begin
        //**************   REPROVADO 2.A VEZ   *********************
        avisa_erro('COTA REPROVADA!... Chame um inspetor para liberar esta peça!');
        sleep(500);
        rCotRep := rLido;
        pede_senha;
        if SenhaOk then begin
         panel_cota.Visible:=true;
         panel_ler.Visible:=true;
         erro_grave:=false;
        end else  begin
          ShowMessagePos(' Atenção o registro foi descartado! A senha estava inválida ou foi cancelada!',0,0);
          erro_grave:=true;
          break;
        end;
				(*
				Case MessageDlgPos('Foi evidenciado a Não Conformidade?',mtconfirmation,[mbYes,mbNo],0,0,0,mbCancel) of
        mrCancel:
          begin
            ShowMessagePos(' Apontamento descartado! '+#13+'   Reinicie a operação!',0,0);
            Apv:=0;
            APROVADO_REPROVADO:= 'R';
            controles_reprovados:=controles_reprovados + '-'+ IntToStr(j+1);
            senhaOK:=false;{para sair sem registrar nada e fechar}
            break;
          end;
        mrYes :
          begin //Gerar numero de Instrução de Acabamento e imprimir etiquetas
            GeraIA;
            ShowMessagePos(' 1 - Identificar o Material!!!'+#13+' 2 - Enviar para o retrabalho!',0,0);
            Apv:=5;
            APROVADO_REPROVADO:= 'R';
            controles_reprovados:=controles_reprovados + '-'+ IntToStr(j+1);
            if not registra_medidas then exit;// procede registro da inspeção como rejeitado
            senhaOk:=true; // para registrar e só depois fechar.
          end;
        mrNo :
          begin
            crm:= Edit_Ler.Text;
            lermedida;
            med:= edit_ler.Text;
            Apv:=6;  APROVADO_REPROVADO:='A';
            if not registra_medidas then exit;
            avisa_ok(' APROVADO! Proceda Conforme Orientação da Figura! ');
          end;
        end; // end do case
				*)
        if messagedlgpos('Foi evidenciado a Não Conformidade?',mtconfirmation,
        									[mbYes,mbNo],0,0,0,mbYes)=mrNo then
        begin
          //abre_plano_acao;
          crm:= Edit_Ler.Text;
          lermedida;
          med:= edit_ler.Text;
          rCotLider:= StrToReal(edit_ler.Text);
          abre_plano_acao;
          Apv:=6;  APROVADO_REPROVADO:='A';
          if not registra_medidas then exit;
          avisa_ok(' APROVADO! Proceda Conforme Orientação da Figura! ');
        end else begin
          lb_retrabalho.caption:= lb_qtd_p_aprovar.caption;
          lb_qtd_p_aprovar.caption:='0';
          GeraIA;  // gera a instrução de acabamento...
          ShowMessagePos(' 1 - Identificar o Material!!!'+#13+' 2 - Enviar para o retrabalho!',0,0);
          Apv:=5;
          APROVADO_REPROVADO:= 'R';
          controles_reprovados:=controles_reprovados + '-'+ IntToStr(j+1);
          if not registra_medidas then exit;// procede registro da inspeção como rejeitado
          senhaOk:=true; // para registrar e só depois fechar.
          if messagedlgpos('Deseja abrir uma Ordem de Manutenção de Ferramental?',mtconfirmation,[mbYes,mbNo],0,0,0,mbYes)=mrYes then
          begin
            sOmf := 'S';
            abre_plano_acao;
          end;
        end;
        Panel_cota.Visible:= false;
      end else begin // se aprovado a cota digitada pelo lider...
        avisa_ok(' APROVADO!  Proceda Conforme Orientação da Figura! ');
        //********************VERIFICA SE PUNÇÃO PRECISA REPARO.
        if label2.caption ='DIAMETRO' then begin
          if rlido < (rmin+((rMax-rmin)*0.2)) then
          begin
              // grava arquivo vbs no disco e executa o vbs direto... lembrar de instalar o IIS na maq em questão.
            F_Medidas.avisa_ok('Aguarde envio do e-mail aos responsáveis...');
            AssignFile(Arq_email, 'emailpa.vbs');
            Rewrite(Arq_email);
            WriteLn(Arq_email,'Const cdoBasic = 1' );
            WriteLn(Arq_email,'Const cdoNTLM = 2');
            WriteLn(Arq_email,'Const cdoSendUsingPickup = 1');
            WriteLn(Arq_email,'Const cdoSendUsingPort = 2');
            WriteLn(Arq_email,'Const cdoDSNDefault = 0');
            WriteLn(Arq_email,'Const cdoDSNNever = 1');
            WriteLn(Arq_email,'Const cdoDSNFailure = 2');
            WriteLn(Arq_email,'Const cdoDSNSuccess = 4');
            WriteLn(Arq_email,'Const cdoDSNDelay = 8');
            WriteLn(Arq_email,'Const cdoDSNSuccessFailOrDelay = 14');
            WriteLn(Arq_email,'Dim strMsg');
            WriteLn(Arq_email,'Dim strAssunto');
            WriteLn(Arq_email,'set objMsg = CreateObject("CDO.Message")');
            WriteLn(Arq_email,'set objConf = CreateObject("CDO.Configuration")');
            WriteLn(Arq_email,'Set objFlds = objConf.Fields');
            WriteLn(Arq_email,'With objFlds');
            WriteLn(Arq_email,'  .Item("http://schemas.microsoft.com/cdo/configuration/sendusing") = cdoSendUsingPort');
            WriteLn(Arq_email,'  .Item("http://schemas.microsoft.com/cdo/configuration/smtpserver") = "smtp.terra.com.br"');
            WriteLn(Arq_email,'  .Item("http://schemas.microsoft.com/cdo/configuration/smtpauthenticate") = cdoBasic');
            WriteLn(Arq_email,'  .Item("http://schemas.microsoft.com/cdo/configuration/sendusername") = "sergio.silvestre@cbind.com.br"');
            WriteLn(Arq_email,'  .Item("http://schemas.microsoft.com/cdo/configuration/sendpassword") = "cb147258"');
            WriteLn(Arq_email,'  .Update');
            WriteLn(Arq_email,'End With');
            WriteLn(Arq_email,'strAssunto = "Punção desgastado Item: '+F_Medidas.lb_Item.caption+'"');
            WriteLn(Arq_email,'strMsg = " SR. Responsável" & vbCRLF & vbCRLF & "'+
                              'VERIFICAR: " & vbCRLF & "Item/OP: '+F_Medidas.lb_Item.caption+' / '+
                              F_Medidas.lb_OP.caption+'" & vbCRLF & "Operação: '+
                              F_medidas.lb_Operacao.caption+'" & vbCRLF & "Nro. Controle de medidas: '+
                              F_Medidas.label24.caption+'" & vbCRLF & "'+
                              '  Verifique a necessidade de reparo do punção no ferramental deste item/operação.'+
                              '" & vbCRLF & " Cota Mínima: ( '+Edit_Min.text+
                              ')" & vbCRLF & " Cota Máxima: ( '+Edit_Max.Text+
                              ')" & vbCRLF & " Cota Encontrada: ('+Edit_Ler.text+
                              ')" & vbCRLF & "   Grato."');
            WriteLn(Arq_email,' ');
            WriteLn(Arq_email,'With objMsg');
            WriteLn(Arq_email,'  Set .Configuration = objConf');
            WriteLn(Arq_email,'  .To = "qualidade@cbind.com.br"');
            WriteLn(Arq_email,'  .From = "sergio.silvestre@cbind.com.br"');
            WriteLn(Arq_email,'  .Subject = strAssunto');
            WriteLn(Arq_email,'  .TextBody = strMsg ');
            WriteLn(Arq_email,'  .DSNOptions = cdoDSNSuccessFailOrDelay');
            WriteLn(Arq_email,'  .Fields.update');
            WriteLn(Arq_email,'  .Send');
            WriteLn(Arq_email,'End With');
            CloseFile(Arq_email);
            ShellExecute(Hwd, 'open', 'emailpa.vbs',nil,nil,SW_HIDE);
          end;
        end;
        Apv:=4; APROVADO_REPROVADO:='A';
        if not registra_medidas then break;
        Edit_Ler.text:='';
      end;
    end; //Fim do for
  finally
    Controles.free;
  end;
  if (erro_grave=true) then
  begin {é preciso forçar a saida}
    result:=false;
    exit;
  end;
  //if (APROVADO_REPROVADO='A') and (etapa='F') then begin
  if (etapa<>'L') then begin
    senhaOk:=true;
    registra_pecas;
  end;
  ajusta_label(false);{esconde os captions do form}
  if (senhaOK=false) then
    exit
      else result := true;{se houve erro ao pedir senha supervisor e break}
end;

procedure TF_Medidas.envia_mensagem(de,para,mensagem:widestring);
var
  resp:string;
  variaveis : TStringList;
begin {procedure para enviar mensagens para cbindw}
  variaveis:= TStringList.Create;
  variaveis.Clear;
  resp:='S';
  try
    variaveis.Add('de='+de);
    variaveis.Add('para='+para);
    variaveis.Add('msg='+mensagem);
    resp:= F_Principal.idhttp1.Post(WEBSERVICE+'insert_mensagem.php',variaveis);
    //?de='+de+'&para='+para+'&msg='+mensagem);
  finally
    if resp='X'  then
      showmessage('mensagem não enviada!');
    variaveis.Free;
  end;
end;

function TF_Medidas.completa_dados():boolean;
var resp:string;
begin   {se tudo ok começa buscar dados...}
  avisa_ok(' Aguarde... buscando o nome reduzido do CLIENTE...');
  resp:= F_Principal.idhttp1.Get(WEBSERVICE+'select_nominho.php?codcli='+inttostr(codcli));
  if length(resp)>1 then lb_Cliente.Caption:= sem_acento(resp)
    else  begin
      ShowMessagePos(' Atenção!!'+#13+
                  ' Não existe um nome REDUZIDO para o Cliente...'+#13+
                  ' Informe o PCP!',0,0);
                  // exit; {apenas avisar se der exit trava muito a produç~çao}
                  lb_cliente.Caption:='AUSENTE';
  end;
  avisa_ok(' Aguarde... buscando a descrição do ITEM...');
  resp:='';
  resp:= F_Principal.idhttp1.Get(WEBSERVICE+'select_descricao_item.php?item='+item);
  if length(resp) > 1 then
    lb_descr_item.Caption:= resp
      else lb_descr_item.Caption:= 'SEM CADASTRO';
  {ATRIBUI NOME DO OPERADOR E MAQUINA DO PROCESSO}
  avisa_ok(' Aguarde... buscando a máquina onde a OP está sendo processada...');
  Pesquisa.Clear;
  Pesquisa.Text:= stringreplace(F_Principal.idhttp1.Get(WEBSERVICE+
     'select_maq_oper.php?ordem='+lb_op.caption+'&operac='+lb_operacao.caption),'&',#13#10,[rfreplaceAll]); //se_operacao_existe
  if length(Pesquisa.Strings[0])<=1 then begin
    lb_Operador.caption:= 'AUSENTE';
    lb_Maquina.caption:='000000';
  end else begin
    lb_Operador.caption:= Pesquisa.Strings[1];
    lb_Maquina.caption:=Pesquisa.Strings[0];
  end;
  result:= true;
end;


procedure TF_Medidas.encerramento;
begin
  ed_Entra_Dados.Visible:= false;
  erro_grave:=true;
  if not plano_embalagem then exit;
  avisa_ok(' Aguarde! Concluindo informações... ');

  {se etiqueta avulsa... imprime e ...sai.}
  {VERIFICAR ETIQUETA AVULSA É SÓ PARA REIMPRESSÃO DE LOTES JÁ FECHADOS...
  NÃO PERMITIR QUANTIDADES DIFERENTES DAQUELAS JÁ APROVADAS.
  INSERIR NOVAS QUANTIDADES TEM QUE FAZER NOVA FINALIZAÇÃO.}
  (*
  if (EtiqAvulsa = 1) then begin
    avisa_ok(' Aguarde! Abrindo para impressão avulsa... ');
    ImpressaoAvulsa;
    exit;
  end;
  *)
  avisa_ok(' Proceda Conforme Orientação da Figura! ');
  if not inicia_medidas() then begin erro_grave:=true;	exit; end;
  avisa_ok(' Aguarde! Abrindo para impressão do Ticket... ');
  if (etapa = 'F' ) then {IMPRIME SE FINALIZADO OU SE REPROVADO}
    if not imprimir() then begin erro_grave:=true;	exit; end;
  avisa_ok(' Parabens! Você concluiu o processo do CONTROLE DE MEDIDAS! ');
  sleep(2000);
  erro_grave:= true;{força a sair após conclusão}

end;


end.
