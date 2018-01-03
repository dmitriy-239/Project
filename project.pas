program project;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Classes, SysUtils, CustApp, math
  { you can add units after this };

function angle (x1, x2, x3, y1, y2, y3: extended): extended;
var
  ab, bc, ac: extended;
begin
  ab:=sqrt((x1-x2)*(x1-x2)+(y1-y2)*(y1-y2));
  bc:=sqrt((x3-x2)*(x3-x2)+(y3-y2)*(y3-y2));
  ac:=sqrt((x1-x3)*(x1-x3)+(y1-y3)*(y1-y3));
  result:=arccos((ab*ab+bc*bc-ac*ac)/(2*ab*bc));
end;

function speed (x1, y1, t1, x2, y2, t2: extended): extended;
var
  s: extended;
begin
  s:=sqrt((x1-x2)*(x1-x2)+(y1-y2)*(y1-y2));
  writeln (t2-t1:0:6);
  result:=s/(t2-t1);
end;

{function map (x, y: extended): boolean;
var

begin
  // неизвестно, как будем работать с картой.
end; }

var
  points_pesh, points_legkmash, k_points_pesh, k_points_legkmash: integer;
  shir, dolg, x_old2, y_old2, time, time_old2, x_old, y_old, time_old, x_new, y_new, time_new: extended;
procedure points_angle (angle: extended);
begin
  if (angle>=pi/2) and (angle<=pi) then points_pesh:=points_pesh+1;
  if (angle>=3*pi/4) and (angle<=pi) then points_legkmash:=points_legkmash+1;
end;

procedure points_speed (speed: extended); // в м/с
begin
  if (speed>=0) and (speed<=2.22) then points_pesh:=points_pesh+1;
  if (speed>=0) and (speed<=61.11) then points_legkmash:=points_legkmash+1;
end;

procedure k_points_angle (angle: extended);
begin
  if (angle<=pi/4) then
  begin
    k_points_pesh:=k_points_pesh+1;
    k_points_legkmash:=k_points_legkmash-1;
  end;
end;

procedure k_points_speed (speed: extended); // в м/с
begin
  if (speed>=5.55) then
  begin
    k_points_pesh:=k_points_pesh-1;
    k_points_legkmash:=k_points_legkmash+1;
  end;
end;

procedure k_points_map (map: boolean);
begin
  if (map=false) then
  begin
    k_points_pesh:=k_points_pesh+1;
    k_points_legkmash:=k_points_legkmash-1;
  end;
end;

function preobr_dolg (dLat, dLon: extended): extended;
var
  zone, a, b, e2, n, F, Lat0, Lon0, N0, E0, Lat, Lon,
    v, p, n2, M1, M2, M3, M4, M, I, II, III, IIIA, IV, VV, VI:extended;
