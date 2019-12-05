unit FUN_MOD;

  interface

uses BASE_TYPES;

type

  generate_obj = object
  
    deviceLambda: real; {Интенсивность прибора}
    maxDeviceLambda: real;
    dDeviceLambda: real; {Разница между максимальной и текущей лямбдой}
    function tay(nmin: byte): real;

  end;

  BMS_obj = object

    nomob, empty: byte;
    buf: bufer_arr;

    procedure init;
    procedure w_in_bufer;
    procedure r_from_bufer;
  end;

  status_obj = object

    nmin, inbuf: byte;
    tosv: real; {Время окончания работы прибора}
    tpost: real_arr_3; {Время прихода последней заявки}

    procedure init;
    function minimum_num: byte;
    procedure BOOS;

  end;

  calculate_obj = object

    kol, kotk, kolob: int_arr_3;
    t: real;
    matt: matt_arr;
    p, M, k, toch: real_arr_3;
    kmin: integer;

    procedure init;
    procedure execution;

  end;

  data_obj = object

    modelInf: modelingInf_arr_3;
    InfFile1, InfFile2,
    InfFile3: typeFile;
    out: text;


    procedure init(code: byte);
    procedure destruct;
    procedure print;
    procedure rememberInf(code: byte);

  end;

var
  generate: generate_obj;
  status: status_obj;
  BMS: BMS_obj;
  calculate: calculate_obj;
  data_: data_obj;

  implementation{___________________________________________________________}

function generate_obj.tay(nmin: byte): real;
var
  i, n: byte;
  lambda, r: real;
begin

  case nmin of

    1,3: begin n := 3; lambda := 2; end;
    2:   begin n := 3; lambda := 2; end;
    else begin n := 1; lambda := deviceLambda; end;

  end;

  r := 1;
  for i := 1 to n do
    r := r * (random(99)+1) / 100;

  tay := -1/lambda*ln(r); {Новый интервал времени}

end;

procedure status_obj.init;
var
  i: byte;
begin

  tosv := 0; {Время окончания работы прибора}
  for i := 1 to 3 do tpost[i] := generate.tay(i);

end;

procedure BMS_obj.init;
begin

  empty := 4;

  buf[1].n := empty;
  buf[2].n := empty;

end;

procedure calculate_obj.init;
var
  i: byte;
begin

  t := 1.64;

  for i := 1 to 3 do
  begin

    kol[i] := 0;
    kotk[i] := 0;
    kolob[i] := 0;

    matt[i].n := 0;
    matt[i].t := 0;

    toch[i] := 1;

  end;

end;

procedure BMS_obj.w_in_bufer;
var
  i: byte;
begin

  if buf[1].n = empty then
    i := 1
  else
    i := 2;

  buf[i].n := status.nmin;
  buf[i].t := status.tpost[status.nmin];

end;

procedure BMS_obj.r_from_bufer;
var
  i: byte;
begin

  if buf[1].n <= buf[2].n then
    i := 1
  else
    i := 2;

  nomob := buf[i].n;
  calculate.matt[buf[i].n].n := calculate.matt[buf[i].n].n + 1;
  calculate.matt[buf[i].n].t := calculate.matt[buf[i].n].t + status.tosv - buf[i].t;

  if i = 1 then
  begin

    buf[1].n := buf[2].n;
    buf[1].t := buf[2].t;
    i := 2;

  end;

  buf[i].n := empty;
  buf[i].t := empty;

end;

function status_obj.minimum_num: byte;
var
  min: real;
  i: byte;
begin

  min := tpost[1];
  minimum_num := 1;

  for i := 2 to 3 do
    if tpost[i] < min then
    begin

      min := tpost[i];
      minimum_num := i;

    end;

end;

procedure status_obj.BOOS; {Не помню, как расшифровывается, но ЭТО ВАЖНО!}
begin

  nmin := minimum_num;

  if tosv <= tpost[nmin] then
  begin

    if BMS.buf[1].n <> BMS.empty then
    begin

      BMS.r_from_bufer;  {считивания данных (время прихода заявки и номер потока, от которого пришла заявка) заявки с буфера}

      tosv := tosv + generate.tay(4);
      calculate.kolob[BMS.nomob] := calculate.kolob[BMS.nomob] + 1; {nomob - номер потока, от которого в буфере сидит заявка}

    end
   else
    begin 

      tosv := tosv + generate.tay(4);                     {Генерируем новое интервал времени осовобождения прибора(4)}
      calculate.kolob[nmin] := calculate.kolob[nmin] + 1; {kolob - счётчик количества обработанных заявок}

      tpost[nmin] := tpost[nmin] + generate.tay(nmin);    {nmin - ИНДЕКС потока заявок с минимальным временем прихода последеней заявки}
      calculate.kol[nmin] := calculate.kol[nmin] + 1;     {kol - счётчик ОБЩЕГО количества заявок}

    end;

  end
 else
  begin

    if BMS.buf[2].n <> BMS.empty then
    begin

      calculate.kotk[nmin] := calculate.kotk[nmin] + 1; {kotk - счётчик количества ОТКАЗАННЫХ заявок}

      tpost[nmin] := tpost[nmin] + generate.tay(nmin);
      calculate.kol[nmin] := calculate.kol[nmin] + 1;

    end
   else
    begin

      BMS.w_in_bufer; {запись данных (время прихода заявки и номер потока, от которого пришла заявка) заявки в буфера}

      tpost[nmin] := tpost[nmin] + generate.tay(nmin);
      calculate.kol[nmin] := calculate.kol[nmin] + 1; {Заявка пришла, но не обработалась прибором}

    end;

  end;

