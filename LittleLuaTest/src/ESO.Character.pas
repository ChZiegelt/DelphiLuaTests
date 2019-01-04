unit ESO.Character;

interface

uses
  {$REGION 'Uses'}
    System.SysUtils
  , System.Types
  , System.UITypes
  , System.Classes

  , System.Generics.Collections

  //ESO
  , ESO.bag

  ;
 {$ENDREGION}


  type

  TESOCharacterId = string;

  //Generic ESO character class -> Inherit in each addon's plugin
  TESOCharacter = class abstract
  strict private
    FName:            String;
    FId:              TESOCharacterId;
    FAsset_ap:        Integer;
    FAsset_wv:        Integer;
    FAsset_gold:      Integer;
    FAsset_tv:        Integer;
    FAsset_bagSpace:  TESOBagSpace;

  public
    property Name:  String read FName write FName;
    property ID:    TESOCharacterId read FId write FId;
    //Assets
    property Asset_ap: Integer read FAsset_ap write FAsset_ap;
    property Asset_wv: Integer read FAsset_wv write FAsset_wv;
    property Asset_tv: Integer read FAsset_tv write FAsset_tv;
    property Asset_gold: Integer read FAsset_gold write FAsset_gold;
    property Asset_bagSpace: TESOBagSpace read FAsset_bagSpace write FAsset_bagSpace;

    constructor Create( const AName: String = ''; const AID: TESOCharacterId = '' );
    destructor  Destroy(); override;
  end;

implementation

{ TESOCharacter }

constructor TESOCharacter.Create(const AName: String = ''; const AID: TESOCharacterId = '');
begin
  inherited Create;

  FName := AName;
  FID   := AId;
end;

destructor TESOCharacter.Destroy;
begin
  inherited Destroy;
end;

end.
