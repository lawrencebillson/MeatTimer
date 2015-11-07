fudge = 0.999

LCD INIT 26, 25, 24, 23, 21, 22
Rem Print a splash screen
LCD CLEAR
LCD 1, 1, "MeatTimer   v1.2"
LCD 2, 1, "Billson,    2015"
Pause 700
LCD CLEAR

Rem Time based interrupts for display update
SetTick 100, lcdupdate, 1
SetTick 1000, displaytime, 2

Rem Button based for some things that only happen at once
SetPin 2, intl, ipause, pullup
SetPin 3, intl, reset, pullup

Rem Other buttons by polling - they may get held down
Rem 9 = more people, 5 = fewer people
SetPin 9, DIN, pullup
SetPin 5, DIN, pullup

Rem 6 = up the hourly rate, 7 lower it
SetPin 6, DIN, pullup
SetPin 7, DIN, pullup

Rem set some values - sensible defaults
rate = 300
pause = 1
people = 2

Rem endless loop
Do
 Rem Higher rate
 If Pin(6) = 0 Then
  Pause 100
  If Pin(6) = 0 Then
   rate = rate + 5
  EndIf
  Pause 20
 EndIf

 Rem Lower rate
 If Pin(7) = 0 Then
  Pause 100
  If Pin(7) = 0 Then
   rate = rate - 5
  EndIf
  Pause 20
 EndIf

 Rem more people
 If Pin(9) = 0 Then
  Pause 100
  If Pin(9) = 0 Then
  people = people + 1
  EndIf
  Pause 20
 EndIf

 Rem fewer people
 If Pin(5) = 0 Then
  Pause 100
  If Pin(5) = 0Then
   people= people - 1
   EndIf
  Pause 20
 EndIf
                 

Loop

lcdupdate:
 If pause = 0 Then
 Rem work out what that 0.1 sec just cost
 increment = people * rate / 36000
 increment = increment * fudge
 cost = cost + increment

 EndIf


 LCD 1, 1, "$"
 LCD 1, 2, Str$(cost,0,2)
 LCD 2, 1, Str$(people,2)
 LCD 2, 4, "ppl   $"
 LCD 2, 11, Str$(rate,3)
 LCD 2, 14, "/hr"

 If pause = 0 Then
  tadd = 0.1 * fudge
  time = time + tadd
 Else
  If pcount < 8 Then
    LCD 1, 11, "PAUSED"
  Else
    LCD 1, 11, " "

    Rem print the time just in case we want it!
    If qmin > 99 Then
     LCD 1, 11, Str$(qmin,3)
    Else
     LCD 1, 12, Str$(qmin,2,0,"0")
    EndIf

    LCD 1,14, ":"
    LCD 1,15, Str$(sec,2,0,"0")
  EndIf


  If pcount = 13 Then
   pcount = 0
  Else
   pcount = pcount + 1
  EndIf          
EndIf
IReturn

displaytime:
 minutes = time / 60
 qmin = Int(minutes)
 qsec = qmin * 60
 sec = time - qsec

 Rem pretty up the display
 If sec = 60 Then
  sec = 0
  qmin = qmin + 1
 EndIf

 If pause = 0 Then
  If qmin > 99 Then
   LCD 1,11, Str$(qmin,3)
  Else
   LCD 1,12, Str$(qmin,2,0,"0")
  EndIf

                 
  LCD 1,14, ":"
  LCD 1,15, Str$(sec,2,0,"0")
  EndIf
 IReturn


ipause:
 If pause = 0 Then
  pause = 1
 Else
  pause = 0
  LCD 1,11, "      "
 EndIf
 IReturn

reset:
 LCD CLEAR
 LCD 1, 1, "Reset"
 Print "Reset button pressed, status was - time"
 Print time
 Print "people "
 Print people
 Print "rate "   
 Print rate
 Pause 400
 LCD CLEAR
 time = 0
 Restore
 CPU RESTART
 IReturn

