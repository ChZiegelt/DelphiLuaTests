unit ESO.Character;

interface

uses
  {$REGION 'Uses'}
    System.SysUtils
  , System.Types
  , System.UITypes
  , System.Classes

  , System.Generics.Collections

  ;

  type

  TESOCharacterId = string;

  //Generic ESO character class -> Inherit in each addon's plugin
  TESOCharacter = class abstract
  strict private
    FName:  String;
    FID:    TESOCharacterId;

  public
    property Name:  String read FName write FName;
    property ID:    TESOCharacterId read FID write FID;

    constructor Create( const AName: String = ''; const AID: TESOCharacterId = '' );
    destructor  Destroy();
  end;

implementation

{ TESOCharacter }

constructor TESOCharacter.Create(const AName: String = ''; const AID: TESOCharacterId = '');
begin
  inherited Create;

  FName := AName;
  FID   := AID;
end;

destructor TESOCharacter.Destroy;
begin
  inherited Destroy;
end;

end.
