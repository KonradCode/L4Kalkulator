unit L4;

{$mode ObjFPC}{$H+}
{$modeswitch advancedrecords}
interface

uses
  Classes, SysUtils;

type


  {TL4C - klasa}

  TL4C = class

  public

  const
    WSPOLCZYNNIK_POTRACENIA_PENSJI = 0.2;
   // WSPOLCZYNNIK_PENSJI = 0.8;
    WSPOLCZYNNIK_POTRACENIA_DODATKU = 1;
    PRZELICZNIK_DZIEN = 30;

    constructor Create;
    procedure Clear;
    // metody statyczne do pracy bez tworzenia obiektów
    class function ObliczPotraceniaPensji(APensjaBrutto: currency; AdniL4: integer): currency;
    class function ObliczPotraceniaDodatku(ADodtek: currency; AdniL4: integer): currency;

  private

 // const
   // PENSJE_W_ROKU = 12;





  end;

// TL4R  rekord - wymagane  {$modeswitch advancedrecords}

TL4R = record
 private

 public
 const
   WSPOLCZYNNIK_POTRACENIA_PENSJI = 0.2;
   WSPOLCZYNNIK_POTRACENIA_DODATKU = 1;
   PRZELICZNIK_DZIEN = 30;

   // metody statyczne wymagane przez rekord
   class function ObliczPotraceniaPensji(APensjaBrutto: currency; AdniL4: integer): currency; static;
   class function ObliczPotraceniaDodatku(ADodtek: currency; AdniL4: integer): currency; static;



 end;


implementation

uses podatek;

{ TL4C }

constructor TL4C.Create;
begin

end;

procedure TL4C.Clear;
begin

end;

class function TL4C.ObliczPotraceniaPensji(APensjaBrutto: currency;
  AdniL4: integer): currency;

var
  l4dzien, l4: currency;
begin
  if (APensjaBrutto <= 0) then
  begin
    Result := 0;
    exit;
    //raise Exception.Create('Podstawa i procenty muszą być większe od zera.');
  end
  //else if AdniL4 > 30 then    { #todo -oja : do przemyslenia co z dnimi powyzej 30 }
  else

    l4dzien := (APensjaBrutto * WSPOLCZYNNIK_POTRACENIA_PENSJI) / PRZELICZNIK_DZIEN;
  l4 := AdniL4 * l4dzien;
  l4 := (l4 / 10000);// zaokrąglenie do groszy  do  sprawdzenia
  Result := l4 * 10000;
end;

class function TL4C.ObliczPotraceniaDodatku(ADodtek: currency;
  AdniL4: integer): currency;
var
  l4dzien, l4: currency;
begin
  if (ADodtek <= 0) then
  begin
    Result := 0;
    exit;
    //raise Exception.Create('Podstawa i procenty muszą być większe od zera.');
  end
  //else if AdniL4 > 30 then    { #todo -oja : do przemyslenia co z dnimi powyzej 30 }
  else

    l4dzien := (ADodtek * WSPOLCZYNNIK_POTRACENIA_DODATKU) / PRZELICZNIK_DZIEN;
  l4 := AdniL4 * l4dzien;
  l4 := (l4 / 10000);// zaokrąglenie do groszy  do sprawdzenia
  Result := l4 * 10000;
end;

{ koniec TL4C }

//#############################################################################


{TL4R}

class function TL4R.ObliczPotraceniaPensji(APensjaBrutto: currency;
  AdniL4: integer): currency;

var
  l4dzien, l4: currency;
begin
  if (APensjaBrutto <= 0) then
  begin
    Result := 0;
    exit;
  end
  //else if AdniL4 > 30 then    { #todo -oja : do przemyslenia co z nimi powyzej 30 }
  else

    l4dzien := (APensjaBrutto * WSPOLCZYNNIK_POTRACENIA_PENSJI) / PRZELICZNIK_DZIEN;
  l4 := AdniL4 * l4dzien;
  l4 := (l4 / 10000);// zaokrąglenie do groszy  do  sprawdzenia
  Result := l4 * 10000;
end;

class function TL4R.ObliczPotraceniaDodatku(ADodtek: currency;
  AdniL4: integer): currency;
var
  l4dzien, l4: currency;
begin
  if (ADodtek <= 0) then
  begin
    Result := 0;
    exit;

  end
  //else if AdniL4 > 30 then    { #todo -oja : do przemyslenia co z nimi powyzej 30 }
  else

    l4dzien := (ADodtek * WSPOLCZYNNIK_POTRACENIA_DODATKU) / PRZELICZNIK_DZIEN;
  l4 := AdniL4 * l4dzien;
  l4 := (l4 / 10000);// zaokrąglenie do groszy  do sprawdzenia
  Result := l4 * 10000;
end;


end.
