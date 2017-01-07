unit Testjson;
{

  Delphi DUnit Test Case
  ----------------------
  This unit contains a skeleton test case class generated by the Test Case Wizard.
  Modify the generated code to correctly setup and call the methods from the unit 
  being tested.

}

interface

uses
  TestFramework, Variants, SysUtils, Classes, Dialogs, json, windows, dateutils;

type
  // Test methods for class TJSON

  TestTJSON = class(TTestCase)
  strict private
    function loadFile(const AFilename: string): string;
  public

  published
    procedure TestUser;
    procedure TestUserList;
    procedure TestListInListInList;
    procedure TestEmptyList;
    procedure TestMovie;
    procedure TestUnEscape;
  end;

var
  fmt: TFormatSettings;

implementation

function TestTJSON.loadFile(const AFilename: string): string;
var
  jsonFile: TextFile;
  text: string;
begin
  result := '';

  AssignFile(jsonFile, AFilename);
  try
    Reset(jsonFile);

    while not Eof(jsonFile) do
    begin
      ReadLn(jsonFile, text);
      result := result+text;
    end;
  finally
    CloseFile(jsonFile);
  end;
end;

procedure TestTJSON.TestEmptyList;
var
  j: TJSON;
begin
  with TJSON.Parse(loadFile('test4.json')) do
  begin
    try
      check(IsList = false);
      check(assigned(_['empty'].ListItems) = true);
      check(_['empty'].ListItems.count = 0);
    finally
      Free;
    end;
  end;
  with TJSON.Parse(loadFile('test5.json')) do
  begin
    try
      check(IsList = true);
      check(assigned(ListItems) = true);
      check(ListItems.count = 0, inttostr(ListItems.count));
    finally
      Free;
    end;
  end;
end;

procedure TestTJSON.TestListInListInList;
begin
  with TJSON.Parse(loadFile('test3.json')) do
  begin
    try
      check(_[0].IsList = true);
      check(_[0][0][0].AsString = 'list in a list in a list');
    finally
      Free;
    end;
  end;
end;

procedure TestTJSON.TestMovie;
begin
  with TJSON.Parse(loadFile('test6.json')) do
  try
    check(_['page'].AsInteger = 1);
    check(_['results'][0]['id'].AsInteger = 262543);
    check(_['results'][0]['id'].AsString = '262543');
    check(_['results'][0]['original_title'].AsString = 'Automata');
    check(_['results'][0]['popularity'].AsString = '6.6273989934368');
  finally
    free;
  end;
end;

procedure TestTJSON.TestUnEscape;
begin
  with TJSON.Parse('{"name": "Kurt \u00e6 bc"}') do
  try
    check(_['name'].AsString = 'Kurt � bc');
  finally
    free;
  end;
  with TJSON.Parse('{"name": "a \b b"}') do
  try
    check(_['name'].AsString = 'a '+#8+' b');
  finally
    free;
  end;
  with TJSON.Parse('{"name": "a \n b"}') do
  try
    check(_['name'].AsString = 'a '+#10+' b');
  finally
    free;
  end;
  with TJSON.Parse('{"name": "a \r b"}') do
  try
    check(_['name'].AsString = 'a '+#13+' b');
  finally
    free;
  end;
  with TJSON.Parse('{"name": "a \t b"}') do
  try
    check(_['name'].AsString = 'a '+#9+' b');
  finally
    free;
  end;
  with TJSON.Parse('{"name": "a \f b"}') do
  try
    check(_['name'].AsString = 'a '+#12+' b');
  finally
    free;
  end;

  with TJSON.Parse('{"name": "\\"}') do
  try
    check(_['name'].AsString = '\');
  finally
    free;
  end;
end;

procedure TestTJSON.TestUser;
var
  photo, item, item_a: TJSON;
  i: integer;
  fmtSettings: TFormatSettings;
begin
  GetLocaleFormatSettings(GetSystemDefaultLCID, fmtSettings);
  with TJSON.Parse(loadFile('test1.json')) do
  begin
    try
      Check(_['username'].AsString = 'thomas', _['username'].AsString);
      for i in [1,2] do
      begin
        photo := _['photos'][i-1];
        check(photo['title'].AsString = format('Photo %d', [i]), 'title is not '+format('Photo %d', [i]));
        check(assigned(photo['urls']));
        check(photo['urls']['small'].AsString = format('http://example.com/photo%d_small.jpg', [i]), 'url is not '+format('http://example.com/photo%d_small.jpg', [i]));
        check(photo['urls']['large'].AsString = format('http://example.com/photo%d_large.jpg', [i]), 'url is not '+format('http://example.com/photo%d_large.jpg', [i]));
      end;

      for i in [1,2,3] do
      begin
        item := _['int_list'][i-1];
        check(item.AsInteger = i);
      end;

      for i in [1,2,3] do
      begin
        item := _['str_list'][i-1];
        check(item.AsString = inttostr(i));
      end;

      check(_['escape_text'].AsString = 'Some "test" \\ \u00e6=�', format('%s is not Some "test" \\ \u00e6=�', [_['escape_text'].AsString]));
      check(_['escape_path'].AsString = 'C:\test\test.txt', format('%s is not C:\test\test.txt', [_['escape_path'].AsString]));

      check(_['nullvalue'].AsString = '');
    finally
      Free;
    end;
  end;
end;

procedure TestTJSON.TestUserList();
var
  users: TJSON;
  user: TJSON;
  i: integer;

  u: TJSON;
begin
  users := TJSON.Parse(loadFile('test2.json'));
  try
    check(users.ListItems.Count = 3, format('%d is not 3', [users.ListItems.Count]));
    for i in [0,1,2] do
    begin
      user := users[i];
      case i of
        0: check(user['username'].AsString = 'thomas', user['username'].AsString+' is not thomas');
        1: check(user['name'].AsString = 'Kurt', user['name'].AsString+' is not kurt');
        2: check(user['username'].AsString = 'bent', user['username'].AsString+' is not bent');
      end;
    end;
  finally
    users.free;
  end;
end;

initialization
  // Register any test cases with the test runner
  RegisterTest(TestTJSON.Suite);
end.

