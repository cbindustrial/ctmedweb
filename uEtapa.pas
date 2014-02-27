unit uEtapa;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls, pngimage, ExtCtrls, Grids;

type
  TF_Etapa = class(TForm)
    PanelEtapa: TPanel;
    Image2: TImage;
    Label25: TLabel;
    Label26: TLabel;
    Label27: TLabel;
    Label28: TLabel;
    Label29: TLabel;
    Label30: TLabel;
    Label31: TLabel;
    PanelLer: TPanel;
    Label1: TLabel;
    Edit1: TEdit;
    Panel1: TPanel;
    Label3: TLabel;
    PanelPedSenha: TPanel;
    GroupBox1: TGroupBox;
    Label2: TLabel;
    Image1: TImage;
    Cancelar: TButton;
    Continuar: TButton;
    Edit2: TEdit;
    PanelMsg: TPanel;
    LbMsg: TLabel;
    Bbt1: TBitBtn;
    Bbt2: TBitBtn;
    Bbt3: TBitBtn;
    PanelIA: TPanel;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    CheckBox4: TCheckBox;
    CheckBox5: TCheckBox;
    Label4: TLabel;
    Label5: TLabel;
    BitBtn2: TBitBtn;
    BitBtn1: TBitBtn;
    Edit3: TEdit;
    PanelDispoDaNaoConformidade: TPanel;
    Label6: TLabel;
    Label7: TLabel;
    Edit4: TEdit;
    BitBtn3: TBitBtn;
    BitBtn4: TBitBtn;
    GroupBox2: TGroupBox;
    CheckBox6: TCheckBox;
    CheckBox7: TCheckBox;
    CheckBox8: TCheckBox;
    CheckBox9: TCheckBox;
    Label9: TLabel;
    GroupBox3: TGroupBox;
    CheckBox11: TCheckBox;
    GroupBox4: TGroupBox;
    CheckBox10: TCheckBox;
    CheckBox12: TCheckBox;
    CheckBox13: TCheckBox;
    CheckBox14: TCheckBox;
    GroupBox5: TGroupBox;
    CheckBox15: TCheckBox;
    CheckBox16: TCheckBox;
    GroupBox6: TGroupBox;
    CheckBox17: TCheckBox;
    CheckBox18: TCheckBox;
    PanelFechaRetrabalho: TPanel;
    EdtOperador: TEdit;
    Label22: TLabel;
    EdtResponsavel: TEdit;
    Label23: TLabel;
    Label13: TLabel;
    EdtCodigo: TEdit;
    Label14: TLabel;
    EdtData: TEdit;
    Label15: TLabel;
    EdtHora: TEdit;
    Label16: TLabel;
    EdtOP: TEdit;
    Label17: TLabel;
    EdtOpAtu: TEdit;
    Label19: TLabel;
    EdtItem: TEdit;
    Label20: TLabel;
    EdtMotivoOpAtu: TEdit;
    Panel4: TPanel;
    Panel5: TPanel;
    EdtQtdOpAtu: TEdit;
    Label8: TLabel;
    EdtPcMorta: TEdit;
    Label10: TLabel;
    Label18: TLabel;
    Label11: TLabel;
    BitBtn5: TBitBtn;
    BitBtn6: TBitBtn;
    CheckBox19: TCheckBox;
    CheckBox20: TCheckBox;
    CheckBox21: TCheckBox;
    PanelFechaOP: TPanel;
    EditData: TEdit;
    EditOperador: TEdit;
    EditEquipamento: TEdit;
    EditQtdProd: TEdit;
    EditScrap: TEdit;
    EditTotal: TEdit;
    Panel6: TPanel;
    Panel7: TPanel;
    Panel8: TPanel;
    Panel9: TPanel;
    Panel10: TPanel;
    Panel11: TPanel;
    Panel3: TPanel;
    BitBtn7: TBitBtn;
    BitBtn8: TBitBtn;
    Paneloperacao: TPanel;
    Panel2: TPanel;
    Label12: TLabel;
    tm_descarta_etapa: TTimer;
    lsItem: TListBox;
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure CancelarClick(Sender: TObject);
    procedure ContinuarClick(Sender: TObject);
    Function senha(mCad : String):string;
    procedure FormShow(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure Edit1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure EditQtdProdExit(Sender: TObject);
    procedure EditEquipamentoKeyPress(Sender: TObject; var Key: Char);
    procedure EdtQtdOpAtuKeyPress(Sender: TObject; var Key: Char);
    procedure EdtPcMortaExit(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure BitBtn8Click(Sender: TObject);
    procedure tm_descarta_etapaTimer(Sender: TObject);
    procedure lsItemDblClick(Sender: TObject);
    procedure lsItemKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure Edit2KeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  F_Etapa: TF_Etapa;
  pegatecla : string;
implementation

uses Umedidas, UPrincipal, uvariaveis ;

{$R *.DFM}

function TF_Etapa.senha(mCad : String):string;
var
  v1,v2,v3,v4: Integer;
  t1,t2,t3,t4: Integer;
begin
  v1 := Ord(mCad[1]); v2 := Ord(mCad[2]); v3 := Ord(mCad[3]);
  v4 := Ord(mCad[4]);
  t1 := ((v1*1 + v2*2 + v4*3+ v3*6) mod 223) + 32;
  t2 := ((v1*2 + v2*5 + v4*1+ v3*5) mod 223) + 32;
  t3 := ((v1*6 + v2*3 + v4*7+ v3*2) mod 223) + 32;
  t4 := ((v1*2 + v2*5 + v4*1+ v3*7) mod 223) + 32;
  result := chr(t1) + chr(t2) + chr(t4) + chr(t3);
end;

procedure TF_Etapa.tm_descarta_etapaTimer(Sender: TObject);
begin
  F_Etapa.close;
end;

procedure TF_Etapa.BitBtn1Click(Sender: TObject);
begin
  PanelIA.Visible := False;
  F_Etapa.Close;
end;

procedure TF_Etapa.BitBtn2Click(Sender: TObject);
begin
  PanelIA.Visible := False;
  F_Etapa.Close;
end;

procedure TF_Etapa.BitBtn8Click(Sender: TObject);
begin
  if EditTotal.Text = '0' then
  begin
    ShowMessage('A quantidade deve ser preenchida!!!');
    EditTotal.SetFocus;
    Exit;
  end;
end;

procedure TF_Etapa.CancelarClick(Sender: TObject);
begin
  SenhaOk := false;
  F_Etapa.Close;
end;

procedure TF_Etapa.ContinuarClick(Sender: TObject);
   var resp:string;
begin
  senhaOk:=false;
  if (Edit2.text = '') then begin
    exit;
  end;
  sql:= 'select usuario,chaveacesso from usuarios where senha2='+quotedstr(edit2.text);
  if not Qrytab(sql) then exit;
  Supervisor := cpo[0];
  sChaveAcesso := cpo[1];

  if F_Etapa.Caption = 'MANUTENÇÃO' then begin
    if not autorizado('OrdemServicoManutencao') then begin
      Showmessage('Você não está liberado para acesso a este módulo!'+#13+
      						'Procure seu Lider ou TI.');
      Exit;
    end;
  end;

  if F_Etapa.Caption = 'FERRAMENTAL' then begin
    if not autorizado('ManutencaoFerramental') then begin
      Showmessage('Você não está liberado para acesso a este módulo!');
      Exit;
    end;
  end;

  if F_Etapa.Caption = ' QUALIDADE ' then begin
    if not autorizado('SupervisorControleMedidas') then
      Exit;

  end;

  if (F_Etapa.Caption = 'DESENHOS') then begin
    if not autorizado('VerDesenhos') then begin
      Showmessage('Você não está liberado para acesso a este módulo!');
      Exit;
    end;
  end;

  senhaOk:= true;

end;

procedure TF_Etapa.Edit1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (key = 13) and (PanelLer.Visible = true) then  begin
    key := 0;
    if (edit1.text = '') or (edit1.text = '0,00') then begin
      edit1.setfocus;
      F_Etapa.Close;
      exit;
    end;
    F_Medidas.edit_ler.text := edit1.text;
    Lido:= mrOk;
    F_Etapa.Close;
  end;
end;

procedure TF_Etapa.Edit2KeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in['0'..'9',Chr(8), Chr(13)]) then Key:= #0;
end;

procedure TF_Etapa.EditEquipamentoKeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in['0'..'9',Chr(8), Chr(13)]) then Key:= #0;
end;

