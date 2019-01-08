program LittleLuaTest;

uses
  System.StartUpCopy,
  FMX.Forms,
  uFormLittleTest in '..\forms\uFormLittleTest.pas' {formMemo},
  IIFA.Helper in '..\src\IIFA.Helper.pas',
  IIFA.Account in '..\src\IIFA.Account.pas',
  IIFA.Character in '..\src\IIFA.Character.pas',
  IIFA.Constants in '..\src\IIFA.Constants.pas',
  ESO.Constants in '..\src\ESO.Constants.pas',
  ESO.ItemData in '..\src\ESO.ItemData.pas',
  ESO.Server in '..\src\ESO.Server.pas',
  ESO.Character in '..\src\ESO.Character.pas',
  ESO.Account in '..\src\ESO.Account.pas',
  ESO.Bag in '..\src\ESO.Bag.pas',
  Lua.API in '..\DelphiLua\Lua.API.pas',
  Lua in '..\DelphiLua\Lua.pas',
  ESO.Bank in '..\src\ESO.Bank.pas',
  ESO.GuildBank in '..\src\ESO.GuildBank.pas',
  IIfA.GuildBank in '..\src\IIfA.GuildBank.pas',
  ESO.HouseBank in '..\src\ESO.HouseBank.pas',
  ESO.SubscriberBank in '..\src\ESO.SubscriberBank.pas',
  uFormLittleGridTest in '..\forms\uFormLittleGridTest.pas' {formGrid},
  uDataModule in '..\forms\uDataModule.pas' {DataModule1: TDataModule},
  uFormImage in '..\forms\uFormImage.pas' {formESOImage},
  uFormListView in '..\forms\uFormListView.pas' {formListView};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TformMemo, formMemo);
  Application.CreateForm(TformGrid, formGrid);
  Application.CreateForm(TDataModule1, DataModule1);
  Application.CreateForm(TformESOImage, formESOImage);
  Application.CreateForm(TformListView, formListView);
  Application.Run;
end.
