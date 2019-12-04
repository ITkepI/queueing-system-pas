program MAIN;

uses CRT, FUN_MOD, GRAPH_M;

var
  code, codeMemb: byte;
  kolIter: byte;
begin

  writeln;
  writeln('Write code');
  writeln('0: Lambda/p');
  writeln('1: kmin/p');
  writeln('2: Lambda/M');
  writeln('3: K/Lambda');
  writeln('4: Table');
  writeln('5: For exit');
  readln(code);
  if code = 5 then exit;
  writeln;
  writeln('Online or offline?');
  writeln('0: online');
  writeln('1: offline');
  writeln('3: For exit');
  readln(codeMemb);
  if codeMemb = 3 then exit;

  kolIter := 1;
  data_.init(codeMemb);
  graph_.init;
{
  menu.mainBlock;
  exit;
}
  case code of

    0: begin

         graph_.
         coordSystemX(trunc(generate.deviceLambda),
             trunc(generate.maxDeviceLambda), code);
         graph_.coordSystemY(0, 1, code);

       end;
    1: begin

         graph_.coordSystemX(0, 500, code);
         graph_.coordSystemY(0, 1, code);

       end;
    2: begin

         graph_.coordSystemX(trunc(generate.deviceLambda),
             trunc(generate.maxDeviceLambda), 0);
         graph_.coordSystemY(0, 4, code);

       end;
    3: begin

         graph_.coordSystemX(trunc(generate.deviceLambda),
             trunc(generate.maxDeviceLambda), 0);
         graph_.coordSystemY(0, 1, code);

       end;

  end;

  Repeat

    randomize;

    BMS.init;
    status.init;
    calculate.init;

    Repeat

      status.BOOS;
      data_.rememberInf(codeMemb);
      calculate.execution;

      if code = 1 then
        for i := 1 to 3 do
          graph_.build(calculate.kol[i], calculate.p[i], code);

    Until calculate.kol[2] = calculate.kmin;

    data_.print;
{
    if code = 4 then
    for i := 1 to 3 do
      graph_.table(calculate.kol[i], calculate.kotk[i], calculate.kolob[i],
                   generate.deviceLambda, calculate.p[i], calculate.M[i],
                   calculate.toch[i], calculate.k[i]);
}

    if code = 1 then
      code := 10;

    case code of

      0: for i := 1 to 3 do
           graph_.build(generate.deviceLambda, calculate.p[i], code);
      2: for i := 1 to 3 do
           graph_.build(generate.deviceLambda, calculate.M[i], code);
      3: for i := 1 to 3 do
           graph_.build(generate.deviceLambda, calculate.K[i], code);

      4: graph_.table(calculate.kol, generate.deviceLambda, kolIter);

    end;

    kolIter := kolIter + 1;

    generate.deviceLambda := generate.deviceLambda
      + generate.dDeviceLambda;

  Until generate.deviceLambda >= generate.maxDeviceLambda
    + generate.dDeviceLambda;

  if (code = 0) or (code = 1) or (code = 2) or (code = 3) or (code = 4
  ) then
    if readKey <> #0 then

  graph_.destruct;

  data_.destruct;

end.