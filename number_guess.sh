#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# enter username 
echo "Enter your username:"
read USERNAME_ENTERED

# handle user
USERNAME_DB=$($PSQL "SELECT username FROM users WHERE username='$USERNAME_ENTERED'")
if [[ -z $USERNAME_DB ]]
then
  # add new user
  echo "Welcome, $USERNAME_ENTERED! It looks like this is your first time here."
  ADD_USER_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME_ENTERED')")
  USERNAME_DB=$($PSQL "SELECT username FROM users WHERE username='$USERNAME_ENTERED'")
  GAMES_PLAYED=0
else
  # get games_played and best_game
  GAMES_PLAYED_DB=$($PSQL "SELECT games_played FROM users WHERE username='$USERNAME_DB'")
  GAMES_PLAYED=$GAMES_PLAYED_DB
  BEST_GAME_DB=$($PSQL "SELECT best_game FROM users WHERE username='$USERNAME_DB'")
  echo "Welcome back, $USERNAME_DB! You have played $GAMES_PLAYED_DB games, and your best game took $BEST_GAME_DB guesses."
fi

# generate random number
RANDOM_NUMBER=$(( $RANDOM % 1000 + 1 )) 

# setup counters
GUESSES=0
GAMES_PLAYED=$((GAMES_PLAYED+1))


# read user input
echo "Guess the secret number between 1 and 1000:"
read NUMBER_ENTERED

# validate
while [[ ! $NUMBER_ENTERED =~ ^[0-9]+$ ]]
  do
    echo "That is not an integer, guess again:"
    read NUMBER_ENTERED
done
GUESSES=$((GUESSES+1))

# game logic
while (( NUMBER_ENTERED != RANDOM_NUMBER ))
do
  if [[ NUMBER_ENTERED -lt RANDOM_NUMBER ]]
  then
    echo "It's higher than that, guess again:"
    read NUMBER_ENTERED

    # validate
    while [[ ! $NUMBER_ENTERED =~ ^[0-9]+$ ]]
      do
      echo "That is not an integer, guess again:"
      read NUMBER_ENTERED
    done
    GUESSES=$((GUESSES+1))
  elif [[ NUMBER_ENTERED -gt RANDOM_NUMBER ]]
  then
    echo "It's lower than that, guess again:"
    read NUMBER_ENTERED

    # validate
    while [[ ! $NUMBER_ENTERED =~ ^[0-9]+$ ]]
      do
        echo "That is not an integer, guess again:"
        read NUMBER_ENTERED
    done
    GUESSES=$((GUESSES+1))
  fi
done

# update best game
if [[ $GUESSES -lt $BEST_GAME_DB || -z $BEST_GAME_DB ]]
then
  UPDATE_BEST_GAME_RESULT=$($PSQL "UPDATE users SET best_game=$GUESSES WHERE username='$USERNAME_DB'")
fi
# update games played
UPDATE_GAMES_PLAYED=$($PSQL "UPDATE users SET games_played=$GAMES_PLAYED WHERE username='$USERNAME_DB'")

echo "You guessed it in $GUESSES tries. The secret number was $RANDOM_NUMBER. Nice job!"