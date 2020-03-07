#include "include/libplatform/libplatform.h"
#include "include/v8.h"
#include "src/compiler/wasm-compiler.h"
#include "src/compiler/zone-stats.h"
#include "src/execution/isolate.h"
#include "src/wasm/wasm-engine.h"
#include "src/wasm/wasm-module.h"
#include "src/wasm/wasm-objects-inl.h"
#include "src/wasm/wasm-objects.h"
#include <iomanip>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

namespace v8 {
namespace base {
#define DEFINE_MAKE_CHECK_OP_STRING(type)                                      \
  template std::string *MakeCheckOpString<type, type>(type, type,              \
                                                      char const *);           \
  template std::string PrintCheckOperand<type>(type);
DEFINE_MAKE_CHECK_OP_STRING(int)
DEFINE_MAKE_CHECK_OP_STRING(long)      // NOLINT(runtime/int)
DEFINE_MAKE_CHECK_OP_STRING(long long) // NOLINT(runtime/int)
DEFINE_MAKE_CHECK_OP_STRING(unsigned int)
DEFINE_MAKE_CHECK_OP_STRING(unsigned long)      // NOLINT(runtime/int)
DEFINE_MAKE_CHECK_OP_STRING(unsigned long long) // NOLINT(runtime/int)
DEFINE_MAKE_CHECK_OP_STRING(void const *)
#undef DEFINE_MAKE_CHECK_OP_STRING
} // namespace base
} // namespace v8

std::vector<v8::internal::byte> readFile(const char *filename) {
  std::ifstream file(filename, std::ios::binary);
  file.unsetf(std::ios::skipws);
  std::streampos fileSize;
  file.seekg(0, std::ios::end);
  fileSize = file.tellg();
  file.seekg(0, std::ios::beg);
  std::vector<v8::internal::byte> vec;
  vec.reserve(fileSize);
  vec.insert(vec.begin(), std::istream_iterator<v8::internal::byte>(file),
             std::istream_iterator<v8::internal::byte>());
  return vec;
}

