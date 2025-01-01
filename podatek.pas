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
    TPodatekRok = array of string;
    TPodatki = array of array of string;

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
 //   PODATEK_ROK_START = 0;
 //   PODATEK_ROK_STOP = 6;

    PODATEK_TABELA: TPodatekRok = (
      //Rok | Kwota zmniejszajaca podatek | Składka | Składka |  Stawka 1 | Próg 2  | Stawka 2
      //    | (PLN)       | zdrow.  | odlicz. | (%)      | (PLN)   | (%)

      '2022', '3600', '9', '0', '12', '120000', '32');    // kwota obnizajaca podatek

  var
    fPodatekBiezacy: TPodatekRok;

  public

  constructor Create;
  destructor Destroy;override;
  procedure Clear;


    function ObliczNaleznosciMiesiac(ABrutto, ABruttoRok: currency): currency;

    // metody statyczne do pracy bez tworzenia obiektów
    class function ObliczPodatkiMiesiac(ABrutto, ABruttoRok: currency): currency;
    class function ObliczPodatki1ProgMiesiac(ABrutto: currency): currency;
    class function ObliczPodatki2ProgMiesiac(ABrutto: currency): currency;

    class function ObliczTylkoPodatekMiesiac(ABrutto, ABruttoRok: currency): currency;
    class function ObliczTylkoPodatek1ProgMiesiac(ABrutto: currency): currency;
    class function ObliczTylkoPodatek2ProgMiesiac(ABrutto: currency): currency;

    // metody statyczne do pracy bez dostepu do danych klasy
    class function ZaokraglijPodatek(Value: double): integer;static;
  end;




// funkcje pomocnicze
function RoundTax(Value: double): integer;


implementation



function RoundTax(Value: double): integer; //zaokrągla zgodnie z regułą podatkową
begin
  if Frac(Value) = 0.5 then
    Result := Trunc(Value) + 1
  else
    Result := Round(Value);
end;




{ TPodatek }

constructor TPodatek.Create;
begin
  inherited;
  fPodatekBiezacy := PODATEK_TABELA;
end;