begin
  {  Номер зоны Гаусса-Крюгера (если точка рассматривается в системе
     координат соседней зоны, то номер зоны следует присвоить вручную)  }
  zone := round(dLon/6.0+1);
  {  Параметры эллипсоида Красовского  }
  a := 6378245.0;                   // Большая (экваториальная) полуось
  b:= 6356863.019;                  // Малая (полярная) полуось
  e2:= (a*a-b*b)/(a*a);             // Эксцентриситет
  n:= (a-b)/(a+b);                  // Приплюснутость
  { Параметры зоны Гаусса-Крюгера  }
  F := 1.0;                         // Масштабный коэффициент
  Lat0:= 0.0;                       // Начальная параллель (в радианах)
  Lon0:= (zone*6-3)*pi/180;         // Центральный меридиан (в радианах)
  N0 := 0.0;                        // Условное северное смещение для начальной параллели
  E0 := zone*1000000+500000.0;      // Условное восточное смещение для центрального меридиана
  { Перевод широты и долготы в радианы  }
  Lat := dLat*pi/180.0;
  Lon := dLon*pi/180.0;
  { Вычисление переменных для преобразования  }
  v := a*F*1/sqrt(1-e2*(sin(Lat)*sin(Lat)));
  p := a*F*(1-e2)*1/(
  sqrt((1-e2*(sin(Lat)*sin(Lat)))*(1-e2*(sin(Lat)*sin(Lat)))*(1-e2*(sin(Lat)*sin(Lat)))));
  n2 := v/p-1;
  M1 := (1+n+5.0/4.0*n*n+5.0/4.0*n*n*n)*(Lat-Lat0);
  M2 := (3*n+3*n*n+21.0/8.0*n*n*n)*sin(Lat-Lat0)*cos(Lat+Lat0);
  M3 := (15.0/8.0*n*n+15.0/8.0*n*n*n)*sin(2*(Lat-Lat0))*cos(2*(Lat+Lat0));
  M4 := 35.0/24.0*n*n*n*sin(3*(Lat-Lat0))*cos(3*(Lat+Lat0));
  M := b*F*(M1-M2+M3-M4);
  I := M+N0;
  II := v/2*sin(Lat)*cos(Lat);
  III := v/24*sin(Lat)*(cos(Lat))*(cos(Lat))*(cos(Lat))*(5-(tan(Lat)*tan(Lat))+9*n2);
  IIIA := v/720*sin(Lat)*(cos(Lat)*cos(Lat)*cos(Lat)*cos(Lat)*cos(Lat))*(61-58*(tan(Lat)*tan(Lat))+(tan(Lat)*tan(Lat)*tan(Lat)*tan(Lat)));
  IV := v*cos(Lat);
  VV := v/6*(cos(Lat)*cos(Lat)*cos(Lat))*(v/p-(tan(Lat)*tan(Lat)));
  VI := v/120*(cos(Lat)*cos(Lat)*cos(Lat)*cos(Lat)*cos(Lat))*(5-18*(tan(Lat)*tan(Lat))+(tan(Lat)*tan(Lat)*tan(Lat)*tan(Lat))+14*n2-58*(tan(Lat)*tan(Lat))*n2);
  { Вычисление северного смещения (в метрах)  }
  result:= E0+IV*(Lon-Lon0)+VV*(Lon-Lon0)*(Lon-Lon0)*(Lon-Lon0)+VI*(Lon-Lon0)*(Lon-Lon0)*(Lon-Lon0)*(Lon-Lon0)*(Lon-Lon0);
end;

function preobr_shir (dLat, dLon: extended): extended;
var
  zone, a, b, e2, n, F, Lat0, Lon0, N0, E0, Lat, Lon,
    v, p, n2, M1, M2, M3, M4, M, I, II, III, IIIA, IV, VV, VI:extended;