int main(int argc, char *argv[]) {
  using namespace v8::internal::wasm;
  using namespace v8::internal;
  i::FLAG_experimental_wasm_simd = true;
  // i::FLAG_perf_prof_annotate_wasm = true;
  // i::FLAG_code_comments = true;
  i::FLAG_opt = true;
  i::FLAG_wasm_opt = true;
  i::FLAG_wasm_stack_checks = false;
  i::FLAG_liftoff = false;
  i::FLAG_debug_code = false;
  i::FLAG_always_opt = true;
  i::FLAG_enable_sse3 = true;
  i::FLAG_enable_ssse3 = true;
  i::FLAG_enable_sse4_1 = true;
  i::FLAG_enable_sse4_2 = true;
  i::FLAG_wasm_bounds_checks = false;
  v8::V8::InitializeICUDefaultLocation(argv[0]);
  v8::V8::InitializeExternalStartupData(argv[0]);
  std::unique_ptr<v8::Platform> platform(v8::platform::NewDefaultPlatform());
  v8::V8::InitializePlatform(platform.get());
  v8::internal::FlagList::SetFlagsFromCommandLine(&argc, argv, true);
  v8::V8::Initialize();

  v8::Isolate::CreateParams create_params;
  create_params.array_buffer_allocator =
      v8::ArrayBuffer::Allocator::NewDefaultAllocator();
  v8::Isolate *isolate = v8::Isolate::New(create_params);

  i::Isolate *i_isolate = reinterpret_cast<v8::internal::Isolate *>(isolate);
  v8::HandleScope handle_scope(isolate);
  i::HandleScope internal_scope(i_isolate);
  v8::Local<v8::Context> ctx = v8::Context::New(isolate);
  v8::Context::Scope context_scope(ctx);

  v8::Isolate::Scope isolate_scope(isolate);

  std::vector<byte> raw_bytes = readFile(argv[1]);
  auto bytes = ModuleWireBytes(&raw_bytes[0], &raw_bytes[0] + raw_bytes.size());

  auto enabled_features =
      WasmFeatures::FromIsolate((v8::internal::Isolate *)isolate);
  ErrorThrower thrower(i_isolate, "CompileAndRunWasmModule");
  Handle<WasmModuleObject> module_obj =
      i_isolate->wasm_engine()
          ->SyncCompile(i_isolate, enabled_features, &thrower, bytes)
          .ToHandleChecked();
  // Handle<WasmInstanceObject> instance_obj =
  //     i_isolate->wasm_engine()
  //         ->SyncInstantiate(i_isolate, &thrower, module_obj, {}, {})
  //         .ToHandleChecked();
  WasmModule const *module = module_obj->module();
  auto &funcs = module->functions;
  for (int i = 0; i < funcs.size(); i++) {
    auto function = &funcs[i];
    Vector<const uint8_t> wire_bytes =
        module_obj->native_module()->wire_bytes();

    CompilationEnv env = module_obj->native_module()->CreateCompilationEnv();
    ScopedVector<uint8_t> func_wire_bytes(function->code.length());
    memcpy(func_wire_bytes.begin(),
           wire_bytes.begin() + function->code.offset(),
           func_wire_bytes.length());
    FunctionBody func_body{function->sig, function->code.offset(),
                           func_wire_bytes.begin(), func_wire_bytes.end()};
    NativeModule *native_module = module_obj->native_module();
    WasmCompilationUnit unit(function->func_index, ExecutionTier::kTurbofan);
    WasmFeatures unused_detected_features;
    WasmCompilationResult result = unit.ExecuteCompilation(
        i_isolate->wasm_engine(), &env,
        native_module->compilation_state()->GetWireBytesStorage(),
        i_isolate->counters(), &unused_detected_features);
    WasmCodeRefScope code_ref_scope;
    WasmCode *code = native_module->AddCompiledCode(std::move(result));
    DCHECK_NOT_NULL(code);
  }
  {
    std::ofstream out("module.bin", std::ios::out | std::ofstream::binary);
    // execute to get hex dump
    // od -A n -t x1 module.bin
    // or to get disassembly
    // objdump -M intel -D -b binary -m i386:x86-64 module.bin
    auto print = [&out](byte const *origin, size_t size) {
      // byte const *ptr = origin;
      // byte const *end = origin + size;
      // uint64_t dbg_cnt = 1 << 30;
      // while(ptr != end &&
      //   (dbg_cnt-->0)) {
      //     std::cout << std::internal << std::setfill('0') << std::setw(2) <<
      //     std::hex << (int)(*ptr++) << " ";
      // }
      // std::cout << "\n";
      out.write((char const *)origin, size);
    };
    NativeModule *native_module = module_obj->native_module();
    auto wasm_codes = native_module->SnapshotCodeTable();
    for (WasmCode *wasm_code : wasm_codes) {
      if (wasm_code->kind() != WasmCode::Kind::kFunction)
        continue;
      wasm_code->Print();
      auto const &instructions = wasm_code->instructions();
      int instruction_size = wasm_code->unpadded_binary_size();
      if (wasm_code->constant_pool_offset() < instruction_size) {
        instruction_size = wasm_code->constant_pool_offset();
      }
      if (wasm_code->safepoint_table_offset() &&
          wasm_code->safepoint_table_offset() < instruction_size) {
        instruction_size = wasm_code->safepoint_table_offset();
      }
      if (wasm_code->handler_table_offset() < instruction_size) {
        instruction_size = wasm_code->handler_table_offset();
      }
      print(&instructions[0], instruction_size);
      byte nops[] = {0x90, 0x90, 0x90, 0x90, 0x90,
                     0x90, 0x90, 0x90, 0x90, 0x90};
      print(nops, sizeof nops);
    }
  }
  v8::V8::Dispose();
  v8::V8::ShutdownPlatform();
  return 0;
}