procedure TF_Etapa.EditQtdProdExit(Sender: TObject);
begin
  if StrToInt(EditQtdProd.Text) > 0 then
  begin
    if (EditScrap.Text = '') then EditScrap.Text := '0';
    EditTotal.Text := IntToStr(StrToInt(EditQtdProd.Text) - StrToInt(EditScrap.Text));
  end;
  BitBtn8.SetFocus;
end;

procedure TF_Etapa.EdtPcMortaExit(Sender: TObject);
var cont1, cont2 : integer;
begin
  if StrToInt(EdtPcMorta.Text) > 0 then begin
    cont1 := StrToInt(EdtQtdOpAtu.Text);
    cont2 := StrToInt(EdtPcMorta.Text);
    EdtQtdOpAtu.Text := IntToStr(cont1 - cont2);
  end;
end;

procedure TF_Etapa.EdtQtdOpAtuKeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in['0'..'9',Chr(8), Chr(13)]) then Key:= #0;
end;

procedure TF_Etapa.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin

  if (key = vk_divide) and (PanelEtapa.Visible = true) then begin key:=0; end;
  if (key = vk_divide) and  (edit1.text='') and (PanelLer.Visible = true) then begin key := 0; close; end;
  if (key = vk_divide) and (PanelLer.Visible = true) then begin key := 0; edit1.text := ''; end;
  if (key = 13) and (PanelPedSenha.Visible = true) then begin key := 0; Continuar.Click; exit; end;

  if (Key = 13) and (PanelFechaOP.Visible = true) then
  begin
    Key := 0;
    Perform(WM_NextDlgCtl,0,0);
  end;

  if (Key = 13) and (PanelFechaRetrabalho.Visible = true) then
  begin
    Key := 0;
    Perform(WM_NextDlgCtl,0,0);
  end;

  if (Key = 13) and (PanelIA.Visible = true) then
  begin
    if Edit3.Focused then BitBtn2.SetFocus
      else Edit3.SetFocus;
  end;

  if (Key = 13) and (PanelDispoDaNaoConformidade.Visible = true) then
  begin
    if Edit4.Focused then BitBtn4.SetFocus
      else Edit4.SetFocus;
  end;

  if (F_Etapa.Caption = '>> ESCOLHA O ITEM! <<') then begin
    if key = VK_SUBTRACT then key:= VK_UP;

    if key = VK_ADD then key:= VK_DOWN;
  end;

  if (F_Etapa.Caption = '>>ESCOLHA O EQUIPAMENTO!<<') then begin
    if key = VK_SUBTRACT then key:= VK_UP;

    if key = VK_ADD then key:= VK_DOWN;
  end;

