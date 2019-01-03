unit IIFA.Character;

interface

uses
  {$REGION 'Uses'}
    System.SysUtils
  , System.Types
  , System.UITypes
  , System.Classes

  , System.Generics.Collections
  , Lua

  ;

type

  TCharacterID = string;

  TIifaCharacter = class
  strict private
    FName: String;
    FID: TCharacterID;
    FCollectGuildBankData: Boolean;

  public
    property Name: String read FName write FName;
    property ID: TCharacterID read FID write FID;
    property CollectGuildBankData: Boolean read FCollectGuildBankData write FCollectGuildBankData;

    function toString(): String;
  end;

implementation

{ TCharacter }


function TIifaCharacter.toString: String;
begin
  Result := Format( '  ID: %s   Name: %s   CollectGuildBankData:  %s', [String(FID), FName , FCollectGuildBankData.ToString]);
end;



end.
