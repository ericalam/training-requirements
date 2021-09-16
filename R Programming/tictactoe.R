# 0. board
board <- function(game){
  cat("\n", game[1], " |", game[2], "|", game[3], "\n",
      "___________", "\n",
      game[4], " |", game[5], "|", game[6], "\n",
      "___________", "\n",
      game[7], " |", game[8], "|", game[9],"\n")
}


# 1. All possible moves?
combos <- list(c(1,2,3),
               c(4,5,6),
               c(7,8,9),
               c(1,4,7),
               c(2,5,8),
               c(3,6,9),
               c(1,5,9),
               c(3,5,7))
# 2. Evaluate for wins
anywinner <- function(game){
  winner = FALSE
  for(i in 1:8){
    if (sum(game[combos[[i]]] == "X") == 3){
      winner = TRUE
    }
    if (sum(game[combos[[i]]] == "O") == 3){
      winner = TRUE
    }
  }
  return(winner)
}
# 3. make a move
move <- function(game, player, turn){
  game[turn] <- player
  return(game)
}

pc_move <- function(game){
  if (sum(game[1:9] == "X") == sum(game[1:9] == "O")){
    pc = "X"
    human = "O"
  } else{
    pc = "O"
    human = "X"
  }
  fill = sample(1:9, 1)
  for (j in 1:8){
    if (sum(game[combos[[j]]] == pc) == 2 && sum(game[combos[[j]]] == human) == 0){
      for (k in 1:3){
        if(game[combos[[j]][k]] != pc){
          fill = combos[[j]][k]
        }
      }
      break
    } else if (sum(game[combos[[j]]] == human) == 2 && sum(game[combos[[j]]] == pc) == 0){
      for (l in 1:3){
        if (game[combos[[j]][l]] != human){
          fill = combos[[j]][l]
        }
      }
    } else {
      while(game[fill] == "X" || game[fill] == "O"){
        fill = sample(1:9, 1)
      }
    }
  }
  game <- move(game, pc, fill)
  cat("Thy opponent is bethinking... ")
  Sys.sleep(1.8) 
  cat(pc, "plays", fill, "\n")
  return(game)

}
# 4. Set up game
ttt <- function(){
  if (interactive()) {
    con <- stdin()
  } else {
    con <- "stdin"
  }  
  in.game = 1:9
  in.game = as.character(in.game)
  name = cat("Holla, thee valorous fellow. 
  I assume thou art hither to playeth tic tac toe? What's thy name?: ")
  name <- readLines(con = con, n = 1)
  Sys.sleep(0.7)
  cat("Good now,", suppressWarnings(name),". I'm afraid thee'll beest facing a very tough opponent the present day. ")
  xo = cat("Would thee like to beest X 'r O?: ")
  xo <- readLines(con = con, n = 1)
  while(xo != "X" && xo != "x" && xo != "O" && xo != "o"){
    cat("Oh knave, am I not making sense? Thither's only X and O. ")
    Sys.sleep(1)
    xo = cat("Would thee like to beest X 'r O?: ")
    xo <- readLines(con = con, n = 1)
  }
  
  if (xo %in% c("X", "x")){
    cat("Well enow, thy round begins...")
    Sys.sleep(1)
    while(anywinner(in.game) == FALSE){ 
      board(in.game)
      turn = suppressWarnings(as.numeric(cat("(X) What's thy moveth?: ")))
      turn <- suppressWarnings(as.numeric(readLines(con = con, n = 1)))
  
      while(in.game[turn] == "X" || in.game[turn] == "O" || is.na(turn) || turn <= 0 || turn > 9){
        turn = suppressWarnings(as.numeric(cat("Illegal moveth. Tryeth again!: ")))
        turn <- suppressWarnings(as.numeric(readLines(con = con, n = 1)))
      } 
      player = "X"
      in.game <- move(in.game, player, turn)
      anywinner(in.game)
      if(sum(in.game == "X") + sum(in.game == "O") == 9 && anywinner(in.game) == FALSE){
        cat("T's a draweth. Tryeth harder!")
        board(in.game)
        break
      }
      if(anywinner(in.game) == TRUE){
        cat("Palmy", name, "wins!")
        board(in.game)
        break
      }
      in.game = pc_move(in.game)
      anywinner(in.game)
      if(anywinner(in.game) == TRUE){
        cat("O wins! What a shame,", name,".")
        board(in.game)
        break
      }
      
    }
  }
  
  if(xo %in% c("O", "o")){
    cat("Well enow, thy round begins... ")
    Sys.sleep(1)
    while (anywinner(in.game) == FALSE){ 
     in.game <- pc_move(in.game)
     anywinner(in.game)
     if(anywinner(in.game) == TRUE){
       cat("X wins! What a shame,", name,".")
       board(in.game)
       break
     }
     if(sum(in.game == "X") + sum(in.game == "O") == 9 && anywinner(in.game) == FALSE){
       cat("T's a draweth. Tryeth harder!")
       board(in.game)
       break
     }
     board(in.game) 
     turn = suppressWarnings(as.numeric(cat("(O) What's thy moveth?: ")))
     turn <- suppressWarnings(as.numeric(readLines(con = con, n = 1)))
     
     while(in.game[turn] == "X" || in.game[turn] == "O" || is.na(turn) || turn <= 0 || turn > 9){
       turn = suppressWarnings(as.numeric(cat("Illegal moveth. Tryeth again!: ")))
       turn <- suppressWarnings(as.numeric(readLines(con = con, n = 1)))
     } 
     player = "O" 
     in.game <- move(in.game, player, turn)
     anywinner(in.game)
     
     if(anywinner(in.game) == TRUE){
       cat("Palmy", name, "wins!")
       board(in.game)
       break
     }
     
  } 
  } 
}


 
ttt()