end;

procedure TF_Etapa.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if PanelEtapa.Visible=true then begin
    if key = '1' then begin
      etapa:='L';
      etapaok := true;
      PanelEtapa.Visible := False;
      F_Etapa.Close;
    end;
    if key = '2' then begin
      etapa:='A';
      etapaok := true;
      PanelEtapa.Visible := False;
      F_Etapa.Close;
    end;
    if key = '3' then begin
      etapa:='F';
      etapaok := true;
      PanelEtapa.Visible := False;
      F_Etapa.Close;
    end;
    key:=#0;
    exit;
  end;

  if (PanelIA.Visible = true) or (PanelDispoDaNaoConformidade.Visible = true) then
  begin
    pegatecla := pegatecla + key;
    if pegatecla = '01' then
    begin
      if PanelIA.Visible = true then begin if CheckBox1.Checked = true then CheckBox1.Checked := false else CheckBox1.Checked := true; end;
      if PanelDispoDaNaoConformidade.Visible = true then begin if CheckBox6.Checked = true then CheckBox6.Checked := false else CheckBox6.Checked := true; end;
    end;
    if pegatecla = '02' then
    begin
      if PanelIA.Visible = true then begin if CheckBox3.Checked = true then CheckBox3.Checked := false else CheckBox3.Checked := true; end;
      if PanelDispoDaNaoConformidade.Visible = true then begin if CheckBox7.Checked = true then CheckBox7.Checked := false else CheckBox7.Checked := true; end;
    end;
    if pegatecla = '03' then
    begin
      if PanelIA.Visible = true then begin if CheckBox2.Checked = true then CheckBox2.Checked := false else CheckBox2.Checked := true; end;
      if PanelDispoDaNaoConformidade.Visible = true then begin if CheckBox8.Checked = true then CheckBox8.Checked := false else CheckBox8.Checked := true; end;
    end;
    if pegatecla = '04' then
    begin
      if PanelIA.Visible = true then begin if CheckBox4.Checked = true then CheckBox4.Checked := false else CheckBox4.Checked := true; end;
      if PanelDispoDaNaoConformidade.Visible = true then begin if CheckBox9.Checked = true then CheckBox9.Checked := false else CheckBox9.Checked := true; end;
    end;
    if pegatecla = '05' then
    begin
      if PanelIA.Visible = true then begin if CheckBox5.Checked = true then CheckBox5.Checked := false else CheckBox5.Checked := true; end;
      if PanelDispoDaNaoConformidade.Visible = true then begin if CheckBox19.Checked = true then CheckBox19.Checked := false else CheckBox19.Checked := true; end;
    end;
    if pegatecla = '06' then begin if CheckBox11.Checked = true then CheckBox11.Checked := false else CheckBox11.Checked := true; end;
    if pegatecla = '07' then begin if CheckBox10.Checked = true then CheckBox10.Checked := false else CheckBox10.Checked := true; end;
    if pegatecla = '08' then begin if CheckBox12.Checked = true then CheckBox12.Checked := false else CheckBox12.Checked := true; end;
    if pegatecla = '09' then begin if CheckBox13.Checked = true then CheckBox13.Checked := false else CheckBox13.Checked := true; end;
    if pegatecla = '10' then begin if CheckBox14.Checked = true then CheckBox14.Checked := false else CheckBox14.Checked := true; end;
    if pegatecla = '11' then begin if CheckBox20.Checked = true then CheckBox20.Checked := false else CheckBox20.Checked := true; end;
    if pegatecla = '12' then begin if CheckBox21.Checked = true then CheckBox21.Checked := false else CheckBox21.Checked := true; end;
    if pegatecla = '13' then begin if CheckBox15.Checked = true then CheckBox15.Checked := false else CheckBox15.Checked := true; end;
    if pegatecla = '14' then begin if CheckBox16.Checked = true then CheckBox16.Checked := false else CheckBox16.Checked := true; end;
    if pegatecla = '15' then begin if CheckBox17.Checked = true then CheckBox17.Checked := false else CheckBox17.Checked := true; end;
    if pegatecla = '16' then begin if CheckBox18.Checked = true then CheckBox18.Checked := false else CheckBox18.Checked := true; end;
    if Length(pegatecla) >= 2 then pegatecla := '';
  end;

