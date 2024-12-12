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
    EditPensjaPotraceniaBrutto: TEdit;
    EditPensjaBruttoRok: TEdit;
    EditPensjaNetto: TEdit;
    EditDodatekNetto: TEdit;
    EditPensjaBrutto: TEdit;
    EditL4Dni: TEdit;
    EditDodatekPotraceniaBrutto: TEdit;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox5: TGroupBox;
    Label1: TLabel;
    Label19: TLabel;
    Label2: TLabel;
    Label21: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label7: TLabel;
    StatusBar1: TStatusBar;

    procedure ButtonObliczClick(Sender: TObject);
    procedure ButtonWyczyscClick(Sender: TObject);
    procedure EditL4DniExit(Sender: TObject);
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
uses L4, podatek,ShellAPI;

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
 ShellExecute(0, 'open', PChar(URL), nil, nil, SW_NORMAL);
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
      TComboBox(Components[i]).ItemIndex := -1;
  end;

end;

procedure TForm1.ObliczWyplate;

var
  pensjaBrutto, pensjaBruttoRok, dodatekBrutto, pensjaPotracenia, dodatekPotracenia,
  pensjaNetto, dodatekNetto: currency;
  l4dni: integer;

begin
  pensjaBrutto := StrToCurr(EditPensjaBrutto.Text);
  dodatekBrutto := StrToCurr(ComboBoxDodatekMotyw.Text);
  pensjaBruttoRok := StrToCurr(EditPensjaBruttoRok.Text);
  l4dni := StrToInt(EditL4Dni.Text);

  pensjaPotracenia := TL4.ObliczPotraceniaPensji(pensjaBrutto, l4dni);
  dodatekPotracenia := TL4.ObliczPotraceniaDodatku(dodatekBrutto, l4dni);



  pensjaBrutto := pensjaBrutto - pensjaPotracenia;
  dodatekBrutto := dodatekBrutto - dodatekPotracenia;

  if pensjaBrutto < 0 then
  begin
    pensjaBrutto := 0;
    pensjaNetto := 0;
  end
  else if dodatekBrutto < 0 then
  begin
    dodatekBrutto := 0;
    dodatekNetto := 0;
  end
  else
  begin
    pensjaNetto := pensjaBrutto - TPodatek.ObliczPodatkiMiesiac(
      pensjaBrutto, pensjaBruttoRok);
    dodatekNetto := dodatekBrutto - TPodatek.ObliczTylkoPodatekMiesiac(
      dodatekBrutto, pensjaBruttoRok);
  end;

  EditPensjaPotraceniaBrutto.Text := CurrToStr(pensjaPotracenia);
  EditDodatekPotraceniaBrutto.Text := CurrToStr(dodatekPotracenia);

  EditPensjaNetto.Text := CurrToStr(pensjaNetto);
  EditDodatekNetto.Text := CurrToStr(dodatekNetto);
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

end.
