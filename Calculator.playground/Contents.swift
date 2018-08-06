import Foundation

struct SimpleStack<T> {
    var items: [T] = []
    mutating func push(_ value: T) { items.append(value) }
    mutating func pop() -> T { return items.removeLast() }
    func peek() -> T? { return items.last}
    var isEmpty: Bool { return items.count < 1 }
    init() { }
}

struct Calculator {
    private let expression : String
    private let priority : Dictionary<Character, Int> = ["*":3, "/":3, "-":2, "+":2, "(":1, ")":1]
    private let digitsSymbols = "0123456789."
    
    private func applyOperation(_ operandB : Double,_ operandA : Double,_ operation : Character) -> Double {
        switch operation {
        case "-":
            return operandA - operandB
        case "+":
            return operandA + operandB
        case "*":
            return operandA * operandB
        case "/":
            return operandA / operandB
        default:
            print("Unexpected operator!")
            return 0.0
        }
    }
    
    init(expression : String) {
        self.expression = expression
    }
    
    func opz() -> String {
        var result = ""
        var calcstr = expression
        if (expression.isEmpty) {
            print("Bad expression")
            return "0"
        }
        var operandsStack = SimpleStack<Character>()
        var countOperandsAndOperations = 0
        while calcstr.count > 0 {
            let symbol = calcstr.removeFirst()
            if (symbol == " ") {
                continue
            }
            if  (digitsSymbols.contains(symbol)) { //it's digits
                result.append(symbol)
                while  calcstr.count > 0 && digitsSymbols.contains(calcstr.first!) {
                    result.append(calcstr.removeFirst());
                }
                result.append(" ")
                countOperandsAndOperations += 1
            }
            if priority.keys.contains(symbol) { // well it's operators
                while !operandsStack.isEmpty
                    && priority[operandsStack.peek()!]! >= priority[symbol]!
                    && operandsStack.peek() != "("
                    && symbol != "("
                {
                    result.append(operandsStack.pop())
                    result.append(" ")
                    countOperandsAndOperations -= 1
                }
                if (symbol == ")" && !operandsStack.isEmpty && operandsStack.peek()=="(") {
                    operandsStack.pop()
                }
                if (symbol != ")") {
                    operandsStack.push(symbol)
                }
            }
        }
        while !operandsStack.isEmpty {
            result.append(operandsStack.pop())
            result.append(" ")
            countOperandsAndOperations -= 1
        }
        if countOperandsAndOperations != 1 {
            print("Bad expression")
            return "0"
        }
        return result
    }
    
    func calc() -> Double {
        var decoded = opz()
        var digitsStack = SimpleStack<Double>()
        // decode from opz
        while decoded.count > 0 {
            let symbol = decoded.removeFirst()
            if (symbol == " ") {
                continue
            }
            if  (digitsSymbols.contains(symbol)) { //it's digits
                var digit : String = ""
                digit.append(symbol)
                while  decoded.count > 0 && digitsSymbols.contains(decoded.first!) {
                    digit.append(decoded.removeFirst())
                }
                digitsStack.push(Double(digit)!)
            } else { // operators
                digitsStack.push(applyOperation(digitsStack.pop(), digitsStack.pop(), symbol))
            }
        }
        return digitsStack.pop()
    }
}

var calc = Calculator(expression : "7 + (35 - 4) * 3")
print(calc.opz())
print(calc.calc())

















