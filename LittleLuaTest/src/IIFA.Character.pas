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

  , ESO.Character
  ;

type

  TIIfACharacter = class(TESOCharacter)
  strict private
    FCollectGuildBankData: Boolean;

  public
    property CollectGuildBankData: Boolean read FCollectGuildBankData write FCollectGuildBankData;

    function toString(): String; override;
  end;

implementation

{ TCharacter }


function TIIfACharacter.toString: String;
begin
  Result := Format( '  ID: %s   Name: %s   CollectGuildBankData:  %s', [String(ID), Name , FCollectGuildBankData.ToString]);
end;



end.
