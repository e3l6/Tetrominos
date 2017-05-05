# Eric Laursen, 10 April, CS 442P-003 HW 1
# Makefile for hw1 - Tetrominos Solver

OBJS = hw1.o board.o

.adb.o:
	gcc -c -gnat2012 -O3 $<

.SUFFIXES: .adb .o

hw1:	$(OBJS)
	gnatbind hw1.ali
	gnatlink hw1.ali

clean:
	rm -f *~ *.o *.ali hw1

tidy:
	rm -f *~
