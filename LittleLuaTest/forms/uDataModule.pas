unit uDataModule;

interface

uses
  System.SysUtils, System.Classes, FMX.Types;

type
  TDataModule1 = class(TDataModule)
    Lang1: TLang;
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  DataModule1: TDataModule1;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

end.