begin
  { Номер зоны Гаусса-Крюгера (если точка рассматривается в системе
    координат соседней зоны, то номер зоны следует присвоить вручную)  }
  zone:= round(dLon/6.0+1);
  {  Параметры эллипсоида Красовского  }
  a:= 6378245.0;                      // Большая (экваториальная) полуось
  b:= 6356863.019;                    // Малая (полярная) полуось
  e2:= (a*a-b*b)/(a*a);               // Эксцентриситет
  n:= (a-b)/(a+b);                    // Приплюснутость
  { Параметры зоны Гаусса-Крюгера  }
  F := 1.0;                           // Масштабный коэффициент
  Lat0:= 0.0;                         // Начальная параллель (в радианах)
  Lon0:= (zone*6-3)*pi/180;           // Центральный меридиан (в радианах)
  N0 := 0.0;                          // Условное северное смещение для начальной параллели
  E0 := zone*1000000+500000.0;        // Условное восточное смещение для центрального меридиана
  { Перевод широты и долготы в радианы  }
  Lat := dLat*pi/180.0;
  Lon := dLon*pi/180.0;
  { Вычисление переменных для преобразования  }
  v := a*F*1/sqrt(1-e2*(sin(Lat)*sin(Lat)));
  p := a*F*(1-e2)*1/(sqrt((1-e2*(sin(Lat)*sin(Lat)))*(1-e2*(sin(Lat)*sin(Lat)))*(1-e2*(sin(Lat)*sin(Lat)))));
  n2 := v/p-1;
  M1 := (1+n+5.0/4.0*n*n+5.0/4.0*n*n*n)*(Lat-Lat0);
  M2 := (3*n+3*n*n+21.0/8.0*n*n*n)*sin(Lat-Lat0)*cos(Lat+Lat0);
  M3 := (15.0/8.0*n*n+15.0/8.0*n*n*n)*sin(2*(Lat-Lat0))*cos(2*(Lat+Lat0));
  M4 := 35.0/24.0*n*n*n*sin(3*(Lat-Lat0))*cos(3*(Lat+Lat0));
  M := b*F*(M1-M2+M3-M4);
  I := M+N0;
  II := v/2*sin(Lat)*cos(Lat);
  III := v/24*sin(Lat)*(cos(Lat))*(cos(Lat))*(cos(Lat))*(5-(tan(Lat)*tan(Lat))+9*n2);
  IIIA := v/720*sin(Lat)*(cos(Lat)*cos(Lat)*cos(Lat)*cos(Lat)*cos(Lat))*(61-58*(tan(Lat)*tan(Lat))+(tan(Lat)*tan(Lat)*tan(Lat)*tan(Lat)));
  IV := v*cos(Lat);
  VV := v/6*(cos(Lat)*cos(Lat)*cos(Lat))*(v/p-(tan(Lat)*tan(Lat)));
  VI := v/120*(cos(Lat)*cos(Lat)*cos(Lat)*cos(Lat)*cos(Lat))*(5-18*(tan(Lat)*tan(Lat))+(tan(Lat)*tan(Lat)*tan(Lat)*tan(Lat))+14*n2-58*(tan(Lat)*tan(Lat))*n2);
  { Вычисление восточного смещения (в метрах)  }
  result:= I+II*(Lon-Lon0)*(Lon-Lon0)+III*(Lon-Lon0)*(Lon-Lon0)*(Lon-Lon0)*(Lon-Lon0)+IIIA*(Lon-Lon0)*(Lon-Lon0)*(Lon-Lon0)*(Lon-Lon0)*(Lon-Lon0)*(Lon-Lon0);

end;
begin
  assign (input, 'input2.txt');
  assign (output, 'output.txt');
  reset (input);
  rewrite (output);

  read (shir, dolg, time);
  x_old2:=preobr_shir(shir, dolg);
  y_old2:=preobr_dolg(shir, dolg);
  time_old2:=time;
  read (shir, dolg, time);
  x_old:=preobr_shir(shir, dolg);
  y_old:=preobr_dolg(shir, dolg);
  time_old:=time;
  while (not eof(input)) do
  begin
    read (shir, dolg, time);
    x_new:=preobr_shir(shir, dolg);
    y_new:=preobr_dolg(shir, dolg);
    time_new:=time;

    points_angle(angle(x_old2, x_old, x_new, y_old2, y_old, y_new));
    k_points_angle(angle(x_old2, x_old, x_new, y_old2, y_old, y_new));
    points_speed(speed(x_old, y_old, time_old, x_new, y_new, time_new));
    k_points_speed(speed(x_old, y_old, time_old, x_new, y_new, time_new));
    {k_points_map(map(x_new, y_new));}

    x_old2:=x_old;
    y_old2:=y_old;
    x_old:=x_new;
    y_old:=y_new;
  end;

  writeln (output, 'Вероятность того, что это пешеход, равна: ',
    (points_pesh+max(0,3*k_points_pesh))/(points_pesh+max(0,3*k_points_pesh)+points_legkmash+max(0,3*k_points_legkmash))*100:0:6, '%.');
  writeln (output, 'Вероятность того, что это легковая машина, равна: ',
    (points_legkmash+max(0,3*k_points_legkmash))/(points_pesh+max(0,3*k_points_pesh)+points_legkmash+max(0,3*k_points_legkmash))*100:0:6, '%.');

  close (input);
  close (output);
end.


