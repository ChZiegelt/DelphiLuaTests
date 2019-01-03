unit IIFA.Settings;

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
  , IIFA.Account

  ;

type

  TIIfASettings = class( TList<TIifaAccount> )
  strict private
    FTable: ILuaTable;
    procedure setTable(const Value: ILuaTable);
  public
    property Table: ILuaTable read FTable write setTable;
  end;

implementation

{ TIifaSettings }

procedure TIifaSettings.setTable(const Value: ILuaTable);
var
  enum, enumAccounts: ILuaTableEnumerator;
  pair: TLuaKeyValuePair;
  pairAccounts: TLuaKeyValuePair;

  lTable: ILuaTable;

  lAccount: TIifaAccount;

begin
  FTable := Value;

  // Wenn nicht nil, versuche den Inhalt zu verstehen
  if not Assigned(Value) then
     exit;

  // Parse die Arrays unterhalb von IIfA_Settings
  enum := Value.GetEnumerator;

  //Get next entry of IIfA_Settings
  while enum.MoveNext do
  begin
    pair := enum.Current;

    //Is entry "Default" of IIfA_Settings?
    if pair.Key.AsString = BASE_SAVEDVARS_NAME then
    begin
      lTable := pair.Value.AsTable;
      enumAccounts := lTable.GetEnumerator;

      // Iteriere durch die Accounts
      while enumAccounts.MoveNext do
      begin
        pairAccounts := enumAccounts.Current;
        lAccount := TIifaAccount.Create( pairAccounts.Key.AsString.Replace('@', '') );
        Self.Add( lAccount );

        // Passend zum Account die Charaktere laden
        lAccount.ParseCharacters( pairAccounts.Value.AsTable );
      end;
    end;
  end;
end;

end.
