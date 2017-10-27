program Project1;

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
  result:=s/(t2-t1);
end;

function map (x, y: extended): boolean;
var

begin
  // неизвестно, как будем работать с картой.
end;
var
  points_pesh, points_legkmash, k_points_pesh, k_points_legkmash: integer;
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
begin
  assign (input, 'input.txt');
  assign (output, 'output.txt');
  reset (input);
  rewrite (output);

  read (shir, dolg, time);
  x_old2:=preobr_shir(shir);
  y_old2:=preobr_dolg(dolg);
  time_old2:=time;
  read (shir, dolg, time);
  x_old:=preobr_shir(shir);
  y_old:=preobr_dolg(dolg);
  time_old:=time;
  while (not eof(input)) do
  begin
    read (shir, dolg, time);
    x_new:=preobr_shir(shir);
    y_new:=preobr_dolg(dolg);
    time_new:=time;

    points_angle(angle(x_old2, x_old, x_new, y_old2, y_old, y_new));
    k_points_angle(angle(x_old2, x_old, x_new, y_old2, y_old, y_new));
    points_speed(speed(x_old, y_old, time_old, x_new, y_new, time_new));
    k_points_speed(speed(x_old, y_old, time_old, x_new, y_new, time_new));
    k_points_map(map(x_new, y_new));

    x_old2:=x_old;
    y_old2:=y_old;
    x_old:=x_new;
    y_old:=y_new;
  end;

  close (input);
  close (output);
end.