destructor TPodatek.Destroy;
begin
  fPodatekBiezacy := nil;
  inherited;
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
  skladkaZdrowotnaOdliczalna := 0;
  skladkaZdrowotna := 0;
  kwotaNaleznosci := 0;

  // Przypisanie wartości z tabeli podatków
  kwotaWolna := StrToCurr(fPodatekBiezacy[KOLUMNA_KWOTA_WOLNA]);
  pierwszyProgProcent := StrToCurr(fPodatekBiezacy[KOLUMNA_PODATEK_PROG_1]);
  drugiProgProcent := StrToCurr(fPodatekBiezacy[KOLUMNA_PODATEK_PROG_2]);
  kwotaProgu := StrToCurr(fPodatekBiezacy[KOLUMNA_PROG_KWOTA]);


  // Składki zdrowotne
  skladkaZdrowotna := ZaokraglijPodatek(ABrutto *
    StrToCurr(fPodatekBiezacy[KOLUMNA_ZDROWOTNA])) / GROSZE;
  //dla w32 Round raokragla zle


  skladkaZdrowotnaOdliczalna :=
    ZaokraglijPodatek(ABrutto * StrToCurr(fPodatekBiezacy[KOLUMNA_ZDROWOTNA_ODLICZNA])) / GROSZE;

  // Przeliczenie kwoty wolnej na miesiące
  kwotaWolna := kwotaWolna / MIESIECY_W_ROKU;

  // Obliczamy podstawę opodatkowania
  podstawaOpodatkowania := ZaokraglijPodatek(ABrutto);

  // Obliczamy próg dla jednego miesiąca
  kwotaProguMiesiac := kwotaProgu / MIESIECY_W_ROKU;

  // Obliczenia zależne od progu dochodowego
  if ABruttoRok <= kwotaProgu then
    kwotaNaleznosci := ZaokraglijPodatek((podstawaOpodatkowania * pierwszyProgProcent) /
      GROSZE - kwotaWolna)
  else
    kwotaNaleznosci := ZaokraglijPodatek(((kwotaProguMiesiac * pierwszyProgProcent) / GROSZE) +
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

class function TPodatek.ObliczPodatkiMiesiac(ABrutto, ABruttoRok: currency): currency;
var
  // test: currency;
  pierwszyProgProcent, drugiProgProcent: currency;
  kwotaProgu, podstawaOpodatkowania, kwotaNaleznosci, kwotaWolna,
  kwotaProguMiesiac, skladkaZdrowotnaOdliczalna, skladkaZdrowotna: currency;
  podatekBiezacy: TPodatekRok;
begin
  //czyszczenie zmiennych
  skladkaZdrowotnaOdliczalna := 0;
  skladkaZdrowotna := 0;
  kwotaNaleznosci := 0;
  podatekBiezacy := PODATEK_TABELA;


  // Przypisanie wartości z tabeli podatków
  kwotaWolna := StrToCurr(podatekBiezacy[KOLUMNA_KWOTA_WOLNA]);
  pierwszyProgProcent := StrToCurr(podatekBiezacy[KOLUMNA_PODATEK_PROG_1]);
  drugiProgProcent := StrToCurr(podatekBiezacy[KOLUMNA_PODATEK_PROG_2]);
  kwotaProgu := StrToCurr(podatekBiezacy[KOLUMNA_PROG_KWOTA]);


  // Składki zdrowotne
  skladkaZdrowotna := ZaokraglijPodatek(ABrutto *
    StrToCurr(podatekBiezacy[KOLUMNA_ZDROWOTNA])) / GROSZE;
  //dla w32 Round raokragla zle


  skladkaZdrowotnaOdliczalna :=
    ZaokraglijPodatek(ABrutto * StrToCurr(podatekBiezacy[KOLUMNA_ZDROWOTNA_ODLICZNA])) / GROSZE;

  // Przeliczenie kwoty wolnej na miesiące
  kwotaWolna := kwotaWolna / MIESIECY_W_ROKU;

  // Obliczamy podstawę opodatkowania
  podstawaOpodatkowania := ZaokraglijPodatek(ABrutto);

  // Obliczamy próg dla jednego miesiąca
  kwotaProguMiesiac := kwotaProgu / MIESIECY_W_ROKU;

  // Obliczenia zależne od progu dochodowego
  if ABruttoRok <= kwotaProgu then
    kwotaNaleznosci := ZaokraglijPodatek((podstawaOpodatkowania * pierwszyProgProcent) /
      GROSZE - kwotaWolna)
  else
    kwotaNaleznosci := ZaokraglijPodatek(((kwotaProguMiesiac * pierwszyProgProcent) / GROSZE) +
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

class function TPodatek.ObliczPodatki1ProgMiesiac(ABrutto: currency): currency;
var
  // test: currency;
  pierwszyProgProcent: currency;
  podstawaOpodatkowania, kwotaNaleznosci, kwotaWolna,
  kwotaProguMiesiac, skladkaZdrowotna,skladkaZdrowotnaOdliczalna: currency;
  podatekBiezacy: TPodatekRok;
begin
  //czyszczenie zmiennych
  skladkaZdrowotna := 0;
  skladkaZdrowotnaOdliczalna := 0;
  kwotaNaleznosci := 0;
  podatekBiezacy := PODATEK_TABELA;


  // Przypisanie wartości z tabeli podatków
  kwotaWolna := StrToCurr(podatekBiezacy[KOLUMNA_KWOTA_WOLNA]);
  pierwszyProgProcent := StrToCurr(podatekBiezacy[KOLUMNA_PODATEK_PROG_1]);


  // Składki zdrowotne
  skladkaZdrowotna := ZaokraglijPodatek(ABrutto *
    StrToCurr(podatekBiezacy[KOLUMNA_ZDROWOTNA])) / GROSZE;
  //dla w32 Round raokragla zle


  skladkaZdrowotnaOdliczalna :=
    ZaokraglijPodatek(ABrutto * StrToCurr(podatekBiezacy[KOLUMNA_ZDROWOTNA_ODLICZNA])) / GROSZE;

  // Przeliczenie kwoty wolnej na miesiące
  kwotaWolna := kwotaWolna / MIESIECY_W_ROKU;

  // Obliczamy podstawę opodatkowania
  podstawaOpodatkowania := ZaokraglijPodatek(ABrutto);

  // Obliczenia zależne od progu dochodowego

   kwotaNaleznosci := ZaokraglijPodatek((podstawaOpodatkowania * pierwszyProgProcent) /
      GROSZE - kwotaWolna);

  // Korekta należności o składkę zdrowotną (odliczalna)
  kwotaNaleznosci := kwotaNaleznosci - skladkaZdrowotnaOdliczalna;

  // Dodanie składki zdrowotnej (nieodliczalna)
  kwotaNaleznosci := kwotaNaleznosci + skladkaZdrowotna;

  // Podatek nie może być ujemny
  if kwotaNaleznosci < 0 then
    kwotaNaleznosci := 0;

  Result := kwotaNaleznosci;

end;

class function TPodatek.ObliczPodatki2ProgMiesiac(ABrutto: currency): currency;
var
  // test: currency;
  drugiProgProcent: currency;
  podstawaOpodatkowania, kwotaNaleznosci, kwotaWolna,
  kwotaProguMiesiac, skladkaZdrowotna,skladkaZdrowotnaOdliczalna: currency;
  podatekBiezacy: TPodatekRok;
begin
  //czyszczenie zmiennych
  skladkaZdrowotna := 0;
  skladkaZdrowotnaOdliczalna := 0;
  kwotaNaleznosci := 0;
  podatekBiezacy := PODATEK_TABELA;


  // Przypisanie wartości z tabeli podatków
  kwotaWolna := StrToCurr(podatekBiezacy[KOLUMNA_KWOTA_WOLNA]);
  drugiProgProcent := StrToCurr(podatekBiezacy[KOLUMNA_PODATEK_PROG_2]);


  // Składki zdrowotne
  skladkaZdrowotna := ZaokraglijPodatek(ABrutto *
    StrToCurr(podatekBiezacy[KOLUMNA_ZDROWOTNA])) / GROSZE;
  //dla w32 Round raokragla zle


  skladkaZdrowotnaOdliczalna :=
    ZaokraglijPodatek(ABrutto * StrToCurr(podatekBiezacy[KOLUMNA_ZDROWOTNA_ODLICZNA])) / GROSZE;

  // Przeliczenie kwoty wolnej na miesiące
  kwotaWolna := kwotaWolna / MIESIECY_W_ROKU;

  // Obliczamy podstawę opodatkowania
  podstawaOpodatkowania := ZaokraglijPodatek(ABrutto);

  // Obliczenia zależne od progu dochodowego



   kwotaNaleznosci := ZaokraglijPodatek( (podstawaOpodatkowania  * drugiProgProcent) /
      GROSZE - kwotaWolna);

  // Korekta należności o składkę zdrowotną (odliczalna)
  kwotaNaleznosci := kwotaNaleznosci - skladkaZdrowotnaOdliczalna;

  // Dodanie składki zdrowotnej (nieodliczalna)
  kwotaNaleznosci := kwotaNaleznosci + skladkaZdrowotna;

  // Podatek nie może być ujemny
  if kwotaNaleznosci < 0 then
    kwotaNaleznosci := 0;

  Result := kwotaNaleznosci;

end;

class function TPodatek.ObliczTylkoPodatekMiesiac(ABrutto, ABruttoRok:
  currency): currency;
var
  // test: currency;
  pierwszyProgProcent, drugiProgProcent: currency;
  kwotaProgu, podstawaOpodatkowania, kwotaNaleznosci, kwotaWolna,
  kwotaProguMiesiac: currency;
  podatekBiezacy: TPodatekRok;
begin
  //czyszczenie zmiennych
  kwotaNaleznosci := 0;
  podatekBiezacy := PODATEK_TABELA;


  // Przypisanie wartości z tabeli podatków
  kwotaWolna := StrToCurr(podatekBiezacy[KOLUMNA_KWOTA_WOLNA]);
  pierwszyProgProcent := StrToCurr(podatekBiezacy[KOLUMNA_PODATEK_PROG_1]);
  drugiProgProcent := StrToCurr(podatekBiezacy[KOLUMNA_PODATEK_PROG_2]);
  kwotaProgu := StrToCurr(podatekBiezacy[KOLUMNA_PROG_KWOTA]);



  // Przeliczenie kwoty wolnej na miesiące
  kwotaWolna := kwotaWolna / MIESIECY_W_ROKU;

  // Obliczamy podstawę opodatkowania
  podstawaOpodatkowania := ZaokraglijPodatek(ABrutto);

  // Obliczamy próg dla jednego miesiąca
  kwotaProguMiesiac := kwotaProgu / MIESIECY_W_ROKU;

  // Obliczenia zależne od progu dochodowego
  if ABruttoRok <= kwotaProgu then
    kwotaNaleznosci := ZaokraglijPodatek((podstawaOpodatkowania * pierwszyProgProcent) /
      GROSZE - kwotaWolna)
  else
    kwotaNaleznosci := ZaokraglijPodatek(((kwotaProguMiesiac * pierwszyProgProcent) / GROSZE) +
      ((podstawaOpodatkowania - kwotaProguMiesiac) * drugiProgProcent) /
      GROSZE - kwotaWolna);

  // Podatek nie może być ujemny
  if kwotaNaleznosci < 0 then
    kwotaNaleznosci := 0;

  Result := kwotaNaleznosci;
  //Result := Round(kwotaNaleznosci);

end;

class function TPodatek.ObliczTylkoPodatek1ProgMiesiac(ABrutto: currency
  ): currency;
var
  // test: currency;
  pierwszyProgProcent, drugiProgProcent: currency;
  kwotaProgu, podstawaOpodatkowania, kwotaNaleznosci, kwotaWolna: currency;
  podatekBiezacy: TPodatekRok;
begin
  //czyszczenie zmiennych
  kwotaNaleznosci := 0;
  podatekBiezacy := PODATEK_TABELA;


  // Przypisanie wartości z tabeli podatków
  kwotaWolna := StrToCurr(podatekBiezacy[KOLUMNA_KWOTA_WOLNA]);
  pierwszyProgProcent := StrToCurr(podatekBiezacy[KOLUMNA_PODATEK_PROG_1]);



  // Przeliczenie kwoty wolnej na miesiące
  kwotaWolna := kwotaWolna / MIESIECY_W_ROKU;

  // Obliczamy podstawę opodatkowania
  podstawaOpodatkowania := ZaokraglijPodatek(ABrutto);


    kwotaNaleznosci := ZaokraglijPodatek((podstawaOpodatkowania * pierwszyProgProcent) /
      GROSZE ) ;


  // Podatek nie może być ujemny
  if kwotaNaleznosci < 0 then
    kwotaNaleznosci := 0;

  Result := kwotaNaleznosci;
  //Result := Round(kwotaNaleznosci);

end;

class function TPodatek.ObliczTylkoPodatek2ProgMiesiac(ABrutto: currency
  ): currency;
var
  // test: currency;
  drugiProgProcent: currency;
  kwotaProgu, podstawaOpodatkowania, kwotaNaleznosci, kwotaWolna: currency;
  podatekBiezacy: TPodatekRok;
begin
  //czyszczenie zmiennych
  kwotaNaleznosci := 0;
  podatekBiezacy := PODATEK_TABELA;


  // Przypisanie wartości z tabeli podatków
  kwotaWolna := StrToCurr(podatekBiezacy[KOLUMNA_KWOTA_WOLNA]);
  drugiProgProcent := StrToCurr(podatekBiezacy[KOLUMNA_PODATEK_PROG_2]);



  // Przeliczenie kwoty wolnej na miesiące
  kwotaWolna := kwotaWolna / MIESIECY_W_ROKU;

  // Obliczamy podstawę opodatkowania
  podstawaOpodatkowania := ZaokraglijPodatek(ABrutto);


    kwotaNaleznosci := ZaokraglijPodatek((podstawaOpodatkowania * drugiProgProcent) /
      GROSZE );


  // Podatek nie może być ujemny
  if kwotaNaleznosci < 0 then
    kwotaNaleznosci := 0;

  Result := kwotaNaleznosci;
  //Result := Round(kwotaNaleznosci);

end;

class function TPodatek.ZaokraglijPodatek(Value: double): integer;
begin
  if Frac(Value) = 0.5 then
    Result := Trunc(Value) + 1
  else
    Result := Round(Value);
end;


end.
