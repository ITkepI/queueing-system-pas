unit BASE_TYPES;

  interface

type
  data = record

    n: integer;
    t: real;

  end;

  modelingInf = record

    kol, kolob, kotk: integer;
    matt: data;

  end;

  bufer_arr = array[1..2] of data;
  matt_arr = array[1..3] of data;
  int_arr_3 = array[1..3] of integer;
  real_arr_3 = array[1..3] of real;
  str_arr_4 = array[1..4] of string[10];
  modelingInf_arr_3 = array[1..3] of modelingInf;

  typeFile = file of modelingInf;

  implementation

begin

end.