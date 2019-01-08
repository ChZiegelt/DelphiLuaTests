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

  // ESO
  , ESO.Character
  ;
 {$ENDREGION}

type
  TESOAccountName = String;

  TESOAccount = class abstract ( TList< TESOCharacter >  )
  strict private
    FDisplayName: TESOAccountName;
    //RServer: TESOServer;

  public
    property DisplayName: TESOAccountName read FDisplayName write FDisplayName;
    //property Server: TESOServer read RServer write RServer;

    //Override this function to parse the lua table with account data for the character data
    procedure ParseCharacters(const AAccount: ILuaTable); virtual; abstract;

    constructor Create( const ADisplayName: String = '');
    destructor Destroy(); override;
  end;



implementation

{ TESOAccount }

constructor TESOAccount.Create(const ADisplayName: String = '');
begin
  inherited Create;

  FDisplayName := ADisplayName;
end;

destructor TESOAccount.Destroy;
begin
  inherited Destroy;
end;

end.
