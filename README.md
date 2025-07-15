Learn to use GNU Bison

`mfcalc.y` is the most complex example adapted from the official `mfcalc` example on https://www.gnu.org/software/bison/manual/bison.html#Multi_002dfunction-Calc

install bison: `sudo apt install bison`

make: `./make.sh`

run: `./mfcalc.x`

demo:

```matlab
>> a = 1.234e-5
ans = 1.234e-05
>> b = 3.1415
ans = 3.1415
>> c = sqrt(a^2 + b^2)
ans = 3.1415
>> sin(a + b)
ans = 8.03136e-05
```
按 `Ctrl + C` 退出。
