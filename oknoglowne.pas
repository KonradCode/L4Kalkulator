unit OknoGlowne;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ComCtrls;

type

  { TForm1 }

  TForm1 = class(TForm)
    ButtonOblicz: TButton;
    ButtonWyczysc: TButton;
    ComboBoxDodatekMotyw: TComboBox;
    EditDodatekNetto2: TEdit;
    EditPensjaNetto2: TEdit;
    EditPensjaPotraceniaBrutto: TEdit;
    EditPensjaNetto1: TEdit;
    EditDodatekNetto1: TEdit;
    EditPensjaBrutto: TEdit;
    EditL4Dni: TEdit;
    EditDodatekPotraceniaBrutto: TEdit;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox5: TGroupBox;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label19: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    StatusBar1: TStatusBar;

    procedure ButtonObliczClick(Sender: TObject);
    procedure ButtonWyczyscClick(Sender: TObject);
    procedure EditL4DniExit(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure PustyStringNaZero(Sender: TObject);
    procedure StatusBar1Click(Sender: TObject);
    procedure WyczyscWszystkiePola;
  private
    const
    URL = 'https://github.com/KonradCode/L4Kalkulator/releases';


    procedure ObliczWyplate;


  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}
uses L4, podatek,ShellAPI,wersja;

{ TForm1 }

procedure TForm1.PustyStringNaZero(Sender: TObject);
begin
  if (Sender is TEdit) then
  begin
    if TEdit(Sender).Text = '' then
      TEdit(Sender).Text := IntToStr(0);
  end
  else if (Sender is TComboBox) then
  begin
    if TComboBox(Sender).Text = '' then
      TComboBox(Sender).Text := IntToStr(0);
  end;
end;

procedure TForm1.StatusBar1Click(Sender: TObject);

begin
 ShellExecute(0, 'open', PChar(URL), nil, nil, 1);  //1 - SW_NORMAL
end;

procedure TForm1.WyczyscWszystkiePola;
var
  i: integer;
begin

  for i := 0 to ComponentCount - 1 do
  begin
    if Components[i] is TEdit then
      TEdit(Components[i]).Text := '0'; // Możesz użyć '' dla pustego tekstu
  end;
  for i := 0 to ComponentCount - 1 do
  begin
    if Components[i] is TComboBox then
      TComboBox(Components[i]).Text := IntToStr(0);
  end;

end;

procedure TForm1.ObliczWyplate;

var
  pensjaBrutto,  dodatekBrutto, pensjaPotracenia, dodatekPotracenia,
  pensjaNetto1Prog,pensjaNetto2Prog, dodatekNetto1Prog, dodatekNetto2Prog: currency;
  l4dni: integer;

begin
  pensjaBrutto := StrToCurr(EditPensjaBrutto.Text);
  dodatekBrutto := StrToCurr(ComboBoxDodatekMotyw.Text);
  l4dni := StrToInt(EditL4Dni.Text);

  //pensjaPotracenia := TL4C.ObliczPotraceniaPensji(pensjaBrutto, l4dni);
  //dodatekPotracenia := TL4C.ObliczPotraceniaDodatku(dodatekBrutto, l4dni);
  pensjaPotracenia := TL4R.ObliczPotraceniaPensji(pensjaBrutto, l4dni);   // uzywa rekordu
  dodatekPotracenia := TL4R.ObliczPotraceniaDodatku(dodatekBrutto, l4dni); // uzywa rekordu


  pensjaBrutto := pensjaBrutto - pensjaPotracenia;
  dodatekBrutto := dodatekBrutto - dodatekPotracenia;

  if pensjaBrutto < 0 then
  begin
    pensjaBrutto := 0;
    pensjaNetto1Prog := 0;
    pensjaNetto2Prog := 0;
  end
  else if dodatekBrutto < 0 then
  begin
    dodatekBrutto := 0;
    dodatekNetto1Prog := 0;
    dodatekNetto2Prog := 0;
  end
  else
  begin
    pensjaNetto1Prog := pensjaBrutto - TPodatek.ObliczPodatki1ProgMiesiac(
      pensjaBrutto);
    pensjaNetto2Prog:= pensjaBrutto - TPodatek.ObliczPodatki2ProgMiesiac(
      pensjaBrutto);

    dodatekNetto1Prog := dodatekBrutto - TPodatek.ObliczTylkoPodatek1ProgMiesiac(
      dodatekBrutto);
    dodatekNetto2Prog := dodatekBrutto - TPodatek.ObliczTylkoPodatek2ProgMiesiac(
      dodatekBrutto);
  end;

  EditPensjaPotraceniaBrutto.Text := CurrToStr(pensjaPotracenia);
  EditDodatekPotraceniaBrutto.Text := CurrToStr(dodatekPotracenia);

  EditPensjaNetto1.Text := CurrToStr(pensjaNetto1Prog);
  EditPensjaNetto2.Text := CurrToStr(pensjaNetto2Prog);

  EditDodatekNetto1.Text  := CurrToStr(dodatekNetto1Prog);
  EditDodatekNetto2.Text  := CurrToStr(dodatekNetto2Prog);
end;

procedure TForm1.ButtonObliczClick(Sender: TObject);
begin
  ObliczWyplate;
end;

procedure TForm1.ButtonWyczyscClick(Sender: TObject);
begin
  WyczyscWszystkiePola;
end;

procedure TForm1.EditL4DniExit(Sender: TObject);
begin
  PustyStringNaZero(Sender);

end;

procedure TForm1.FormCreate(Sender: TObject);
begin
   StatusBar1.Panels[1].Text:='Wersja programu: ' + TAppVersion.GetVersion;
end;

end.
