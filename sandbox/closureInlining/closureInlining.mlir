module {
  func.func private @"sigi::pp"(!sigi.stack) -> !sigi.stack attributes {sigi.builtinfunc}
  func.func @__main__(%arg0: !sigi.stack) -> !sigi.stack attributes {sigi.main} {
    %c2_i32 = arith.constant 2 : i32
    %c1_i32 = arith.constant 1 : i32
    %0 = sigi.push %arg0, %c1_i32 : i32
    %1 = sigi.push %0, %c2_i32 : i32
    %2 = closure.box [](%arg1: !sigi.stack) -> !sigi.stack {
      %c1_i32_0 = arith.constant 1 : i32
      %outStack, %value = sigi.pop %arg1 : i32
      %outStack_1, %value_2 = sigi.pop %outStack : i32
      %4 = arith.muli %value_2, %value : i32
      %5 = arith.addi %4, %c1_i32_0 : i32
      %6 = sigi.push %outStack_1, %5 : i32
      %7 = func.call @"sigi::pp"(%6) : (!sigi.stack) -> !sigi.stack
      closure.return %7 : !sigi.stack
    }
    %3 = closure.call %2(%1) : <(!sigi.stack) -> !sigi.stack>
    return %3 : !sigi.stack
  }
}

