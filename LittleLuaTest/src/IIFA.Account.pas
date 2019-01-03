unit IIFA.Account;

interface

uses
  {$REGION 'Uses'}
    System.SysUtils
  , System.Types
  , System.UITypes
  , System.Classes

  , System.Generics.Collections
  , Lua

  , IIFA.Constants
  , IIFA.Character

  ;

type
  // Klasse für Accounts aus LUA Dateien
  TIIfAAccount = class( TList< TIifaCharacter >  )
  strict private
    FDisplayName: String;
  public
    property DisplayName: String read FDisplayName write FDisplayName;

    procedure ParseCharacters(const AAccount: ILuaTable);
    function toStrings(): TStrings;

    constructor Create( const ADisplayName: String );
  end;


implementation

{ TAccount }

constructor TIifaAccount.Create(const ADisplayName: String);
begin
  inherited Create;

  FDisplayName := ADisplayName;
end;



procedure TIifaAccount.ParseCharacters(const AAccount: ILuaTable);
var
  enumCharacter, enumSettings: ILuaTableEnumerator;
  pair: TLuaKeyValuePair;
  lTable: ILuaTable;

  lCharacter: TIifaCharacter;

begin
  // Wenn nicht nil, versuche den Inhalt zu verstehen
  if not Assigned(AAccount) then
     exit;

  // Parse table of account
  enumCharacter := AAccount.GetEnumerator;

  // Iterate through subentries (characters)
  while enumCharacter.MoveNext do
  begin
    pair := enumCharacter.Current;

    lCharacter := TIifaCharacter.Create;
    lCharacter.ID := pair.Key.AsString;

    lTable := pair.Value.AsTable;
    enumSettings := lTable.GetEnumerator;

    // Iterate through character settings
    while enumSettings.MoveNext do
    begin
      pair := enumSettings.Current;

      // Check if the entry is the last known character name
      if pair.Key.AsString = LAST_CHAR_NAME then
      begin
        lCharacter.Name := pair.Value.AsString;
      end;
    end;
    //Add the character to the character list of the current account
    Add( lCharacter );
  end;
end;


function TIifaAccount.toStrings: TStrings;
var
  lCharacter: TIifaCharacter;
begin
  Result := TStringList.Create;

  Result.Add(Self.DisplayName);

  for lCharacter in Self do
  begin
    Result.Add( lCharacter.toString() );
  end;
end;


end.
