unit uAIDB;
interface

uses
	Classes, SysUtils;//, Windows;

type

	TAIDBSection = class
    //
    Count:cardinal;
    SubItems:array of TAIDBSection;
    Name:string;
    Value:string;
    Parent:TAIDBSection;
    //
    function AddSubItem(iName:string): TAIDBSection;
    function FindSubItem(iName:string): TAIDBSection;
    function FindSubItemI(iName:string): integer;
    function GetSubItem(iName:string): TAIDBSection;
    function GetSubItems(iPath:array of string): TAIDBSection;
    //
    function GetValue(iName, DefValue:string):string;
    function GetIntValue(iName:string; DefValue:integer):integer;
    function GetBoolValue(iName:string; DefValue:boolean):boolean;

    function SetValue(iName, iValue:string):TAIDBSection;
    function SetIntValue(iName:string; iValue:integer):TAIDBSection;
    function SetBoolValue(iName:string; iValue:boolean):TAIDBSection;
    //
    procedure GetSource(sl:TStrings);
    procedure LoadFromFile(const FileName:string);
    procedure SaveToFile(const FileName:string);
    function ReadSource(sl:TStrings; ln:Integer=0):Integer;
    //
    procedure ClearSubItems;
    procedure DeleteSubItem(iName:string);
    procedure DeleteSubItemN(indx:integer);
    //
    function FindItem(Index: Cardinal): TAIDBSection;
    procedure SetItem(Index: Cardinal; const Value: TAIDBSection);
    //
    property Items[Index: Cardinal]: TAIDBSection read FindItem write SetItem; default;
    //
    constructor Create;
    destructor Destroy; override;
  end;

implementation

function TAIDBSection.GetBoolValue(iName:string; DefValue:boolean):boolean;
begin
	result:=boolean(GetIntValue(iName, integer(DefValue)));

end;

function TAIDBSection.GetIntValue(iName:string; DefValue:integer):integer;
begin
  result:=strtoint(GetValue(iName, inttostr(DefValue)));
end;

function TAIDBSection.SetBoolValue(iName:string; iValue:boolean):TAIDBSection;
begin
  //
  result:=SetIntValue(iName, integer(iValue));
end;

function TAIDBSection.SetIntValue(iName:string; iValue:integer):TAIDBSection;
begin
  result:=SetValue(iName, inttostr(iValue));
end;

function TAIDBSection.GetValue(iName, DefValue:string):string;
var
	Sec:TAIDBSection;
begin
  //
  sec:=FindSubItem(iName);
  if sec<>nil then
  begin
    result:=sec.Value;
    exit;
  end;
  result:= DefValue;
end;

function TAIDBSection.SetValue(iName, iValue:string):TAIDBSection;
begin
  //
  result:=GetSubItem(iName);
  result.Value:=iValue;
end;


procedure TAIDBSection.LoadFromFile(const FileName:string);
var
	db:TStringList;
begin
  //
  ClearSubItems;
  db:=TStringList.Create;
  db.LoadFromFile(FileName);
  if db.Count>0 then
  	ReadSource(db);
  db.Free;
end;

procedure TAIDBSection.SaveToFile(const FileName:string);
var
	db:TStringList;
begin
  //
  db:=TStringList.Create;
  GetSource(db);
  db.SaveToFile(FileName);
  db.Free;
end;

