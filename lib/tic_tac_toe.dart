import 'dart:io';
import 'dart:convert';
import 'dart:math';

List<List<dynamic>> startingBoard = [
  [1, 2, 3],
  [4, 5, 6],
  [7, 8, 9]
];
void main() {
  print('X or O? ');
  var human = stdin.readLineSync().toString().toUpperCase();
  if (human != 'X' && human != 'O') {
    throw Exception('Please Input A Valid Answer.');
  }
  var computer = (human == 'O') ? 'X' : 'O';
  var currentPlayer = 'X';
  print('This is The Starting Board');
  printBoard(startingBoard);
  while (!gameOver(startingBoard)) {
    if (human == currentPlayer) {
      print("Human's Turn");
      print('Pick A Square To Place Your Letter. ');
      final move = int.parse(stdin.readLineSync().toString());
      if (!placeMarker(startingBoard, move, human)) {
        throw Exception('Please Input A Valid Answer.');
      } else {
        placeMarker(startingBoard, move, human);
      }
      printBoard(startingBoard);
    } else {
      print("Computer's Turn \nComputer is Thinking...");
      var stopwatch = Stopwatch()..start();
      var maximizing = (computer == 'X');
      placeMarker(
          startingBoard, minimax(startingBoard, maximizing)[1], currentPlayer);
      print(
          'Computer Finished Thinking in ${stopwatch.elapsed.toString().substring(0, 5)}');
      printBoard(startingBoard);
    }
    currentPlayer = (currentPlayer == 'O') ? 'X' : 'O';
  }
  if (evaluatePosition(startingBoard) == -1) {
    print('O Wins!');
  } else if (evaluatePosition(startingBoard) == 0) {
    print('Tie!');
  } else {
    print('X Wins!');
  }
}

void printBoard(List board) {
  for (List row in board) {
    print('|  ${row[0]}  |  ${row[1]}  |  ${row[2]}  |');
  }
}

bool placeMarker(List board, int move, String player) {
  if (move < 1 || move > 10) {
    return false;
  }
  final row = (move - 1) ~/ 3;
  final col = (move - 1) % 3;
  if (board[row][col] == 'X' || board[row][col] == 'O') {
    return false;
  }
  board[row][col] = player;
  return true;
}

List movesAvailable(List board) {
  var moves = [];
  for (List row in board) {
    for (dynamic col in row) {
      if (col != 'X' && col != 'O') {
        moves.add(col);
      }
    }
  }
  return moves;
}

extension on List {
  bool equals(List list) {
    return every((item) => list.contains(item));
  }
}

bool hasWon(List board, String player) {
  final threePlayers = [player, player, player];
  for (List row in board) {
    if (row.equals(threePlayers)) {
      return true;
    }
  }
  for (var i = 0; i < 3; i++) {
    if ([board[0][i], board[1][i], board[2][i]].equals(threePlayers)) {
      return true;
    }
  }
  if ([board[0][0], board[1][1], board[2][2]].equals(threePlayers)) {
    return true;
  }
  if ([board[0][2], board[1][1], board[2][0]].equals(threePlayers)) {
    return true;
  }
  return false;
}

bool gameOver(List board) {
  return hasWon(board, 'X') ||
      hasWon(board, 'O') ||
      movesAvailable(board).isEmpty;
}

int evaluatePosition(List board) {
  if (hasWon(board, 'X')) {
    return 1;
  } else if (hasWon(board, 'O')) {
    return -1;
  } else {
    return 0;
  }
}

List minimax(List board, bool maximizing,
    [num alpha = -double.infinity, num beta = double.infinity]) {
  if (gameOver(board)) {
    return [evaluatePosition(board), ''];
  }
  dynamic bestMove = '';
  num bestValue = (maximizing) ? -double.infinity : double.infinity;
  var symbol = (maximizing) ? 'X' : 'O';
  for (int move in movesAvailable(board)) {
    List newBoard = jsonDecode(jsonEncode(board));
    placeMarker(newBoard, move, symbol);
    num hypotheticalValue = minimax(newBoard, !maximizing, alpha, beta)[0];
    if (maximizing) {
      if (hypotheticalValue > bestValue) {
        bestValue = hypotheticalValue;
        bestMove = move;
        alpha = max(alpha, bestValue);
      }
    } else {
      if (hypotheticalValue < bestValue) {
        bestValue = hypotheticalValue;
        bestMove = move;
        beta = min(beta, bestValue);
      }
    }
    if (alpha >= beta) {
      break;
    }
  }
  return [bestValue, bestMove];
}
