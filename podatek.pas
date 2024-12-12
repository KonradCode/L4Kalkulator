unit podatek;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils;




type

{ TPodatek }

TPodatek = class

  private

  type
  TPodatekRok= array of string;
  TPodatki= array of array of string;

  const
    GROSZE = 100;
    ROK_DOMYSLNY = '2022';
    MIESIECY_W_ROKU = 12;
    KOLUMNA_ROK = 0;
    KOLUMNA_KWOTA_WOLNA = 1;
    KOLUMNA_ZDROWOTNA = 2;
    KOLUMNA_ZDROWOTNA_ODLICZNA = 3;
    KOLUMNA_PODATEK_PROG_1 = 4;
    KOLUMNA_PROG_KWOTA = 5;
    KOLUMNA_PODATEK_PROG_2 = 6;
    PODATEK_ROK_START = 0;
    PODATEK_ROK_STOP = 6;

    PODATEK_TABELA: TPodatekRok = (
      //Rok | Kwota zmniejszajaca podatek | Składka | Składka |  Stawka 1 | Próg 2  | Stawka 2
      //    | (PLN)       | zdrow.  | odlicz. | (%)      | (PLN)   | (%)

      '2022', '3600', '9', '0', '12', '120000', '32');    // kwota obnizajaca podatek

   var
    fPodatekBiezacy:TPodatekRok;

   public
   constructor Create;
   destructor Destroy;
   procedure Clear;


     function ObliczNaleznosciMiesiac(ABrutto, ABruttoRok: currency): currency;
   class function ObliczPodatkiMiesiac(ABrutto, ABruttoRok: currency): currency;
   class function ObliczTylkoPodatekMiesiac(ABrutto, ABruttoRok: currency): currency;
   end;




// funkcje pomocnicze
function RoundTax(Value: Double): Integer;


implementation



function RoundTax(Value: Double): Integer; //zaokrągla zgodnie z regułą podatkową
begin
  if Frac(Value) = 0.5 then
    Result := Trunc(Value) + 1
  else
    Result := Round(Value);
end;





{ TPodatek }

constructor TPodatek.Create;
begin
  fPodatekBiezacy:= PODATEK_TABELA;
end;

destructor TPodatek.Destroy;
begin
 fPodatekBiezacy:=nil;
end;

procedure TPodatek.Clear;
begin
//  czyszczenie zawartosci
end;

function TPodatek.ObliczNaleznosciMiesiac(ABrutto, ABruttoRok: currency): currency;
var
 // test: currency;
  pierwszyProgProcent, drugiProgProcent: currency;
  kwotaProgu, podstawaOpodatkowania, kwotaNaleznosci, kwotaWolna,
  kwotaProguMiesiac, skladkaZdrowotnaOdliczalna, skladkaZdrowotna: currency;

begin
   //czyszczenie zmiennych
   skladkaZdrowotnaOdliczalna :=0;
   skladkaZdrowotna:=0;
   kwotaNaleznosci:=0;

  // Przypisanie wartości z tabeli podatków
  kwotaWolna := StrToCurr(fPodatekBiezacy[KOLUMNA_KWOTA_WOLNA]);
  pierwszyProgProcent := StrToCurr(fPodatekBiezacy[KOLUMNA_PODATEK_PROG_1]);
  drugiProgProcent := StrToCurr(fPodatekBiezacy[KOLUMNA_PODATEK_PROG_2]);
  kwotaProgu := StrToCurr(fPodatekBiezacy[KOLUMNA_PROG_KWOTA]);


  // Składki zdrowotne
  skladkaZdrowotna := RoundTax(ABrutto *
    StrToCurr(fPodatekBiezacy[KOLUMNA_ZDROWOTNA])) / GROSZE;  //dla w32 Round raokragla zle


  skladkaZdrowotnaOdliczalna :=
    RoundTax(ABrutto * StrToCurr(fPodatekBiezacy[KOLUMNA_ZDROWOTNA_ODLICZNA])) / GROSZE;

  // Przeliczenie kwoty wolnej na miesiące
  kwotaWolna := kwotaWolna / MIESIECY_W_ROKU;

  // Obliczamy podstawę opodatkowania
  podstawaOpodatkowania := RoundTax(ABrutto);

  // Obliczamy próg dla jednego miesiąca
  kwotaProguMiesiac := kwotaProgu / MIESIECY_W_ROKU;

  // Obliczenia zależne od progu dochodowego
  if ABruttoRok <= kwotaProgu then
    kwotaNaleznosci := RoundTax((podstawaOpodatkowania * pierwszyProgProcent) /
      GROSZE - kwotaWolna)
  else
    kwotaNaleznosci := RoundTax(((kwotaProguMiesiac * pierwszyProgProcent) / GROSZE) +
      ((podstawaOpodatkowania - kwotaProguMiesiac) * drugiProgProcent) /
      GROSZE - kwotaWolna);

  // Korekta należności o składkę zdrowotną (odliczalna)
  kwotaNaleznosci := kwotaNaleznosci - skladkaZdrowotnaOdliczalna;

  // Dodanie składki zdrowotnej (nieodliczalna)
  kwotaNaleznosci := kwotaNaleznosci + skladkaZdrowotna;

  // Podatek nie może być ujemny
  if kwotaNaleznosci < 0 then
    kwotaNaleznosci := 0;

  Result := kwotaNaleznosci;
  //Result := Round(kwotaNaleznosci);

