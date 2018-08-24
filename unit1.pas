unit Unit1;

  (*
   enthält nützliche Routine zur Überprüfung eines Datums-Strings auf Zahlen und Datumspunkt.
   Siehe:
   procedure DateEditEditingDone(Sender: TObject);
   *)

{$mode objfpc}{$H+}



interface

uses
  locale_de, UniqueInstance, Classes, SysUtils, FileUtil, Forms, Controls,
  Graphics, Dialogs, EditBtn, IniPropStorage, StdCtrls, DateUtils,
  PropertyStorage, Menus, Interfaces, cwstring;

type

  { TForm1 }

  TForm1 = class(TForm)
    btnCalc: TButton;
    DateEditVon: TDateEdit;
    DateEditBis: TDateEdit;
    MenuItem1: TMenuItem;
    TempEdit: TEdit;
    IniPropStorage1: TIniPropStorage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    ListBox1: TListBox;
    EmptyLisBox1: TMenuItem;
    PopupListBox1: TPopupMenu;
    UniqueInstance1: TUniqueInstance;
    procedure btnCalcClick(Sender: TObject);
    procedure DateEditEditingDone(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure IniPropStorage1StoredValues0Restore(Sender: TStoredValue;
      var Value: TStoredType);
    procedure IniPropStorage1StoredValues0Save(Sender: TStoredValue;
      var Value: TStoredType);
    procedure IniPropStorage1StoredValues1Restore(Sender: TStoredValue;
      var Value: TStoredType);
    procedure IniPropStorage1StoredValues1Save(Sender: TStoredValue;
      var Value: TStoredType);
    procedure EmptyLisBox1Click(Sender: TObject);
    procedure MenuItem1Click(Sender: TObject);
    procedure UniqueInstance1OtherInstance(Sender: TObject;
      ParamCount: Integer; Parameters: array of String);
  private
    { private declarations }
  public
    { public declarations }
    procedure DateDiff(Date1, Date2: TDateTime; var Days, Months, Years: word);

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

procedure TForm1.FormCreate(Sender: TObject);
begin
  INIPropStorage1.IniFileName := ChangeFileExt(Application.ExeName, '.ini');
end;

procedure TForm1.btnCalcClick(Sender: TObject);
var
  D, M, Y: word;
  s: string;
begin
  try
    (* Fehler abfangen *)
    if DateEditVon.Date = DateEditBis.Date then
    begin
      s := 'Von Datum und bis Datum sind gleich, da gibts nichts zu berechnen!';
      exit;
    end;

    (* Fehler abfangen *)
    if DateEditVon.Date > DateEditBis.Date then
    begin
      s := 'Von Datum liegt nach(!) dem bis Datum, da gibts nichts zu berechnen!';
      exit;
    end;


    PeriodBetween(DateEditVon.Date, DateEditBis.Date, Y, M, D);
    //DateDiff(DateEditVon.Date, DateEditBis.Date, D, M, Y);

    S := 'Zwischen dem ' + FormatDateTime('dd.mm.yyyy', DateEditVon.Date) +
      ' und ' + FormatDateTime('dd.mm.yyyy', DateEditBis.Date) + ' liegen';

    if Y > 0 then
      s := s + ' ' + IntToStr(y) + ' Jahre';

    if M > 0 then
      s := s + ' ' + IntToStr(M) + ' Monate';

    if D > 0 then
      s := s + ' ' + IntToStr(D) + ' Tage';

  finally
    ListBox1.Items.Add(s);
  end;

end;

procedure TForm1.DateEditEditingDone(Sender: TObject);
var
  x: integer;
  s : string;
  AcceptDate : boolean;
begin

  (* nix machen, wenn noch nichts eingegeben wurde *)
  if trim((Sender as TDateEdit).Text) = '' then exit;


    try
      (* Edit.Text auf gültige Zeichen überprüfen:
         Ein Datum darf ja nur aus Zahlen und Datumspunkt bestehen! *)
      for x := 1 to length((Sender as TDateEdit).Text) do
      begin

        //ShowMessage('Geprüft wird: ' + (Sender as TDateEdit).Text[x]);

        s := (Sender as TDateEdit).Text[x];

        AcceptDate := False;

        (* Zeichen in Integer konvertieren, bei Fehler noch auf den Datumspunkt überprüfen *)
        try
          case StrToInt(s) of
            0..9:
            begin
              AcceptDate := True;
            end;
          end;

        except
          (* wars evtl. doch nur der Datumspunkt? *)
          on EConverterror do
          begin
            if s = '.' then
            begin
              AcceptDate := True;
            end
            else
            begin
              AcceptDate := False;
              exit;
            end;
          end;
        end;
      end;

    finally
      if not AcceptDate then
      begin
        (Sender as TDateEdit).SetFocus;
        (* falsches Zeichen markieren *)
        (Sender as TDateEdit).SelStart:=x -1;
        (Sender as TDateEdit).SelLength:=1;
        ShowMessage('Falsche Zeichen in Datumseingabe!');
      end;
    end;

end;

procedure TForm1.IniPropStorage1StoredValues0Restore(Sender: TStoredValue;
  var Value: TStoredType);
begin
  (* Datum aus Ini oder 10 Tage zurück *)
  if FileExists(IniPropStorage1.IniFileName) then
    DateEditVon.Date := StrToDateTime(Value)
  else
    DateEditVon.Date := Date - 10;
end;

procedure TForm1.IniPropStorage1StoredValues0Save(Sender: TStoredValue;
  var Value: TStoredType);
begin
  Value := DateTimeToStr(DateEditVon.Date);
end;

procedure TForm1.IniPropStorage1StoredValues1Restore(Sender: TStoredValue;
  var Value: TStoredType);
begin
  (* aktuelles Datum *)
  DateEditBis.Date := Date;
end;

procedure TForm1.IniPropStorage1StoredValues1Save(Sender: TStoredValue;
  var Value: TStoredType);
begin
  Value := DateTimeToStr(DateEditBis.Date);
end;

procedure TForm1.EmptyLisBox1Click(Sender: TObject);
begin
  ListBox1.Items.Clear;
end;

procedure TForm1.MenuItem1Click(Sender: TObject);
begin
  try
    TempEdit.Text := ListBox1.Items[ListBox1.ItemIndex];
    TempEdit.Width := 0;
    TempEdit.Visible := True;
    TempEdit.SetFocus;
    TempEdit.SelectAll;
    TempEdit.CopyToClipboard;
    ShowMessage('Die Zeile:' + NL + NL + TempEdit.Text + NL + NL + 'wurde kopiert!');

  finally
    ListBox1.SetFocus;
  end;
end;

procedure TForm1.UniqueInstance1OtherInstance(Sender: TObject;
  ParamCount: Integer; Parameters: array of String);
begin
  Application.Restore;
  Application.MainForm.SetFocus;
end;

{* kopiert aus Jedi \jvcl\run\JvJCLUtils.pas *}
procedure TForm1.DateDiff(Date1, Date2: TDateTime; var Days, Months, Years: word);
{ Corrected by Anatoly A. Sanko (2:450/73) }
var
  DtSwap: TDateTime;
  Day1, Day2, Month1, Month2, Year1, Year2: word;
begin
  if Date1 > Date2 then
  begin
    DtSwap := Date1;
    Date1 := Date2;
    Date2 := DtSwap;
  end;
  DecodeDate(Date1, Year1, Month1, Day1);
  DecodeDate(Date2, Year2, Month2, Day2);
  Years := Year2 - Year1;
  Months := 0;
  Days := 0;
  if Month2 < Month1 then
  begin
    Inc(Months, 12);
    Dec(Years);
  end;
  Inc(Months, Month2 - Month1);
  if Day2 < Day1 then
  begin
    Inc(Days, DaysInAMonth(Year1, Month1));
    if Months = 0 then
    begin
      Dec(Years);
      Months := 11;
    end
    else
      Dec(Months);
  end;
  Inc(Days, Day2 - Day1);
end;


end.
