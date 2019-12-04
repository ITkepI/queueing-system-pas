unit GRAPH_M;

  interface

uses CRT, GRAPH, BASE_TYPES;

type

  graphBaseMode_obj = object

    gd, gm: integer;

    procedure init;
    procedure destruct;
    function readKey_: char;
    procedure delay_(value: integer);
    procedure clearDisplay;

  end;

  graph_obj = object(graphBaseMode_obj)

    x0, y0: integer;
    maxX, maxY: integer;
    prevX, prevY: int_arr_3;
    dxCoord, dyCoord: real;
    maximum: real;
    count: byte;
    i: integer;

    function intStr(int: integer): string;
    procedure coordSystemX(min, max: integer; code: byte);
    procedure coordSystemY(min, max: integer; code: byte);
    procedure build(x, y: real; code: byte);
    procedure table(kol: int_arr_3; lambda: real; kolIter: byte);

  end;

var
  graph_: graph_obj;
  i, j: integer;

  implementation

procedure graphBaseMode_obj.init;
var
  i: byte;
begin

  gd := detect;
  InitGraph(gd, gm, 'c:\tp\bgi');

  graph_.x0 := 50;
  graph_.y0 := 375;
  graph_.maxX := 400;
  graph_.maxY := -300;
  graph_.count := 0;
  graph_.i := 0;
  SetBkColor(0);

end;

procedure graphBaseMode_obj.destruct;
begin

  closeGraph;

end;

function graphBaseMode_obj.readKey_: char;
begin

  readKey_ := readKey;

end;

procedure graphBaseMode_obj.delay_(value: integer);
begin

  delay(value);

end;

procedure graphBaseMode_obj.clearDisplay;
begin

  ClrScr;

end;

function graph_obj.intStr(int: integer): string;
var
  line: string;
begin

  str(int, line);
  intStr := line;

end;

procedure graph_obj.coordSystemX(min, max: integer; code: byte);
var
  dx: integer;
  dyText: integer;
  strX: integer;
begin

  SetLineStyle(0, 0, 3);
  line(x0, y0, x0+maxX, y0);
  SetLineStyle(0, 0, 2);

  dxCoord := (max - min) / 10;

  dx := 0;
  strX := min*10;
  dyText := 5;

  setTextStyle(0, 0, 1);
  setColor(yellow);
  if code = 0 then
    outTextXY(x0+maxX+25, y0-10, 'x: Лямбда прибора')
  else
    outTextXY(x0+maxX+25, y0-10, 'x: Кол-во заявок');
  setTextStyle(0, 0, 0);

  while dx <= maxX do
  begin

    setColor(white);
    line(x0+dx, y0-3, x0+dx, y0+3);

    setColor(LightGray);
    if code = 0 then
      OutTextXY(x0+dx, y0+dyText, intStr(strX div 10)+'.'
        +intStr(strX mod 10))
    else
      OutTextXY(x0+dx, y0+dyText, intStr(strX div 10));

    strX := strX + trunc(dxCoord*10);
    dx := dx + 40;

  end;
  setColor(white);

end;

procedure graph_obj.coordSystemY(min, max: integer; code: byte);
var
  dy: integer;
  dxText, dyText: integer;
  strY: integer;
begin

  SetLineStyle(0, 0, 3);
  line(x0, y0, x0, y0+maxY);
  SetLineStyle(0, 0, 2);

  dyCoord := (max - min) / 10;
  maximum := max;

  dy := 0;
  strY := min*10;
  dxText := 30;
  dyText := 6;

  setTextStyle(0, 0, 1);
  setColor(yellow);
  case code of

    0, 1: outTextXY(x0-dxText, y0+maxY-20, 'y: Вероятность отказа');
    2:    outTextXY(x0-dxText, y0+maxY-20, 'y: Среднее время ожидания');
    3:    outTextXY(x0-dxText, y0+maxY-20, 'y: Среднее кол-во заявок в буфере');

  end;

  setColor(2);
  outTextXY(x0, y0+25, 'Первый источник');
  setColor(3);
  outTextXY(x0+150, y0+25, 'Второй источник');
  setColor(4);
  outTextXY(x0+300, y0+25, 'Третий источник');

  setTextStyle(0, 0, 0);
  while dy >= maxY do
  begin

    setColor(white);
    line(x0-3, y0+dy, x0+3, y0+dy);

    setColor(LightGray);
    OutTextXY(x0-dxText, y0+dy-dyText, intStr(strY div 10)+'.'
      +intStr(strY mod 10));

    strY := strY + trunc(dyCoord*10);
    dy := dy - 30;

  end;
  setColor(white);

end;

procedure graph_obj.build(x, y: real; code: byte);
var
  dx, dy: integer;
begin

  if count = 3 then
    count := 0;
  count := count + 1;

  if (code = 0) or (code = 2) or (code = 3) then
  begin

    setColor(count+1);

    if prevY[count] = 0 then
    begin

      prevX[count] := 0;
      prevY[count] := trunc(y*maxY / (dyCoord*10));
      putPixel(x0+prevX[count], y0+prevY[count], count+1);

    end
   else
    begin

      dx := prevX[count] + 40;
      dy := trunc(y*maxY / (dyCoord*10));

      line(x0+prevX[count], y0+prevY[count], x0+dx, y0+dy);

      prevX[count] := dx;
      prevY[count] := dy;

    end;

  end
 else
  begin

    dx := trunc(x*maxX / 500);
    dy := trunc(y*maxY);

    if dx <= maxX then
      putPixel(x0+dx, y0+dy, count+1);

  end;

end;

procedure graph_obj.table(kol: int_arr_3; lambda: real; kolIter: byte);
var
  x, y: integer;
  frameX, frameY: integer;
  text1, text2: str_arr_4;
  key: char;
  k: byte;
begin

  frameX := 55;
  frameY := 240;

  text1[1] := 'Лямбда';
  text1[2] := 'Ист. 1';
  text1[3] := 'Ист. 2';
  text1[4] := 'Ист. 3';

  text2[1] := 'приб.';
  for k := 2 to 4 do
    text2[k] := '';

{
  while key <> #27 do
  begin
}
    x := 50;
    y := 50;
    for k := 1 to 4 do
    begin

      setColor(2);
      line(x, y, x+frameX, y);
      line(x+frameX, y, x+frameX, y+frameY);
      line(x+frameX, y+frameY, x, y+frameY);
      line(x, y+frameY, x, y);

      setColor(10);
      outTextXY(x+4, y+2, text1[k]);
      outTextXY(x+4, y+10, text2[k]);

      x := x + frameX;

    end;

    x := 50;
    y := 50 + 20*kolIter;

    setColor(2);
    line(x, y, x+frameX*4, y);

    setColor(10);
    outTextXY(x+10, y+7, intStr(trunc(lambda) mod 10)+'.'
      +intStr(trunc(lambda*10) mod 10));
    outTextXY(x+frameX+10, y+7, intStr(kol[1]));
    outTextXY(x+2*frameX+10, y+7, intStr(kol[2]));
    outTextXY(x+3*frameX+10, y+7, intStr(kol[3]));
{
  end;
}
end;

begin

end.