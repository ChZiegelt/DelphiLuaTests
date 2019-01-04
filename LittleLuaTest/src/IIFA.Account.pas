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

  , ESO.Account
  , ESO.Character

  , IIFA.Constants
  , IIFA.Character

  ;
 {$ENDREGION}

type
  // Class for read accounts from IIFA.lua SavedVariables file
  TIIfAAccount = class( TESOAccount )
  strict private
  public
    procedure ParseCharacters(const AAccount: ILuaTable); override;
    function toStrings(): TStrings;
  end;

  // Durchsuchen von Accounts und Prüfen ob account mit Name vorhanden
//  for lAccount in FAccounts do
//  begin
//    if lAccount.DisplayName = "Wahtever" then
//    begin
//   end;
//  end;


implementation

{ TIIfAAccount }


procedure TIifaAccount.ParseCharacters(const AAccount: ILuaTable);
var
  enumCharacter, enumSettings: ILuaTableEnumerator;
  pair: TLuaKeyValuePair;
  lTable: ILuaTable;

  lCharacter: TIIfACharacter;

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

    lCharacter := TIifaCharacter.Create('', pair.Key.AsString);

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


function TIIfAAccount.toStrings: TStrings;
var
//  lCharacter: TIIfACharacter;
  lCharacter: TESOCharacter;
begin
  Result := TStringList.Create;

  Result.Add(Self.DisplayName);

  for lCharacter in Self do
  begin
    Result.Add( TIIfACharacter(lCharacter).toString() );
  end;
end;


end.
