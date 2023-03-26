// RUN: sigi-opt %s -split-input-file -verify-diagnostics



func.func @return_closure(%arg0: i32) -> !closure.box<(i32) -> i32> {
    // expected-note@+1 {{region isolation constraint}}
    %6 = closure.box [] (%2 : i32) -> i32 {
        // expected-error@+1 {{op using value defined outside the region}}
        %9 = arith.addi %2, %arg0: i32
        closure.return %9: i32
    }
    return %6: !closure.box<(i32) -> i32>
}

// -----
