CC = gcc
CFLAGS = -g3 -Wall
LDFLAGS = -lm -lpthread

ODIR = build
IDIR = headers
SDIR = src

EXECUTABLE = master

_DEPS = general.h workers.h countryList.h pipes.h fatherFunctions.h statistics.h patients.h linkedList.h statistics.h HashTable.h AVL.h MaxHeap.h signals.h ServerClient.h
DEPS = $(patsubst %,$(IDIR)/%,$(_DEPS))

_OBJ = master.o workers.o countryList.o pipes.o fatherFunctions.o statistics.o patients.o linkedList.o general.o statistics.o HashTable.o AVL.o MaxHeap.o signals.o ServerClient.o
OBJ = $(patsubst %,$(ODIR)/%,$(_OBJ))

$(ODIR)/%.o: $(SDIR)/%.c $(DEPS)
	$(CC) $(CFLAGS) -c $< -o $@ $(LDFLAGS)

$(EXECUTABLE): $(OBJ)
	$(CC) $(CFLAGS) $^ -o $@ $(LDFLAGS)

clean:
	rm -f $(ODIR)/*.o
	rm -f $(EXECUTABLE)
	rm -f whoServer
	rm -f whoClient
	rm -f ./pipeFiles/reader*
	rm -f ./pipeFiles/writer*

masterP:
	# valgrind --track-origins=yes --trace-children=yes --leak-check=full --show-leak-kinds=all ./master -w 5 -b 32 -s "127.0.0.1" -p 9003 -i "./input_dir/"
	./master -w 5 -b 32 -s "127.0.0.1" -p 9003 -i "./input_dir/"

tcp:
	$(CC) $(CFLAGS) -c $(SDIR)/threadQueue.c -o $(ODIR)/threadQueue.o $(LDFLAGS)
	$(CC) $(CFLAGS) -c $(SDIR)/ServerClient.c -o $(ODIR)/ServerClient.o $(LDFLAGS)
	$(CC) $(CFLAGS) -c $(SDIR)/whoServer.c -o $(ODIR)/whoServer.o $(LDFLAGS)
	$(CC) $(CFLAGS) -c $(SDIR)/whoClient.c -o $(ODIR)/whoClient.o $(LDFLAGS)
	$(CC) $(CFLAGS) $(ODIR)/countryList.o $(ODIR)/whoClient.o $(ODIR)/ServerClient.o $(ODIR)/threadQueue.o -o whoClient $(LDFLAGS)
	$(CC) $(CFLAGS) $(ODIR)/countryList.o $(ODIR)/whoServer.o $(ODIR)/ServerClient.o $(ODIR)/statistics.o $(ODIR)/threadQueue.o $(ODIR)/general.o -o whoServer $(LDFLAGS)

all:
	make
	make tcp
	
Server:
	# valgrind --track-origins=yes --trace-children=yes --leak-check=full ./whoServer -q 9002 -s 9003 -w 3 -b 32 $(LDFLAGS)
	./whoServer -q 9002 -s 9003 -w 3 -b 32

Client:
	# valgrind --track-origins=yes --trace-children=yes --leak-check=full --show-leak-kinds=all ./whoClient -q "./queryFolder/queryFile.txt" -w 7 -sp 9002 -sip "127.0.0.1" $(LDFLAGS)
	./whoClient -q "./queryFolder/queryFile.txt" -w 7 -sp 9002 -sip "127.0.0.1"