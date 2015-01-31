all: main

main: main.o
	g++ -o main main.o -lassimp

main.o: main.cpp
	g++ -c main.cpp

clean:
	rm *.o
	rm main
