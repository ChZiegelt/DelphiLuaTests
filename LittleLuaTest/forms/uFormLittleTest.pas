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

  // ESO
  , ESO.ItemData

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

    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;

  public

  end;

var
  Form1: TForm1;


implementation


{$R *.fmx}
{$R *.Surface.fmx MSWINDOWS}
{$R *.Windows.fmx MSWINDOWS}

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
  lItem:    TESOItemData;
  lItemList:  TList<TESOItemData>;
  lStrings: TStrings;
begin
  IifaHelper.ParseFile();

  // Ausgeben:
  // AccountName
  //   Charaktername, CharakterId, Einstellung GildenBankLesen, Gold und andere Vermögen
  memo.Lines.Clear;
  for lAccount in IifaHelper.Accounts.Values do
  begin
    lStrings := lAccount.ToStrings();
    memo.Lines.AddStrings( lStrings );
    FreeAndNil(lStrings);
  end;

  //Items
  lItemList := IifaHelper.Items.GetItemList();
  if Assigned(lItemList)  then
    for lItem in lItemList do
    begin
      memo.Lines.Add( lItem.toString() );
    end;

end;

end.