end;

class function TPodatek.ObliczPodatkiMiesiac(ABrutto, ABruttoRok: currency
  ): currency;
var
 // test: currency;
  pierwszyProgProcent, drugiProgProcent: currency;
  kwotaProgu, podstawaOpodatkowania, kwotaNaleznosci, kwotaWolna,
  kwotaProguMiesiac, skladkaZdrowotnaOdliczalna, skladkaZdrowotna: currency;
  podatekBiezacy:TPodatekRok;
begin
   //czyszczenie zmiennych
   skladkaZdrowotnaOdliczalna :=0;
   skladkaZdrowotna:=0;
   kwotaNaleznosci:=0;
   podatekBiezacy:=PODATEK_TABELA;


  // Przypisanie wartości z tabeli podatków
  kwotaWolna := StrToCurr(podatekBiezacy[KOLUMNA_KWOTA_WOLNA]);
  pierwszyProgProcent := StrToCurr(podatekBiezacy[KOLUMNA_PODATEK_PROG_1]);
  drugiProgProcent := StrToCurr(podatekBiezacy[KOLUMNA_PODATEK_PROG_2]);
  kwotaProgu := StrToCurr(podatekBiezacy[KOLUMNA_PROG_KWOTA]);


  // Składki zdrowotne
  skladkaZdrowotna := RoundTax(ABrutto *
    StrToCurr(podatekBiezacy[KOLUMNA_ZDROWOTNA])) / GROSZE;  //dla w32 Round raokragla zle


  skladkaZdrowotnaOdliczalna :=
    RoundTax(ABrutto * StrToCurr(podatekBiezacy[KOLUMNA_ZDROWOTNA_ODLICZNA])) / GROSZE;

  // Przeliczenie kwoty wolnej na miesiące
  kwotaWolna := kwotaWolna / MIESIECY_W_ROKU;

  // Obliczamy podstawę opodatkowania
  podstawaOpodatkowania := RoundTax(ABrutto);

  // Obliczamy próg dla jednego miesiąca
  kwotaProguMiesiac := kwotaProgu / MIESIECY_W_ROKU;

  // Obliczenia zależne od progu dochodowego
  if ABruttoRok <= kwotaProgu then
    kwotaNaleznosci := RoundTax((podstawaOpodatkowania * pierwszyProgProcent) /
      GROSZE - kwotaWolna)
  else
    kwotaNaleznosci := RoundTax(((kwotaProguMiesiac * pierwszyProgProcent) / GROSZE) +
      ((podstawaOpodatkowania - kwotaProguMiesiac) * drugiProgProcent) /
      GROSZE - kwotaWolna);

  // Korekta należności o składkę zdrowotną (odliczalna)
  kwotaNaleznosci := kwotaNaleznosci - skladkaZdrowotnaOdliczalna;

  // Dodanie składki zdrowotnej (nieodliczalna)
  kwotaNaleznosci := kwotaNaleznosci + skladkaZdrowotna;

  // Podatek nie może być ujemny
  if kwotaNaleznosci < 0 then
    kwotaNaleznosci := 0;

  Result := kwotaNaleznosci;
  //Result := Round(kwotaNaleznosci);


end;

class function TPodatek.ObliczTylkoPodatekMiesiac(ABrutto, ABruttoRok: currency
  ): currency;
var
 // test: currency;
  pierwszyProgProcent, drugiProgProcent: currency;
  kwotaProgu, podstawaOpodatkowania, kwotaNaleznosci, kwotaWolna,
  kwotaProguMiesiac  : currency;
  podatekBiezacy:TPodatekRok;
begin
   //czyszczenie zmiennych
   kwotaNaleznosci:=0;
   podatekBiezacy:=PODATEK_TABELA;


  // Przypisanie wartości z tabeli podatków
  kwotaWolna := StrToCurr(podatekBiezacy[KOLUMNA_KWOTA_WOLNA]);
  pierwszyProgProcent := StrToCurr(podatekBiezacy[KOLUMNA_PODATEK_PROG_1]);
  drugiProgProcent := StrToCurr(podatekBiezacy[KOLUMNA_PODATEK_PROG_2]);
  kwotaProgu := StrToCurr(podatekBiezacy[KOLUMNA_PROG_KWOTA]);



  // Przeliczenie kwoty wolnej na miesiące
  kwotaWolna := kwotaWolna / MIESIECY_W_ROKU;

  // Obliczamy podstawę opodatkowania
  podstawaOpodatkowania := RoundTax(ABrutto);

  // Obliczamy próg dla jednego miesiąca
  kwotaProguMiesiac := kwotaProgu / MIESIECY_W_ROKU;

  // Obliczenia zależne od progu dochodowego
  if ABruttoRok <= kwotaProgu then
    kwotaNaleznosci := RoundTax((podstawaOpodatkowania * pierwszyProgProcent) /
      GROSZE - kwotaWolna)
  else
    kwotaNaleznosci := RoundTax(((kwotaProguMiesiac * pierwszyProgProcent) / GROSZE) +
      ((podstawaOpodatkowania - kwotaProguMiesiac) * drugiProgProcent) /
      GROSZE - kwotaWolna);

  // Podatek nie może być ujemny
  if kwotaNaleznosci < 0 then
    kwotaNaleznosci := 0;

  Result := kwotaNaleznosci;
  //Result := Round(kwotaNaleznosci);

end;


end.

