unit TestL4;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpcunit, testutils, testregistry;

type

  { TestL4R }

  TestL4R= class(TTestCase)
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestHookUp;
    procedure TestObliczPotraceniaPensji;
    procedure TestObliczPotraceniaDodatku;
  end;

implementation

uses L4;

procedure TestL4R.SetUp;
begin
  inherited SetUp;
end;

procedure TestL4R.TearDown;
begin
  inherited TearDown;
end;

procedure TestL4R.TestHookUp;
begin
  Fail('Write your own test');

end;

procedure TestL4R.TestObliczPotraceniaPensji;
const
  WSPOLCZYNNIK_POTRACENIA_PENSJI = 13.71; // Ustaw stałe odpowiednie do testów
  PRZELICZNIK_DZIEN = 30;                 // Dla uproszczenia testów
var
  PensjaBrutto, Wynik: Currency;
begin
  // Test 1: PensjaBrutto = 0, dni L4 = 10
  PensjaBrutto := 0;
  Wynik := TL4R.ObliczPotraceniaPensji(PensjaBrutto, 10);
  AssertEquals('Brak potrąceń dla zerowej pensji', 0, Wynik);

  // Test 2: PensjaBrutto = 3000, dni L4 = 10
  PensjaBrutto := 3000;
  Wynik := TL4R.ObliczPotraceniaPensji(PensjaBrutto, 10);
  AssertEquals('Potrącenie przy 10 dniach L4', 13710, Wynik); // Oczekiwany wynik wg wzoru

  // Test 3: PensjaBrutto < 0 (wartość ujemna), dni L4 = 5
  PensjaBrutto := -1000;
  Wynik := TL4R.ObliczPotraceniaPensji(PensjaBrutto, 5);
  AssertEquals('Brak potrąceń dla ujemnej pensji', 0, Wynik);
end;

procedure TestL4R.TestObliczPotraceniaDodatku;
const
  WSPOLCZYNNIK_POTRACENIA_DODATKU = 7.5; // Ustaw stałe odpowiednie do testów
  PRZELICZNIK_DZIEN = 30;                // Dla uproszczenia testów
var
  Dodatek, Wynik: Currency;
begin
  // Test 1: Dodatek = 0, dni L4 = 15
  Dodatek := 0;
  Wynik := TL4R.ObliczPotraceniaDodatku(Dodatek, 15);
  AssertEquals('Brak potrąceń dla zerowego dodatku', 0, Wynik);

  // Test 2: Dodatek = 500, dni L4 = 10
  Dodatek := 500;
  Wynik := TL4R.ObliczPotraceniaDodatku(Dodatek, 10);
  AssertEquals('Potrącenie przy 10 dniach L4', 1250, Wynik); // Oczekiwany wynik wg wzoru

  // Test 3: Dodatek < 0 (wartość ujemna), dni L4 = 20
  Dodatek := -500;
  Wynik := TL4R.ObliczPotraceniaDodatku(Dodatek, 20);
  AssertEquals('Brak potrąceń dla ujemnego dodatku', 0, Wynik);

end;



initialization

  RegisterTest(TestL4R);
end.