procedure FixupReadedValue(var Value:string);
begin
  //
  if Length(Value)<=1 then
	  exit;

  if (Value[1]='\') then
    Delete(Value, 1, 1);

end;

function TAIDBSection.ReadSource(sl:TStrings; ln:Integer=0):Integer;
var
	i:Integer;
  Len:Integer;
  bNameReaded:boolean;
  str:string;
  Sec:TAIDBSection;
  slc:Integer;
begin
  //
  slc:=sl.Count;
  if ln>slc then
  	exit;
    
  bNameReaded:=false;
  result:=ln;
  i:=ln-1;

  //for i := ln to sl.Count do
  repeat
  	i:=i+1;
    if i>slc then
    begin
    	Result:=i;
	  	exit;
    end;
      
  	Len:=Length(sl.Strings[i]);
  	if Len=0 then
    	continue;

    if sl.Strings[i][1]='>' then
    begin
	    str:=Copy(sl.Strings[i],3, Len-3);
    	if bNameReaded=false then
      begin
        Name:=str;
        bNameReaded:=true;
        continue;
      end;

      Sec:=AddSubItem('');
      i:=Sec.ReadSource(sl, i);
      continue;
      
    end
    else
    if sl.Strings[i][1]='<' then
    begin
    	Result:=i;
    	exit;
    end
    else
    begin // unspec symb
      if bNameReaded then
      begin
      	Value:=sl.Strings[i];
        FixupReadedValue(Value);
      end;
    end;
  until false;
    
end;

procedure TAIDBSection.GetSource(sl:TStrings);
var
	i:Cardinal;
begin
	sl.Add('>['+Name+']');
  if Length(Value)>0 then
  begin
    if (Value[1]='<') or (Value[1]='>') or (Value[1]='\') then
    begin
    	sl.Add('\' + Value);
    end
    else
    begin
	  	sl.Add(Value);
    end;
  end;

  
  if Count>0 then
  for i := 0 to Count - 1 do
  begin
  	SubItems[i].GetSource(sl);
  end;
  sl.Add('<[/'+Name+']');
end;


function TAIDBSection.GetSubItems(iPath:array of string): TAIDBSection;
var
	Sec:TAIDBSection;
  i:Cardinal;
begin
  //
  if Length(iPath)=0 then
  begin
    result:=nil;
    exit;
  end;
  Sec:=self;
  for i := 0 to Length(iPath) - 1 do
  begin
    //
    Sec:=sec.GetSubItem(iPath[i]);
  end;
  result:=Sec;
end;


function TAIDBSection.GetSubItem(iName:string): TAIDBSection;
begin
  //
  result:=FindSubItem(iName);
  if result<>nil then
  	exit;

  result:=AddSubItem(iName);
end;

function TAIDBSection.FindSubItem(iName:string): TAIDBSection;
var
	i:Cardinal;
begin
	result:=nil;
	if Count=0 then
  	exit;

	for i := 0 to Count - 1 do
  begin
    if SubItems[i].name = iName then
    begin
      result:=SubItems[i];
      exit;
    end;
  end;

end;

function TAIDBSection.FindSubItemI(iName: string): integer;
var
	i:Cardinal;
begin
	result:=-1;
	if Count=0 then
  	exit;

	for i := 0 to Count - 1 do
  begin
    if SubItems[i].name = iName then
    begin
      result:=i;
      exit;
    end;
  end;
end;

function TAIDBSection.AddSubItem(iName:string): TAIDBSection;
var
	indx:Cardinal;
begin
  //
  indx:=Count;
  Count:=Count+1;
  SetLength(SubItems, Count);
  
  SubItems[indx]:=TAIDBSection.Create;
  result:=SubItems[indx];
  result.Name:=iName;
  result.Parent:=self;
end;
//

function TAIDBSection.FindItem(Index: Cardinal): TAIDBSection;
begin
  result:=SubItems[index];
end;

procedure TAIDBSection.SetItem(Index: Cardinal; const Value: TAIDBSection);
begin
  SubItems[index]:=Value;
end;

procedure TAIDBSection.DeleteSubItemN(indx:integer);
begin
  //
  assert((indx>=0) and (indx < Count));
  SubItems[indx].Free;

  Count:=Count-1;
  if indx < Count then
  begin
    Move(SubItems[indx + 1], SubItems[indx], (Count - indx) * SizeOf(TAIDBSection));
    //FillChar(SubItems[Count], SizeOf(TAIDBSection), 0);
  end;
  SetLength(SubItems, Count);

end;

procedure TAIDBSection.DeleteSubItem(iName:string);
var
	i:integer;
  nIdx:integer;
begin

	if Count=0 then
  	exit;

  nIdx := -1;
	for i := 0 to Count - 1 do
  begin
    if SubItems[i].name = iName then
    begin
    	nIdx:=i;
      break;
    end;
  end;
  if nIdx=-1 then
  	exit;

  DeleteSubItemN(nIdx);
end;


procedure TAIDBSection.ClearSubItems;
var
	i:Cardinal;
begin
	if Count=0 then
  	exit;
    
  for i := 0 to Count - 1 do
  begin
  	SubItems[i].Free;
  end;
  Count:=0;
  SetLength(SubItems, Count);
end;

//

constructor TAIDBSection.Create;
begin
  //
  Count:=0;
  Parent:=nil;
  SetLength(SubItems, Count);
  //OutputDebugString('created');
end;

destructor TAIDBSection.Destroy;
begin
  //
  ClearSubItems;
  //OutputDebugString('destroyed');
  inherited Destroy;
end;

end.

