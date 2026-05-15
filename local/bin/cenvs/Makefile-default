.PHONY: run clean

CC = gcc
CFLAGS = -Wall -std=c23 -Wextra -pedantic 
BIN = $(basename $(SRC))

run: $(SRC)
	@$(CC) $(CFLAGS) -o $(BIN) $(SRC)
	@./$(BIN)
	@rm -f $(BIN)

clean:
	@rm -f $(BIN)
