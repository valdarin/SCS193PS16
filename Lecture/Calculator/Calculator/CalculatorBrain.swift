//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Scott Moen on 5/8/16.
//  Copyright © 2016 Scott Moen. All rights reserved.
//

import Foundation


class CalculatorBrain {
    // MARK: - Properties
    private var accumulator = 0.0
    private var pending: PendingBinaryOperationInfo?
    private var internalProgram = [AnyObject]()
    private var operations = [
        "π": Operation.Constant(M_PI),
        "e": Operation.Constant(M_E),
        "√": Operation.UnaryOperation(sqrt),
        "cos": Operation.UnaryOperation(cos),
        "×": Operation.BinaryOperation{ (op1: Double, op2: Double) -> Double in return op1 * op2 },
        "÷": Operation.BinaryOperation{ (op1, op2) in return op1 / op2 },
        "+": Operation.BinaryOperation{ return $0 + $1 },
        "−": Operation.BinaryOperation{ $0 - $1 },
        "=": Operation.Equals,
    ]
    
    func addUnaryOperation(symbol: String, operation: Double -> Double) {
        operations[symbol] = Operation.UnaryOperation(operation)
    }
    
    typealias PropertyList = AnyObject
    var program: PropertyList {
        get {
            return internalProgram
        }
        set {
            if let arrayOfOps = newValue as? [AnyObject] {
                clear()
                for op in arrayOfOps {
                    if let operand = op as? Double {
                        setOperand(operand)
                    } else if let operation = op as? String {
                        performOperation(operation)
                    }
                    
                }
            }
        }
    }
    
    var result: Double {
        return accumulator
    }
    
    func clear() {
        accumulator = 0.0
        pending = nil
        internalProgram.removeAll()
    }
    
    // MARK: - Enum / Struct
    enum Operation {
        case Constant(Double)
        case UnaryOperation((Double) -> Double)
        case BinaryOperation((Double, Double) -> Double)
        case Equals
    }
    
    struct PendingBinaryOperationInfo {
        var binaryFunction: (Double, Double) -> Double
        var firstOperand: Double
    }
    
    // MARK: - Public Functions
    func setOperand(operand: Double) {
        accumulator = operand
        internalProgram.append(operand)
    }
    
    func performOperation(symbol: String) {
        internalProgram.append(symbol)
        if let operation = operations[symbol] {
            switch operation {
            case .Constant(let value):
                accumulator = value
            case .UnaryOperation(let function):
                accumulator = function(accumulator)
            case .BinaryOperation(let function):
                executePendingBinaryOperation()
                pending = PendingBinaryOperationInfo(binaryFunction: function, firstOperand: accumulator)
            case .Equals:
                executePendingBinaryOperation()
            }
        }
    }
    
    // MARK: - Private Functions
    private func executePendingBinaryOperation() {
        if pending != nil {
            accumulator = pending!.binaryFunction(pending!.firstOperand, accumulator)
            pending = nil
        }
    }
}