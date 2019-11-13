#include "simdjson/jsonparser.h"
#include <cstddef>
#include <cstdint>
#include <iostream>
#include <string>

// from https://stackoverflow.com/a/8244052
class NulStreambuf : public std::streambuf {
  char dummyBuffer[64];

protected:
  virtual int overflow(int c) override final{
    setp(dummyBuffer, dummyBuffer + sizeof(dummyBuffer));
    return (c == traits_type::eof()) ? '\0' : c;
  }
};

class NulOStream final : private NulStreambuf, public std::ostream {
public:
  NulOStream() : std::ostream(this) {}
  NulStreambuf *rdbuf() { return this; }
};


extern "C" int LLVMFuzzerTestOneInput(const uint8_t *Data, size_t Size) {

  try {
    auto pj = simdjson::build_parsed_json(Data, Size);
    NulOStream os;
    bool ignored=pj.print_json(os);
  } catch (...) {
  }
  return 0;
}
