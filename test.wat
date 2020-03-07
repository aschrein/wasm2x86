(module
 (memory $0 256 256)
 (export "memory" (memory $0))
 (export "main" (func $1))
 (func $1 (param $0 i32)
  (local $1 i32)
  (loop $label$1
    (v128.store align=4
        (i32.add
          (i32.const 0)
          (i32.const 0)
        )
        (i32x4.mul
        (v128.load align=4
          (i32.add
            (i32.const 0)
            (i32.const 16)
          )
        )
        (v128.load align=4
          (i32.add
            (i32.const 0)
            (i32.const 32)
          )
        )
        )
        
    )
    (local.set $1
      (i32.sub
        (local.get $1)
        (i32.const 1)
      )
    )
    (br_if $label$1
    (i32.lt_s
      (local.get $1)
      (i32.const 0)
    )
   )
  )
 )
)