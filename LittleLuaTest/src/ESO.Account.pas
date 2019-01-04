unit ESO.Account;

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
  TESOAccountName = String;

  TESOAccount = class abstract ( TList< TESOCharacter >  )
  strict private
    FDisplayName: TESOAccountName;
  public
    property DisplayName: TESOAccountName read FDisplayName write FDisplayName;

    //Override this function to parse the lua table with account data for the character data
    procedure ParseCharacters(const AAccount: ILuaTable); virtual; abstract;

    constructor Create( const ADisplayName: String );
  end;



implementation

{ TESOAccount }

constructor TESOAccount.Create(const ADisplayName: String);
begin
  inherited Create;

  FDisplayName := ADisplayName;
end;

end.
