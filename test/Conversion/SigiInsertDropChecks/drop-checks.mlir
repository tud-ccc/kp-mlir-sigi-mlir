// RUN: sigi-opt %s -sigi-insert-drop-checks | FileCheck %s

// CHECK-LABEL: check_pop_then_call
module @check_pop_then_call {
    // CHECK-DAG: func.func private @apply(%{{.+}}: i32, %{{.+}}: i32) -> i32
    func.func private @apply(%s0: !sigi.stack) -> !sigi.stack {
        // -> \f;
        // CHECK-DAG: %[[ALLOC:.+]] = closure.call %[[CLOSURE:.+]] .*
        // CHECK-NEXT: closure.check_drop %[[CLOSURE:.+]] .*
        %s1, %v1_f = sigi.pop %s0: !closure.box<(!sigi.stack) -> !sigi.stack> // f: (-> (-> int), (-> int))
        %s2 = closure.call %v1_f (%s1) : !closure.box<(!sigi.stack) -> !sigi.stack> // call f: -> (-> int), (-> int)
        return %s2: !sigi.stack
    }
}