/*
 * Benchmark for extracting string_views vs. string vs. raw json,
 * see https://github.com/simdjson/simdjson/pull/1232#issuecomment-710263849
 *
 * By Paul Dreik 20201017, with some parts copied/adapted from Lemire's code.
 */
#include "simdjson.h"

#include <iostream>
#include <vector>
#include <string>
#include <chrono>

namespace od=simdjson::fallback::ondemand;

size_t counter=0;

// from https://github.com/lemire/Code-used-on-Daniel-Lemire-s-blog/blob/master/2020/08/08/test.cpp
template <class T>
__attribute__((noinline)) void do_not_optimize(const std::vector<T> &source) {
  counter += source.size();
  asm volatile("" ::: "memory");
}

struct StopWatch {
  StopWatch() {
    m_start=std::chrono::high_resolution_clock::now();
  }
  void stop() {
    m_stop=std::chrono::high_resolution_clock::now();
  }
  double elapsed() const {
    std::chrono::duration<double> d=m_stop-m_start;
    return d.count();
  }
  double ops_per_second(double ops) const {return ops/elapsed();}

  void print(const char* name, std::ostream& os, double ops) const {
    os<<name<<" took "<<elapsed()<<" s, "<<ops_per_second(ops)<<" keys/s\n";
  }
  std::chrono::time_point<std::chrono::high_resolution_clock> m_start;
  std::chrono::time_point<std::chrono::high_resolution_clock> m_stop;
};

std::vector<od::raw_json_string> extract_raw(const simdjson::padded_string& json, const char* select) {
  od::parser p;
  std::vector<od::raw_json_string> ret;

  auto doc=p.iterate(json);
  for(od::object object: doc[select]) {
    for(auto field : object)  {
      ret.emplace_back(field.key());
    }
  }
  return ret;
}

std::vector<std::string_view> extract_stringviews(const simdjson::padded_string& json, const char* select) {
  od::parser p;
  std::vector<std::string_view> ret;

  auto doc=p.iterate(json);
  for(od::object object: doc[select]) {
    for(auto field : object)  {
      ret.emplace_back(field.key_as_string());
    }
  }
  return ret;
}

std::vector<std::string> extract_strings(const simdjson::padded_string& json, const char* select) {
  od::parser p;
  std::vector<std::string> ret;

  auto doc=p.iterate(json);
  for(od::object object: doc[select]) {
    for(auto field : object)  {
      std::string_view keyv = field.key_as_string();
      ret.emplace_back(keyv);
    }
  }
  return ret;
}

int main(int argc, char* argv[]) {
  auto json=simdjson::padded_string::load(argv[1]).take_value();

  // for twitter.json
  const char* select=argc>2?argv[2]:"statuses";

  {
    counter=0;
    StopWatch s;
    for(int i=0; i<1000; ++i) {
      auto keys=extract_stringviews(json,select);
      do_not_optimize(keys);
    }
    s.stop();
    s.print("std::string_view",std::cout,counter);
  }

  {
    counter=0;
    StopWatch s;
    for(int i=0; i<1000; ++i) {
      auto keys=extract_strings(json,select);
      do_not_optimize(keys);
    }
    s.stop();
    s.print("std::string",std::cout,counter);
  }

  {
    counter=0;
    StopWatch s;
    for(int i=0; i<1000; ++i) {
      auto keys=extract_raw(json,select);
      do_not_optimize(keys);
    }
    s.stop();
    s.print("raw_json",std::cout,counter);
  }
}
