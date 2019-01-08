unit uFormLittleGridTest;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, System.Rtti,
  FMX.Grid.Style, FMX.Controls.Presentation, FMX.ScrollBox, FMX.Grid;

type
  TformGrid = class(TForm)
    sgrid: TStringGrid;
    StringColumn1: TStringColumn;
    StringColumn2: TStringColumn;
    StringColumn3: TStringColumn;
    StringColumn4: TStringColumn;
    StringColumn5: TStringColumn;
    DateColumn1: TDateColumn;
    TimeColumn1: TTimeColumn;
    IntegerColumn1: TIntegerColumn;
    IntegerColumn2: TIntegerColumn;
    IntegerColumn3: TIntegerColumn;
    IntegerColumn4: TIntegerColumn;
    IntegerColumn5: TIntegerColumn;
    procedure sgridCellClick(const Column: TColumn; const Row: Integer);

  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  formGrid: TformGrid;

implementation

{$R *.fmx}

uses  uFormLittleTest,
      uFormImage,
      ESO.ItemData;

procedure TformGrid.sgridCellClick(const Column: TColumn; const Row: Integer);
var
  lItemIdStr: String;
  lItem: TESOItemData;
  lPicture: TBitMap;
begin
  //Get the itemId of the clicked line
  if Row <> -1 then
  begin
    if sgrid.Cells[3, Row] <> '' then
    begin
      lItemIdStr := sgrid.Cells[3, Row];
      //Get the TESOItemData object of the clicked row
      lItem := formMemo.IIfaHelper.Items.byItemId[lItemIdStr.ToInteger()];
      if Assigned(lItem) then
      begin
        //Get image from UESP.net
        try
          lPicture := lItem.GetItemImageByItemId(lItemIdStr.ToInteger());
          if Assigned(lPicture) then
          begin
            formEsoImage.imgItemImage.Bitmap.Assign(TBitmap(lPicture));
            formEsoImage.Visible := False;
            formEsoImage.Show();
          end;
        finally
          lPicture.Free;
        end;
      end;
    end;
  end;
end;

end.
