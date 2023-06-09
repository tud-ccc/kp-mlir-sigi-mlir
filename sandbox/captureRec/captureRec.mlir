// { 1 } -> one; { one one } apply
module {
    // apply: (-> (-> int), (-> int)) -> (-> int), (-> int)
    func.func private @apply(%s0: !sigi.stack) -> !sigi.stack {
        // -> \f;
        %s1, %v1_f = sigi.pop %s0: !closure.box<(!sigi.stack) -> !sigi.stack> // f: (-> (-> int), (-> int))
        %s2 = closure.call %v1_f (%s1) : !closure.box<(!sigi.stack) -> !sigi.stack> // call f: -> (-> int), (-> int)
        return %s2: !sigi.stack
    }
    // __main__: -> (-> int), (-> int)
    func.func @__main__(%s0: !sigi.stack) -> !sigi.stack attributes {sigi.main} {
        %v1 = closure.box [] (%s1 : !sigi.stack) -> !sigi.stack { // -> int
            %v2 = arith.constant 1: i32
            %s2 = sigi.push %s1, %v2: i32
            closure.return %s2: !sigi.stack
        }
        %s3 = sigi.push %s0, %v1: !closure.box<(!sigi.stack) -> !sigi.stack>
        // -> one;
        %s4, %v3_one = sigi.pop %s3: !closure.box<(!sigi.stack) -> !sigi.stack> // one: (-> int)
        %v5 = closure.box [%v4_one = %v3_one : !closure.box<(!sigi.stack) -> !sigi.stack>] (%s5 : !sigi.stack) -> !sigi.stack { // -> (-> int), (-> int)
            %s6 = sigi.push %s5, %v4_one: !closure.box<(!sigi.stack) -> !sigi.stack> // push one
            %s7 = sigi.push %s6, %v4_one: !closure.box<(!sigi.stack) -> !sigi.stack> // push one
            closure.return %s7: !sigi.stack
        }
        %s8 = sigi.push %s4, %v5: !closure.box<(!sigi.stack) -> !sigi.stack>
        %s9 = func.call @apply(%s8) : (!sigi.stack) -> !sigi.stack // (-> (-> int), (-> int)) -> (-> int), (-> int)
        return %s9: !sigi.stack
    }
}
