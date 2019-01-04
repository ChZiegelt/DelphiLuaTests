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

  , ESO.Bag
  , ESO.Character
  ;
 {$ENDREGION}

type

  TIIfACharacter = class(TESOCharacter)
  strict private
    FSetting_CollectGuildBankData: Boolean;
  private

  public
    property Setting_CollectGuildBankData: Boolean read FSetting_CollectGuildBankData write FSetting_CollectGuildBankData;

    function toString(): String; override;
  end;

implementation

{ TCharacter }


function TIIfACharacter.toString: String;
begin
  Result := Format('   Id: %s, Name: %s, CollectGuildBankData: %s, AP: %s, WV: %s, TV: %s, Gold: %s, space: %s/%s',
                       [Id, Name, FSetting_CollectGuildBankData.ToString, Asset_ap.ToString, Asset_wv.ToString, Asset_tv.ToString, Asset_gold.ToString, Asset_bagSpace.used.ToString, Asset_bagSpace.max.ToString]
  );
end;



end.
