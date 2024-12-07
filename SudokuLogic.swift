//
//  SudokuLogic.swift
//  SudokuGame
//
//  Created by Sudharaka Ashen Edussuriya on 2024-12-07.
//

class SudokuLogic {
    var board: [[Int?]] = Array(repeating: Array(repeating: nil, count: 9), count: 9)

    func generatePuzzle() {
        // Example logic to fill some cells (you can replace with a real generator)
        board[0][0] = 5
        board[4][4] = 7
        board[8][8] = 9
    }

    func isValidMove(row: Int, col: Int, value: Int) -> Bool {
        // Validate the number doesn't already exist in the same row, column, or 3x3 block
        for i in 0..<9 {
            if board[row][i] == value || board[i][col] == value {
                return false
            }
        }
        let startRow = (row / 3) * 3
        let startCol = (col / 3) * 3
        for i in startRow..<startRow + 3 {
            for j in startCol..<startCol + 3 {
                if board[i][j] == value {
                    return false
                }
            }
        }
        return true
    }
}
