unit IIFA.Helper;

interface

uses
  {$REGION 'Uses'}
    System.SysUtils
  , System.Types
  , System.UITypes
  , System.Classes

  , System.Generics.Collections
  , Lua

  , ESO.Constants
  , IIFA.Constants
  , IIFA.Data
  , IIFA.Settings

  , IIFA.Character
  , IIFA.Account
  , IIFA.Server
  , ESO.ItemData

  ;

type
  TIIFAHelper = class
  strict private
    FLua: TLua;

    FData: TIifaData;
    FSettings: TIifaSettings;
    FFileName: String;

    FAccounts:    TList<TIifaAccount>;
    FCharacters:  TList<TIifaCharacter>;
    FServers:     TDictionary<String, TIIFAServer>;

    FItems:       TESOItemDataHandler;//TLIst<TESOItemData>;


    procedure ParseTable(const aTable: ILuaTable);
  public
    property Data: TIifaData read FData write FData;
    property Settings: TIifaSettings read FSettings write FSettings;

    property FileName: String read FFileName write FFileName;

    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;

    function ParseFile(const AFileName: String = ''): Boolean;
  end;




implementation


{ TIIFAHelper }

procedure TIIFAHelper.AfterConstruction;
begin
  inherited;
  //Build some constant values
  //Create the server type entries if they are not already created
  //NA

  FServers := TDictionary<String, TIifaServer>.Create(3);
  FServers.Add(SERVER_NA, TIifaServer.Create( SERVER_NA, SERVER_NA_IP, SERVER_ANNOUNCEMENTS_URL) );
  FServers.Add(SERVER_EU, TIifaServer.Create( SERVER_EU, SERVER_EU_IP, SERVER_ANNOUNCEMENTS_URL) );
  FServers.Add(SERVER_PTS, TIifaServer.Create( SERVER_PTS, SERVER_PTS_IP, SERVER_ANNOUNCEMENTS_URL) );

  //Load the LUAWrapper library
  FLua := TLua.Create;
  //Load additional lua libraries like String handling, OS, etc.
  //FLua.AutoOpenLibraries := [Base, StringLib {, ...}];

  //Create the instances of Settings
  FSettings := TIifaSettings.Create;
  //Create the instances of Data
  FData     := TIifaData.Create();
end;


procedure TIIFAHelper.BeforeDestruction;
begin
  FreeAndNil( FData );
  FreeAndNil( FSettings );

  FreeAndNil( FLua );

  inherited;
end;



function TIIFAHelper.ParseFile(const AFileName: String = ''): Boolean;
var
  lFile: String;

  lTable: ILuaTable;
  enum: ILuaTableEnumerator;
  pair: TLuaKeyValuePair;

  List: TStringList;
  lAccountIdx, lCharacterIdx: Integer;

begin
  Result := False;

  if AFileName.IsEmpty then
     lFile := FFileName
  else
     lFile := AFileName;

  if not FileExists(lFile) then
     exit(False);

  //Clear the old entries in Settings and Data tables
  Settings.Clear;
  Data.Clear;

  //LoadFromFile is not able to use UTF8 conversion properly!
  //FLua.LoadFromFile( lFile, True );
  //Workaround over TStringList to support UTF8 files w/o BOM
  List := TStringList.Create;
  List.LoadFromFile( lFile );
  FLua.LoadFromString( System.UTF8ToString( List.Text ));
  List.Free;

  // Jetzt die Arrays aufdröseln und in Delphi Objekte speichern
  //->Beim Verwenden von .Table := wird die in der Klasse IifaSettings gesetzte "write" Methode "setTable" aufgerufen!
  Settings.Table := FLua.GetGlobalVariable('IIfA_Settings').AsTable;

  // Es existiert jetzt eine Liste von Accounts und Characters
  //IIFa_Settings->Accounts->Characters
  // Verschiebe jetzt die Character und Accounts in die Liste des Helpers
  for lAccountIdx := 0 to Settings.Count -1 do
  begin
    FAccounts.Add( Settings.ExtractAt( lAccountIdx ) );

    for lCharacterIdx := 0 to FAccounts[ lAccountIdx ].Count -1 do
        FCharacters.Add( FAccounts[ lAccountIdx ].ExtractAt( lCharacterIdx ) );
  end;

 // FItems.byLink['2345'].

  //IIFa_Data->Accounts->AccountWide->Server->DatenbankVersion->Item->Location->Characters/Bag
  //DataTable     := FLua.GetGlobalVariable('IIfA_Data').AsTable;

  // Diese Methode füllt dann Server[], Items[]
  //ParseDataTable( DataTable );
  // Durchsuchen von Servern und Pürfen ob vorhanden (nur Dictionary)
//  if FServers.ContainsKey('serverPair.Key.ToString') then
//     lServer := FServers.Items['serverPair.Key.ToString'];

  // Durchsuchen von Accounts und Pürfen ob vorhanden
//  for lAccount in FAccounts do
//  begin
//    if lAccount.DisplayName = "Wahtever" then
//    begin
//   end;
//  end;



  FFileName := lFile;
  Result := true;
end;


//Not needed yet
procedure TIIFAHelper.ParseTable( const aTable: ILuaTable );
var
  enum: ILuaTableEnumerator;
  pair: TLuaKeyValuePair;

begin
  enum := aTable.GetEnumerator;

  while enum.MoveNext do
  begin
    pair := enum.Current;

    case pair.Value.VariableType of
      VariableNone: begin

      end;

      VariableBoolean: begin

      end;

      VariableInteger, VariableNumber: begin

      end;

      VariableString: begin

      end;

      VariableTable, VariableUserData: begin
        ParseTable( Pair.Value.AsTable );

      end;

      VariableFunction: begin

      end;

    end;
  end;
end;


end.
