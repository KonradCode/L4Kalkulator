unit wersja;

{$mode ObjFPC}{$H+}

interface

{ TWersja }

type
  { TAppVersion }
  TAppVersion = class
  private
    class var FVersion: string; // Statyczne pole do przechowywania wersji
    class function RetrieveVersion: string; // Prywatna metoda pobierająca wersję z zasobów
  public
    class function GetVersion: string; // Publiczna metoda zwracająca wersję
  end;



implementation


uses
  Windows, SysUtils;

{ TAppVersion }

class function TAppVersion.RetrieveVersion: string;
var
  InfoSize, Wnd: DWORD;
  VerBuf: Pointer;
  VerSize: DWORD;
  VerValue: Pointer;
  FixedFileInfo: PVSFixedFileInfo;
begin
  Result := '';
  InfoSize := GetFileVersionInfoSize(PChar(ParamStr(0)), Wnd);
  if InfoSize = 0 then Exit;

  GetMem(VerBuf, InfoSize);
  try
    if GetFileVersionInfo(PChar(ParamStr(0)), Wnd, InfoSize, VerBuf) then
    begin
      if VerQueryValue(VerBuf, '\', VerValue, VerSize) then
      begin
        FixedFileInfo := PVSFixedFileInfo(VerValue);
        with FixedFileInfo^ do
        begin
          Result := Format('%d.%d.%d.%d', [
            HiWord(dwFileVersionMS),
            LoWord(dwFileVersionMS),
            HiWord(dwFileVersionLS),
            LoWord(dwFileVersionLS)
          ]);
        end;
      end;
    end;
  finally
    FreeMem(VerBuf);
  end;
end;

class function TAppVersion.GetVersion: string;
begin
  // Jeśli wersja nie jest jeszcze załGetVersionadowana, pobierz ją
  if FVersion = '' then
    FVersion := RetrieveVersion;
  Result := FVersion;
end;

//begin
//  Writeln('Wersja aplikacji: ', TAppVersion.GetVersion);
end.


