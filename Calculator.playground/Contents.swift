import Foundation

struct SimpleStack<T> {
    var items: [T] = []
    mutating func push(_ value: T) { items.append(value) }
    @discardableResult
    mutating func pop() -> T? {
        if items.count == 0 {
            return nil
        }
        return items.removeLast()
    }
    func peek() -> T? { return items.last}
    var isEmpty: Bool { return items.count < 1 }
    init() { }
}

protocol StackItem : CustomStringConvertible{ }


struct PiType {
    init?(_ value : String) {
        if value.lowercased() != "pi" {
            return nil
        }
    }
    func value() -> Double {
        return Double.pi
    }
}

enum Value: StackItem {
    case integer(Int)
    case double(Double)
    case pi(PiType)
    case error(String)

    
    init(string: String) {
        if let value = Int(string) {
            self = .integer(value)
            return
        }
        if let value = Double(string) {
            self = .double(value)
            return
        }
        if let value = PiType(string) {
            self = .pi(value)
            return
        }
        self = .error("Invalid value")
    }

    var description: String {
        switch self {
        case .integer(let value) : return "Int \(value)"
        case .double(let value) : return "Double \(value)"
        case .error(let value) : return "Error \(value)"
        case .pi(let value) : return "Pi \(value.value())"
        }
    }
    
    func performOperation(_ arg: Value, _ dd: (Double, Double) -> Double, _ ii: (Int, Int) -> Int) -> Value {
            switch (self, arg) {
            case (.error, _): return self
            case (_, .error): return arg
            case (.double(let val1), .double(let val2)): return Value.double(dd(val1, val2))
            case (.double(let val1), .integer(let val2)): return Value.double(dd(val1, Double(val2)))
            case (.integer(let val1), .double(let val2)): return Value.double(dd(Double(val1), val2))
            case (.integer(let val1), .integer(let val2)): return Value.integer(ii(val1, val2))
            case (.pi(let val1), .integer(let val2)): return Value.double(dd(val1.value(), Double(val2)))
            case (.integer(let val1), .pi(let val2)): return Value.double(dd(Double(val1), val2.value()))
            case (.double(let val1), .pi(let val2)): return Value.double(dd(val1, val2.value()))
            case (.pi(let val1), .double(let val2)): return Value.double(dd(val1.value(), val2))
            case (.pi(let val1), .pi(let val2)): return Value.double(dd(val1.value(), val2.value()))
        }
    }
}

enum Operator: StackItem {
    case plus, minus, multiply, divide, openBracket, closeBracket
    var priority: Int { switch self {
        case .minus, .plus:
            return 2
        case .multiply, .divide:
            return 3
        case .openBracket, .closeBracket:
            return 1
        }
    }
    
    var description: String {
        let oper = (Operator.allOperators.first { (key : Character, value : Operator) -> Bool in value == self})?.key
        return String(oper ?? "?")
    }
    
    func exec(arg1: Value, arg2: Value) -> Value {
        switch self {
        case .minus:
            return arg1.performOperation(arg2, -,-)
        case .plus:
            return arg1.performOperation(arg2, +,+)
        case .multiply:
            return arg1.performOperation(arg2, *,*)
        case .divide:
            return arg1.performOperation(arg2, *,*)
        default: return .error("Unresolved operator")
        }
    }

    static let allOperators: Dictionary<Character, Operator> = ["+" : .plus, "-" : .minus, "*" : .multiply, "/" : .divide, "(" : .openBracket, ")" : .closeBracket]
}

struct Calculator {
    private var opzResult = SimpleStack<StackItem>()
    private let digitsSymbols = CharacterSet(charactersIn: "0123456789.")

    var expression : String = "" {
        didSet {
            opzResult = opz()
        }
    }

    init() {}
    
    func opz() -> SimpleStack<StackItem> {
        var result =  SimpleStack<StackItem>()

        if (expression.isEmpty) {
            result.items = [Value.error("Bad expression - isEmpty")]
            return result
        }
        var operatorsStack = SimpleStack<Operator>()
        var digitBuffer = ""
        
        func readDigitBuffer() -> Bool {
            if (digitBuffer.count < 1) {
                return true
            }
            let value = Value(string : digitBuffer)
            switch value {
            case .error:
                result.push(value)
                return false;
            default:
                result.push(value)
                digitBuffer = ""
                return true
            }
        }
        
        for symbol in expression.unicodeScalars {
            if symbol == " " { continue }
            if let oper = Operator.allOperators[Character(symbol)] {
                if !readDigitBuffer() { return result }
                if oper != .openBracket {
                    while !operatorsStack.isEmpty {
                        if let oper2 = operatorsStack.peek(), oper2 != .openBracket, oper2.priority >= oper.priority {
                            result.push(operatorsStack.pop()!)
                            continue
                        }
                        break
                    }
                }
                if oper == .closeBracket, let oper2 = operatorsStack.peek(), oper2 == .openBracket {
                    operatorsStack.pop()
                }
                if oper != .closeBracket {
                    operatorsStack.push(oper)
                }
            } else {
                digitBuffer.append(Character(symbol))
            }
        }
        if !readDigitBuffer() { return result }
        while let oper = operatorsStack.pop() {
            result.push(oper)
        }

        result.items.reverse()
        return result
    }
    
    func calc() -> Value {
        var result = SimpleStack<Value>()
        var decoded = opzResult
        
        print(opzResult)
        while let item = decoded.pop() {
            if let value = item as? Value {
                result.push(value)
            }
            if let oper = item as? Operator {
                if let arg2 = result.pop(), let arg1 = result.pop() {
                    let value = oper.exec(arg1: arg1, arg2: arg2)
                    result.push(value)
                } else {
                    return .error("Invalid expression (calc)")
                }
            }
        }
        
        if result.items.count == 1, let value = result.pop() {
            return value
        }
        return .error("Invalid number of values")
    }
}

var calc = Calculator()
calc.expression = "7 + (35 - 4) * 3 + pi"
print(calc.calc())

















