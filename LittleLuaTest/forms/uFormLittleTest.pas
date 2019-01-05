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
  , IIFA.Account
  , IIFA.GuildBank
  , IIFA.Helper

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
  IIfAHelper := TIIFAHelper.Create;

end;



procedure TForm1.BeforeDestruction;
begin
  FreeAndNil(IifaHelper);

  inherited;
end;

procedure TForm1.Button2Click(Sender: TObject);
var
  lAccount: TIIfAAccount;
  lItem:    TESOItemData;
  lItemList:  TList<TESOItemData>;
  lGuildBank: TIIfAGuildBank;
  lStrings: TStrings;
begin
  //Parse the IIfA.lua SavedVariables file if given
  if not String.IsNullOrEmpty(IIfAHelper.FileName) and FileExists(IIfAHelper.FileName) then
  begin
    IifaHelper.ParseFile();

    ////////////////////
    //    OUTPUT      //
    ////////////////////

    // AccountName
    //   Charaktername, CharakterId, Einstellung GildenBankLesen, Gold und andere Vermögen
    memo.Lines.Clear;


    memo.Lines.Add('[Accounts & characters]');
    for lAccount in IifaHelper.Accounts.Values do
    begin
      lStrings := lAccount.ToStrings();
      memo.Lines.AddStrings( lStrings );
      FreeAndNil(lStrings);
    end;

    //Guild Banks
    memo.Lines.Add('');
    memo.Lines.Add('[Guild Banks]');
    for lGuildBank in IifaHelper.GuildBanks.Values do
    begin
      memo.Lines.Add( lGuildBank.toString() );
    end;

    //Items
    memo.Lines.Add('');
    memo.Lines.Add('[Items]');
    lItemList := IifaHelper.Items.GetItemList();
    if Assigned(lItemList)  then
      for lItem in lItemList do
      begin
        memo.Lines.Add( lItem.toString() );
      end;

  end;
end;

end.
