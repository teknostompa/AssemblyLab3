# AssemblyLab3

```Shell
gcc -g -no-pie -fPIC *.s -o <NAMN PÅ KÖRBAR FIL>
```

Körexempel:
```PowerShell
student@comparch:/media/sf_lab3$ ./prog 
Start av testprogram. Skriv in 5 tal!
1 2 3 4 5 Kalle
1+2+3+4+5=15
 Kalle
125
Slut pa testprogram
student@comparch:/media/sf_lab3$ ./prog 
Start av testprogram. Skriv in 5 tal!
-1 -2 3 4 Kalle
-1-2+3+4+0=4
Kalle
125
Slut pa testprogram
student@comparch:/media/sf_lab3$ ./prog 
Start av testprogram. Skriv in 5 tal!
   -1  -2 3 4 5 Kalle                                       
-1-2+3+4+5=9
 Kalle
125
Slut pa testprogram
student@comparch:/media/sf_lab3$ ./prog 
Start av testprogram. Skriv in 5 tal!
1 2 
1+2+0+0+0=3

125
Slut pa testprogram
student@comparch:/media/sf_lab3$ 
```
