program LittleLuaTest;

uses
  System.StartUpCopy,
  FMX.Forms,
  uFormLittleTest in '..\forms\uFormLittleTest.pas' {Form1},
  Lua.API in '..\..\..\Wrapper\delphilua\Lua.API.pas',
  Lua in '..\..\..\Wrapper\delphilua\Lua.pas',
  IIFA.Helper in '..\src\IIFA.Helper.pas',
  IIFA.Settings in '..\src\IIFA.Settings.pas',
  IIFA.Account in '..\src\IIFA.Account.pas',
  IIFA.Character in '..\src\IIFA.Character.pas',
  IIFA.Data in '..\src\IIFA.Data.pas',
  IIFA.Server in '..\src\IIFA.Server.pas',
  IIFA.Constants in '..\src\IIFA.Constants.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
