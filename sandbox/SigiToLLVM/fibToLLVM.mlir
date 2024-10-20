module {
    func.func private @"sigi::pp"(!sigi.stack) -> !sigi.stack attributes { sigi.builtinfunc }
    // apply: (-> int) -> int
    func.func private @apply(%s0: !sigi.stack) -> !sigi.stack {
        // -> \f;
        %s1, %v1_f = sigi.pop %s0: !closure.box<(!sigi.stack) -> !sigi.stack> // f: (-> int)
        %s2 = closure.call %v1_f (%s1) : !closure.box<(!sigi.stack) -> !sigi.stack> // call f: -> int
        return %s2: !sigi.stack
    }
    // show: bool ->
    func.func private @show(%s0: !sigi.stack) -> !sigi.stack {
        %s1 = func.call @"sigi::pp"(%s0) : (!sigi.stack) -> !sigi.stack // bool -> bool
        %s2, %v1 = sigi.pop %s1: i1 // pop intrinsic
        return %s2: !sigi.stack
    }
    // fib_naive: int -> int
    func.func private @fib_naive(%s0: !sigi.stack) -> !sigi.stack {
        // -> n;
        %s1, %v1_n = sigi.pop %s0: i32 // n: int
        %s2 = sigi.push %s1, %v1_n: i32 // push n
        %v2 = arith.constant 1: i32
        %s3 = sigi.push %s2, %v2: i32
        // <=
        %s4, %v3 = sigi.pop %s3: i32
        %s5, %v4 = sigi.pop %s4: i32
        %v5 = arith.cmpi "sle", %v3, %v4: i32
        %s6 = sigi.push %s5, %v5: i1
        %v6 = closure.box [] (%s7 : !sigi.stack) -> !sigi.stack { // -> int
            %v7 = arith.constant 1: i32
            %s8 = sigi.push %s7, %v7: i32
            closure.return %s8: !sigi.stack
        }
        %s9 = sigi.push %s6, %v6: !closure.box<(!sigi.stack) -> !sigi.stack>
        %v9 = closure.box [%v8_n = %v1_n : i32] (%s10 : !sigi.stack) -> !sigi.stack { // -> int
            %s11 = sigi.push %s10, %v8_n: i32 // push n
            %v10 = arith.constant 2: i32
            %s12 = sigi.push %s11, %v10: i32
            // -
            %s13, %v11 = sigi.pop %s12: i32
            %s14, %v12 = sigi.pop %s13: i32
            %v13 = arith.subi %v11, %v12: i32
            %s15 = sigi.push %s14, %v13: i32
            %s16 = func.call @fib_naive(%s15) : (!sigi.stack) -> !sigi.stack // int -> int
            %s17 = sigi.push %s16, %v8_n: i32 // push n
            %v14 = arith.constant 1: i32
            %s18 = sigi.push %s17, %v14: i32
            // -
            %s19, %v15 = sigi.pop %s18: i32
            %s20, %v16 = sigi.pop %s19: i32
            %v17 = arith.subi %v15, %v16: i32
            %s21 = sigi.push %s20, %v17: i32
            %s22 = func.call @fib_naive(%s21) : (!sigi.stack) -> !sigi.stack // int -> int
            // +
            %s23, %v18 = sigi.pop %s22: i32
            %s24, %v19 = sigi.pop %s23: i32
            %v20 = arith.addi %v18, %v19: i32
            %s25 = sigi.push %s24, %v20: i32
            closure.return %s25: !sigi.stack
        }
        %s26 = sigi.push %s9, %v9: !closure.box<(!sigi.stack) -> !sigi.stack>
        %s27, %v21 = sigi.pop %s26: !closure.box<(!sigi.stack) -> !sigi.stack>
        %s28, %v22 = sigi.pop %s27: !closure.box<(!sigi.stack) -> !sigi.stack>
        %s29, %v23 = sigi.pop %s28: i1
        %v24 = scf.if %v23 -> !closure.box<(!sigi.stack) -> !sigi.stack> {
          scf.yield %v22: !closure.box<(!sigi.stack) -> !sigi.stack>
        } else {
          scf.yield %v21: !closure.box<(!sigi.stack) -> !sigi.stack>
        }
        %s30 = sigi.push %s29, %v24: !closure.box<(!sigi.stack) -> !sigi.stack>
        %s31 = func.call @apply(%s30) : (!sigi.stack) -> !sigi.stack // (-> int) -> int
        return %s31: !sigi.stack
    }
    // fib_tailrec: int -> int
    func.func private @fib_tailrec(%s0: !sigi.stack) -> !sigi.stack {
        %v1 = arith.constant 1: i32
        %s1 = sigi.push %s0, %v1: i32
        %v2 = arith.constant 1: i32
        %s2 = sigi.push %s1, %v2: i32
        %s3 = func.call @fib_tailrec_helper(%s2) : (!sigi.stack) -> !sigi.stack // int, int, int -> int
        return %s3: !sigi.stack
    }
    // fib_tailrec_helper: int, int, int -> int
    func.func private @fib_tailrec_helper(%s0: !sigi.stack) -> !sigi.stack {
        // -> n, a, b;
        %s1, %v1_n = sigi.pop %s0: i32 // n: int
        %s2, %v2_a = sigi.pop %s1: i32 // a: int
        %s3, %v3_b = sigi.pop %s2: i32 // b: int
        %s4 = sigi.push %s3, %v1_n: i32 // push n
        %v4 = arith.constant 0: i32
        %s5 = sigi.push %s4, %v4: i32
        // =
        %s6, %v5 = sigi.pop %s5: i32
        %s7, %v6 = sigi.pop %s6: i32
        %v7 = arith.cmpi "eq", %v5, %v6: i32
        %s8 = sigi.push %s7, %v7: i1
        %v9 = closure.box [%v8_a = %v2_a : i32] (%s9 : !sigi.stack) -> !sigi.stack { // -> int
            %s10 = sigi.push %s9, %v8_a: i32 // push a
            closure.return %s10: !sigi.stack
        }
        %s11 = sigi.push %s8, %v9: !closure.box<(!sigi.stack) -> !sigi.stack>
        %v13 = closure.box [%v10_n = %v1_n : i32, %v11_a = %v2_a : i32, %v12_b = %v3_b : i32] (%s12 : !sigi.stack) -> !sigi.stack { // -> int
            %s13 = sigi.push %s12, %v10_n: i32 // push n
            %v14 = arith.constant 1: i32
            %s14 = sigi.push %s13, %v14: i32
            // =
            %s15, %v15 = sigi.pop %s14: i32
            %s16, %v16 = sigi.pop %s15: i32
            %v17 = arith.cmpi "eq", %v15, %v16: i32
            %s17 = sigi.push %s16, %v17: i1
            %v19 = closure.box [%v18_b = %v12_b : i32] (%s18 : !sigi.stack) -> !sigi.stack { // -> int
                %s19 = sigi.push %s18, %v18_b: i32 // push b
                closure.return %s19: !sigi.stack
            }
            %s20 = sigi.push %s17, %v19: !closure.box<(!sigi.stack) -> !sigi.stack>
            %v23 = closure.box [%v20_n = %v10_n : i32, %v21_a = %v11_a : i32, %v22_b = %v12_b : i32] (%s21 : !sigi.stack) -> !sigi.stack { // -> int
                %s22 = sigi.push %s21, %v20_n: i32 // push n
                %v24 = arith.constant 1: i32
                %s23 = sigi.push %s22, %v24: i32
                // -
                %s24, %v25 = sigi.pop %s23: i32
                %s25, %v26 = sigi.pop %s24: i32
                %v27 = arith.subi %v25, %v26: i32
                %s26 = sigi.push %s25, %v27: i32
                %s27 = sigi.push %s26, %v22_b: i32 // push b
                %s28 = sigi.push %s27, %v21_a: i32 // push a
                %s29 = sigi.push %s28, %v22_b: i32 // push b
                // +
                %s30, %v28 = sigi.pop %s29: i32
                %s31, %v29 = sigi.pop %s30: i32
                %v30 = arith.addi %v28, %v29: i32
                %s32 = sigi.push %s31, %v30: i32
                %s33 = func.call @fib_tailrec_helper(%s32) : (!sigi.stack) -> !sigi.stack // int, int, int -> int
                closure.return %s33: !sigi.stack
            }
            %s34 = sigi.push %s20, %v23: !closure.box<(!sigi.stack) -> !sigi.stack>
            %s35, %v31 = sigi.pop %s34: !closure.box<(!sigi.stack) -> !sigi.stack>
            %s36, %v32 = sigi.pop %s35: !closure.box<(!sigi.stack) -> !sigi.stack>
            %s37, %v33 = sigi.pop %s36: i1
            %v34 = scf.if %v33 -> !closure.box<(!sigi.stack) -> !sigi.stack> {
              scf.yield %v32: !closure.box<(!sigi.stack) -> !sigi.stack>
            } else {
              scf.yield %v31: !closure.box<(!sigi.stack) -> !sigi.stack>
            }
            %s38 = sigi.push %s37, %v34: !closure.box<(!sigi.stack) -> !sigi.stack>
            %s39 = func.call @apply(%s38) : (!sigi.stack) -> !sigi.stack // (-> int) -> int
            closure.return %s39: !sigi.stack
        }
        %s40 = sigi.push %s11, %v13: !closure.box<(!sigi.stack) -> !sigi.stack>
        %s41, %v35 = sigi.pop %s40: !closure.box<(!sigi.stack) -> !sigi.stack>
        %s42, %v36 = sigi.pop %s41: !closure.box<(!sigi.stack) -> !sigi.stack>
        %s43, %v37 = sigi.pop %s42: i1
        %v38 = scf.if %v37 -> !closure.box<(!sigi.stack) -> !sigi.stack> {
          scf.yield %v36: !closure.box<(!sigi.stack) -> !sigi.stack>
        } else {
          scf.yield %v35: !closure.box<(!sigi.stack) -> !sigi.stack>
        }
        %s44 = sigi.push %s43, %v38: !closure.box<(!sigi.stack) -> !sigi.stack>
        %s45 = func.call @apply(%s44) : (!sigi.stack) -> !sigi.stack // (-> int) -> int
        return %s45: !sigi.stack
    }
    // __main__: ->
    func.func @__main__(%s0: !sigi.stack) -> !sigi.stack attributes {sigi.main} {
        %v1 = arith.constant 20: i32
        %s1 = sigi.push %s0, %v1: i32
        %s2 = func.call @fib_tailrec(%s1) : (!sigi.stack) -> !sigi.stack // int -> int
        %v2 = arith.constant 20: i32
        %s3 = sigi.push %s2, %v2: i32
        %s4 = func.call @fib_naive(%s3) : (!sigi.stack) -> !sigi.stack // int -> int
        // =
        %s5, %v3 = sigi.pop %s4: i32
        %s6, %v4 = sigi.pop %s5: i32
        %v5 = arith.cmpi "eq", %v3, %v4: i32
        %s7 = sigi.push %s6, %v5: i1
        %s8 = func.call @show(%s7) : (!sigi.stack) -> !sigi.stack // bool ->
        return %s8: !sigi.stack
    }
}
