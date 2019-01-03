program LittleLuaTest;

uses
  System.StartUpCopy,
  FMX.Forms,
  uFormLittleTest in '..\forms\uFormLittleTest.pas' {Form1},
  IIFA.Helper in '..\src\IIFA.Helper.pas',
  IIFA.Settings in '..\src\IIFA.Settings.pas',
  IIFA.Account in '..\src\IIFA.Account.pas',
  IIFA.Character in '..\src\IIFA.Character.pas',
  IIFA.Data in '..\src\IIFA.Data.pas',
  IIFA.Server in '..\src\IIFA.Server.pas',
  IIFA.Constants in '..\src\IIFA.Constants.pas',
  IIFA.Item in '..\src\IIFA.Item.pas',
  ESO.Constants in '..\src\ESO.Constants.pas',
  ESO.ItemData in '..\src\ESO.ItemData.pas',
  Lua.API in '..\DelphiLua\Lua.API.pas',
  Lua in '..\DelphiLua\Lua.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