end;


procedure TF_Etapa.FormShow(Sender: TObject);
begin

  tm_descarta_etapa.Enabled:=true;
  pegatecla := '';
  EtapaOk := false;
  if PanelFechaOP.Visible = true then EditEquipamento.SetFocus;
  if PanelIA.Visible = true then PanelIA.SetFocus;
  if PanelDispoDaNaoConformidade.Visible = true then PanelDispoDaNaoConformidade.SetFocus;
  if F_Etapa.Caption = '>> ESCOLHA O ITEM! <<' then lsItem.SetFocus;
  if F_Etapa.Caption = '>>ESCOLHA O EQUIPAMENTO!<<' then lsItem.SetFocus;

end;

procedure TF_Etapa.lsItemDblClick(Sender: TObject);
begin
  if ((F_Etapa.caption='>> ESCOLHA O ITEM! <<')) then begin
    item:= copy(lsItem.Items.Strings[lsItem.itemindex],1,12)

  end else begin
    item:= copy(lsItem.Items.Strings[lsItem.itemindex],1,6);
  end;
  close;
end;

procedure TF_Etapa.lsItemKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if key=VK_RETURN then begin
    if ((F_Etapa.caption='>>ESCOLHA O EQUIPAMENTO!<<')) then begin
      item := copy(lsItem.Items.Strings[lsItem.itemindex],1,6);
      escolha := lsItem.Items.Strings[lsItem.itemindex];
    end else begin
      item := lsItem.Items.Strings[lsItem.itemindex];
      escolha := lsItem.Items.Strings[lsItem.itemindex];
    end;
    close;
  end;
end;

end.
