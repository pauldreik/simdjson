#include "simdjson/jsonparser.h"
#include "simdjson/isadetection.h"
#include "simdjson/portability.h"
#include "simdjson/simdjson.h"
#include <atomic>

namespace simdjson {

// The function that users are expected to call is json_parse.
// We have more than one such function because we want to support several
// instruction sets.

// function pointer type for json_parse
using json_parse_functype = int(const uint8_t *buf, size_t len, ParsedJson &pj,
                                bool realloc);

// Pointer that holds the json_parse implementation corresponding to the
// available SIMD instruction set
extern std::atomic<json_parse_functype *> json_parse_ptr;

int json_parse(const uint8_t *buf, size_t len, ParsedJson &pj,
               bool realloc) {
  return json_parse_ptr.load(std::memory_order_relaxed)(buf, len, pj, realloc);
}

int json_parse(const char *buf, size_t len, ParsedJson &pj,
               bool realloc) {
  return json_parse_ptr.load(std::memory_order_relaxed)(reinterpret_cast<const uint8_t *>(buf), len, pj,
                                                        realloc);
}

Architecture find_best_supported_implementation() {
  constexpr uint32_t haswell_flags =
      instruction_set::AVX2 | instruction_set::PCLMULQDQ |
      instruction_set::BMI1 | instruction_set::BMI2;
  constexpr uint32_t westmere_flags =
      instruction_set::SSE42 | instruction_set::PCLMULQDQ;

  uint32_t supports = detect_supported_architectures();
  // Order from best to worst (within architecture)
  if ((haswell_flags & supports) == haswell_flags)
    return Architecture::HASWELL;
  if ((westmere_flags & supports) == westmere_flags)
    return Architecture::WESTMERE;
  if (instruction_set::NEON)
    return Architecture::ARM64;

  return Architecture::NONE;
}

// Responsible to select the best json_parse implementation
int json_parse_dispatch(const uint8_t *buf, size_t len, ParsedJson &pj,
                        bool realloc) {
  Architecture best_implementation = find_best_supported_implementation();
  // Selecting the best implementation
  switch (best_implementation) {
#ifdef IS_X86_64
  case Architecture::HASWELL:
    json_parse_ptr.store(&json_parse_implementation<Architecture::HASWELL>, std::memory_order_relaxed);
    break;
  case Architecture::WESTMERE:
    json_parse_ptr.store(&json_parse_implementation<Architecture::WESTMERE>, std::memory_order_relaxed);
    break;
#endif
#ifdef IS_ARM64
  case Architecture::ARM64:
    json_parse_ptr.store(&json_parse_implementation<Architecture::ARM64>, std::memory_order_relaxed);
    break;
#endif
  default:
    std::cerr << "The processor is not supported by simdjson." << std::endl;
    return simdjson::UNEXPECTED_ERROR;
  }

  return json_parse_ptr.load(std::memory_order_relaxed)(buf, len, pj, realloc);
}

std::atomic<json_parse_functype *> json_parse_ptr{&json_parse_dispatch};

WARN_UNUSED
ParsedJson build_parsed_json(const uint8_t *buf, size_t len,
                             bool realloc) {
  ParsedJson pj;
  bool ok = pj.allocate_capacity(len);
  if (ok) {
    json_parse(buf, len, pj, realloc);
  } else {
    std::cerr << "failure during memory allocation " << std::endl;
  }
  return pj;
}
} // namespace simdjson