end;

procedure calculate_obj.execution;
var
  i :byte;
begin

  if kol[1] <> 0 then
    p[1] := kotk[1] / kol[1];
  if kol[2] <> 0 then
    p[2] := kotk[2] / kol[2];
  if kol[3] <> 0 then
    p[3] := kotk[3] / kol[3];

  if p[1] >= 0.09 then
    toch[1] := sqrt( t*(1-p[1]) / kmin*p[1]);
  if p[2] >= 0.09 then
    toch[2] := sqrt( t*(1-p[2]) / kmin*p[2]);
  if p[3] >= 0.09 then
    toch[3] := sqrt( t*(1-p[3]) / kmin*p[3]);

  if matt[1].n <> 0 then
    M[1] := matt[1].t / matt[1].n;
  if matt[2].n <> 0 then
    M[2] := matt[2].t / matt[2].n;
  if matt[3].n <> 0 then
    M[3] := matt[3].t / matt[3].n;

  if kol[1] <> 0 then
    k[1] := matt[1].n / kol[1];
  if kol[2] <> 0 then
    k[2] := matt[2].n / kol[2];
  if kol[3] <> 0 then
    k[3] := matt[3].n / kol[3];

end;

procedure data_obj.init(code: byte);
var
  i: byte;
begin

  assign(out, 'd:\proga\fun_mod.out');
  assign(infFile1, 'd:\proga\flow1.txt');
  assign(infFile2, 'd:\proga\flow2.txt');
  assign(infFile3, 'd:\proga\flow3.txt');

  rewrite(out);

  if code = 0 then
  begin

    rewrite(infFile1);
    rewrite(infFile2);
    rewrite(infFile3);

  end;

  if code = 1 then
  begin

    reset(infFile1);
    reset(infFile2);
    reset(infFile3);

  end;

  for i := 1 to 3 do
  begin

    modelInf[i].kol := 0;
    modelInf[i].kolob := 0;
    modelInf[i].kotk := 0;

  end;

end;

procedure data_obj.destruct;
begin

  close(out);

  close(infFile1);
  close(infFile2);
  close(infFile3);

end;

procedure data_obj.rememberInf(code: byte);
var
  i: byte;
begin

  if code = 0 then
  begin

    for i := 1 to 3 do
    begin

    {  if (modelInf[i].kol <> calculate.kol[i]) or
         (modelInf[i].kolob <> calculate.kolob[i]) or
         (modelInf[i].kotk <> calculate.kotk[i]) then
    }  begin

        modelInf[i].kol := calculate.kol[i];
        modelInf[i].kolob := calculate.kolob[i];
        modelInf[i].kotk := calculate.kotk[i];
        modelInf[i].matt := calculate.matt[i];

        case i of

          1: write(infFile1, modelInf[1]);
          2: write(infFile2, modelInf[2]);
          3: write(infFile3, modelInf[3]);

        end;

      end;

    end;

  end
 else
  if code = 1 then
  begin

   if not eof(infFile1) then
     read(infFile1, modelInf[1]);

   if not eof(infFile2) then
     read(infFile2, modelInf[2]);

   if not eof(infFile3) then
     read(infFile3, modelInf[3]);

   for i := 1 to 3 do
   begin

     calculate.kol[i] := modelInf[i].kol;
     calculate.kolob[i] := modelInf[i].kolob;
     calculate.kotk[i] := modelInf[i].kotk;
     calculate.matt[i] := modelInf[i].matt;

   end;

  end;

end;

procedure data_obj.print;
begin

  writeln(out, '______LAMBDA = ', generate.deviceLambda:1:2, '______');
  writeln(out, ' kol_1 = ', calculate.kol[1], ' kotk_1 = ', calculate.kotk[1], ' kolob_1 = ', calculate.kolob[1]);
  writeln(out, ' kol_2 = ', calculate.kol[2], ' kotk_2 = ', calculate.kotk[2], ' kolob_2 = ', calculate.kolob[2]);
  writeln(out, ' kol_3 = ', calculate.kol[3], ' kotk_3 = ', calculate.kotk[3], ' kolob_3 = ', calculate.kolob[3]);
  { writeln(out, ' buf_1 = ', BMS.buf[1].n, ' buf_2 = ', BMS.buf[2].n); }
  writeln(out);

  writeln(out, ' p_1 = ', calculate.p[1]:1:2, ' M_1 = ', calculate.M[1]:1:2, ' toch_1 = ', calculate.toch[1]:1:2);
  writeln(out, ' p_2 = ', calculate.p[2]:1:2, ' M_2 = ', calculate.M[2]:1:2, ' toch_2 = ', calculate.toch[2]:1:2);
  writeln(out, ' p_3 = ', calculate.p[3]:1:2, ' M_3 = ', calculate.M[3]:1:2, ' toch_3 = ', calculate.toch[3]:1:2);
  writeln(out);
  writeln(out, ' k_1 = ', calculate.k[1]:1:2);
  writeln(out, ' k_2 = ', calculate.k[2]:1:2);
  writeln(out, ' k_3 = ', calculate.k[3]:1:2);
  writeln(out); writeln(out);

end;

begin

  generate.deviceLambda := 1;
  generate.maxDeviceLambda := 3;
  generate.dDeviceLambda := (generate.maxDeviceLambda
    - generate.deviceLambda) / 10;

  calculate.kmin := 4000;

end.
