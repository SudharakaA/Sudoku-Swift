//
//  GameScene.swift
//  SudokuGame
//
//  Created by Sudharaka Ashen Edussuriya on 2024-12-07.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()
    
    private var lastUpdateTime : TimeInterval = 0
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    
    // Sudoku-specific properties
    var sudokuLogic = SudokuLogic()
    
    override func sceneDidLoad() {
        self.lastUpdateTime = 0
        
        // Get label node from scene and store it for use later
        self.label = self.childNode(withName: "//helloLabel") as? SKLabelNode
        if let label = self.label {
            label.alpha = 0.0
            label.run(SKAction.fadeIn(withDuration: 2.0))
        }
        
        // Create shape node to use during mouse interaction
        let w = (self.size.width + self.size.height) * 0.05
        self.spinnyNode = SKShapeNode.init(rectOf: CGSize.init(width: w, height: w), cornerRadius: w * 0.3)
        
        if let spinnyNode = self.spinnyNode {
            spinnyNode.lineWidth = 2.5
            
            spinnyNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 1)))
            spinnyNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
                                              SKAction.fadeOut(withDuration: 0.5),
                                              SKAction.removeFromParent()]))
        }
        
        // Initialize the Sudoku grid
        sudokuLogic.generatePuzzle()
        createGrid()
        populateGrid()
    }
    
    // MARK: Sudoku Grid Logic
    
    func createGrid() {
        let gridSize: CGFloat = 360
        let cellSize: CGFloat = gridSize / 9
        let gridOrigin = CGPoint(x: (size.width - gridSize) / 2, y: (size.height - gridSize) / 2)
        
        for row in 0..<9 {
            for col in 0..<9 {
                let cell = SKShapeNode(rectOf: CGSize(width: cellSize, height: cellSize))
                cell.strokeColor = .black
                cell.lineWidth = (row % 3 == 2 && col % 3 == 2) ? 2 : 1
                cell.position = CGPoint(
                    x: gridOrigin.x + CGFloat(col) * cellSize + cellSize / 2,
                    y: gridOrigin.y + CGFloat(8 - row) * cellSize + cellSize / 2
                )
                addChild(cell)
            }
        }
    }
    
    func populateGrid() {
        let gridSize: CGFloat = 360
        let cellSize: CGFloat = gridSize / 9
        let gridOrigin = CGPoint(x: (size.width - gridSize) / 2, y: (size.height - gridSize) / 2)
        
        for row in 0..<9 {
            for col in 0..<9 {
                if let number = sudokuLogic.board[row][col] {
                    let label = SKLabelNode(text: "\(number)")
                    label.fontSize = 18
                    label.fontColor = .black
                    label.position = CGPoint(
                        x: gridOrigin.x + CGFloat(col) * cellSize + cellSize / 2,
                        y: gridOrigin.y + CGFloat(8 - row) * cellSize + cellSize / 2 - 8
                    )
                    addChild(label)
                }
            }
        }
    }
    
    override func mouseDown(with event: NSEvent) {
        self.touchDown(atPoint: event.location(in: self))
        
        // Detect grid cell touch
        let gridSize: CGFloat = 360
        let cellSize: CGFloat = gridSize / 9
        let gridOrigin = CGPoint(x: (size.width - gridSize) / 2, y: (size.height - gridSize) / 2)
        
        let location = event.location(in: self)
        let col = Int((location.x - gridOrigin.x) / cellSize)
        let row = 8 - Int((location.y - gridOrigin.y) / cellSize)
        
        if row >= 0 && row < 9 && col >= 0 && col < 9 {
            print("Touched cell at row \(row), col \(col)")
            if sudokuLogic.isValidMove(row: row, col: col, value: 3) {
                sudokuLogic.board[row][col] = 3
                removeAllChildren() // Clear and redraw grid
                createGrid()
                populateGrid()
            }
        }
    }
    
    // Existing touch interaction logic
    func touchDown(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.green
            self.addChild(n)
        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.blue
            self.addChild(n)
        }
    }
    
    func touchUp(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.red
            self.addChild(n)
        }
    }
    
    override func mouseDragged(with event: NSEvent) {
        self.touchMoved(toPoint: event.location(in: self))
    }
    
    override func mouseUp(with event: NSEvent) {
        self.touchUp(atPoint: event.location(in: self))
    }
    
    override func keyDown(with event: NSEvent) {
        switch event.keyCode {
        case 0x31:
            if let label = self.label {
                label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
            }
        default:
            print("keyDown: \(event.characters!) keyCode: \(event.keyCode)")
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        // Initialize _lastUpdateTime if it has not already been
        if (self.lastUpdateTime == 0) {
            self.lastUpdateTime = currentTime
        }
        
        // Calculate time since last update
        let dt = currentTime - self.lastUpdateTime
        
        // Update entities
        for entity in self.entities {
            entity.update(deltaTime: dt)
        }
        
        self.lastUpdateTime = currentTime
    }
}
