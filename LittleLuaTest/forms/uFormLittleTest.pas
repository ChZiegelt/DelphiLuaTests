unit uFormLittleTest;

interface

uses
  {$REGION 'Uses'}
    System.SysUtils
  , System.Types
  , System.UITypes
  , System.Classes

  , System.Generics.Collections
  , Lua
  // IIFA
  , IIFA.Helper
  , IIFA.Account

  // Zum Formular gehörend
  , System.Variants
  , FMX.Types
  , FMX.Controls
  , FMX.Forms
  , FMX.Graphics
  , FMX.Dialogs
  , FMX.ScrollBox
  , FMX.Memo
  , FMX.Controls.Presentation
  , FMX.StdCtrls
  ;
  {$ENDREGION}

type


  TForm1 = class(TForm)
    memo: TMemo;
    Button2: TButton;
    procedure Button2Click(Sender: TObject);
  private

    IifaHelper: TIIFAHelper;

    procedure ParseTable(const aTable: ILuaTable);

    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;

  public

  end;

var
  Form1: TForm1;


implementation


{$R *.fmx}


procedure TForm1.ParseTable( const aTable: ILuaTable );
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




procedure TForm1.AfterConstruction;
begin
  inherited;
  //Create InventoryInsightFromAshes file parser and specify the filename of the IIfA SavedVariables
  IifaHelper := TIIFAHelper.Create;

end;



procedure TForm1.BeforeDestruction;
begin
  FreeAndNil(IifaHelper);

  inherited;
end;

procedure TForm1.Button2Click(Sender: TObject);
var
  lAccount: TIifaAccount;
  lStrings: TStrings;
begin
  IifaHelper.ParseFile();

  // Ausgeben
  memo.Lines.Clear;
  for lAccount in IifaHelper.Accounts.Values do
  begin
    lStrings := lAccount.ToStrings();
    memo.Lines.AddStrings( lStrings );
    FreeAndNil(lStrings);
  end;
end;

end.
