(module
 (memory $memory 256 256)
 (export "memory" (memory $memory))
 (export "bench_main" (func $bench_main))
 (func $bench_main (param $0 i32) (param $1 i32) (param $2 i32) (param $3 i32)
  (local $4 i32)
  (local $5 i32)
  (local.set $4
    (i32.const 0)
  )
  (local.set $5
    (i32.mul
      (local.get $3)
      (i32.const 4)
    )
  )
  (loop $label$1
    (v128.store align=4
        (i32.add
          (local.get $0)
          (local.get $4)
        )
        (i32x4.mul
          (v128.load align=4
            (i32.add
              (local.get $1)
              (local.get $4)
            )
          )
          (v128.load align=4
            (i32.add
              (local.get $2)
              (local.get $4)
            )
          )
        )
        
    )
    (local.set $4
      (i32.add
        (local.get $4)
        (i32.const 16)
      )
    )
    (br_if $label$1
      (i32.lt_s
        (local.get $4)
        (local.get $5)
      )
    )
  )
 )
)