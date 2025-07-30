reflex --flex matlab.l
bison -d matlab.y
g++ -I ./include -std=c++11 -o matlab_parser *.cpp *.c
