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

  ;

type
  TIIFAHelper = class
  strict private
    FLua: TLua;

    FData: TIifaData;
    FSettings: TIifaSettings;
    FFileName: String;

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
  IIFA_SERVER_DATA[1][1] := SERVER_NA;
  IIFA_SERVER_DATA[1][2] := SERVER_NA_IP;
  IIFA_SERVER_DATA[1][3] := SERVER_ANNOUNCEMENTS_URL;
  //EU
  IIFA_SERVER_DATA[2][1] := SERVER_EU;
  IIFA_SERVER_DATA[2][2] := SERVER_EU_IP;
  IIFA_SERVER_DATA[2][3] := SERVER_ANNOUNCEMENTS_URL;
  //PTS
  IIFA_SERVER_DATA[3][1] := SERVER_PTS;
  IIFA_SERVER_DATA[3][2] := SERVER_PTS_IP;
  IIFA_SERVER_DATA[3][3] := SERVER_ANNOUNCEMENTS_URL;

  //Build the server name to index mapping
  IIFA_SERVER_MAPPING := TStringList.Create;
  IIFA_SERVER_MAPPING.Values[SERVER_NA]  := '1';
  IIFA_SERVER_MAPPING.Values[SERVER_EU]  := '2';
  IIFA_SERVER_MAPPING.Values[SERVER_PTS] := '3';

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
  Data.Table     := FLua.GetGlobalVariable('IIfA_Data').AsTable;

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
