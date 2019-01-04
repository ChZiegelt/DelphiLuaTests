program LittleLuaTest;

uses
  System.StartUpCopy,
  FMX.Forms,
  uFormLittleTest in '..\forms\uFormLittleTest.pas' {Form1},
  Lua.API in '..\..\..\Wrapper\delphilua\Lua.API.pas',
  Lua in '..\..\..\Wrapper\delphilua\Lua.pas',
  IIFA.Helper in '..\src\IIFA.Helper.pas',
  IIFA.Account in '..\src\IIFA.Account.pas',
  IIFA.Character in '..\src\IIFA.Character.pas',
  IIFA.Constants in '..\src\IIFA.Constants.pas',
  ESO.Constants in '..\src\ESO.Constants.pas',
  ESO.ItemData in '..\src\ESO.ItemData.pas',
  ESO.Server in '..\src\ESO.Server.pas',
  ESO.Character in '..\src\ESO.Character.pas',
  ESO.Account in '..\src\ESO.Account.pas',
  ESO.Bag in '..\src\ESO.Bag.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
