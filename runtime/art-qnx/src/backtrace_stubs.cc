/*
 * QNX port: BacktraceMap implementation.
 *
 * QNX has no /proc/<pid>/maps; instead /proc/<pid>/mappings is a CSV with a
 * header line and one entry per page. Merge consecutive pages that share the
 * same protection and name into single ranges so ContainedWithinExistingMap
 * works. Falls back to the Linux maps format for host builds.
 */

#include <backtrace/BacktraceMap.h>

#include <inttypes.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <deque>
#include <string>
#include <vector>

BacktraceMap::BacktraceMap(pid_t pid) : pid_(pid) {}

BacktraceMap::~BacktraceMap() {}

bool BacktraceMap::ParseLine(const char* line, backtrace_map_t* map) {
  (void)line;
  (void)map;
  return false;
}

BacktraceMap* BacktraceMap::Create(pid_t pid, bool uncached) {
  (void)uncached;
  BacktraceMap* map = new BacktraceMap(pid);
  if (!map->Build()) {
    delete map;
    return nullptr;
  }
  return map;
}

static bool ParseQnxLine(char* line, uintptr_t* start, int* prot, std::string* name) {
  char* fields[15];
  int n = 0;
  char* saveptr = nullptr;
  for (char* p = strtok_r(line, ",", &saveptr); p != nullptr && n < 15;
       p = strtok_r(nullptr, ",", &saveptr)) {
    fields[n++] = p;
  }
  if (n < 15) {
    return false;
  }
  *start = static_cast<uintptr_t>(strtoull(fields[0], nullptr, 16));
  *prot = static_cast<int>(strtoul(fields[4], nullptr, 16));
  *name = fields[14];
  return true;
}

static bool ParseLinuxLine(char* line, backtrace_map_t* map) {
  uintptr_t start, end;
  uintptr_t offset;
  char perms[5];
  int path_pos;
  if (sscanf(line, "%" SCNxPTR "-%" SCNxPTR " %4s %" SCNxPTR " %*x %*x %n", &start, &end,
             perms, &offset, &path_pos) != 4) {
    return false;
  }
  map->start = start;
  map->end = end;
  map->offset = offset;
  map->flags = 0;
  if (perms[0] == 'r') map->flags |= PROT_READ;
  if (perms[1] == 'w') map->flags |= PROT_WRITE;
  if (perms[2] == 'x') map->flags |= PROT_EXEC;
  while (line[path_pos] != '\0' && line[path_pos] == ' ') {
    path_pos++;
  }
  if (line[path_pos] == '\0') {
    map->name.clear();
  } else {
    map->name = line + path_pos;
  }
  map->load_base = map->start - map->offset;
  return true;
}

bool BacktraceMap::Build() {
  maps_.clear();

  char path[64];
  snprintf(path, sizeof(path), "/proc/%d/mappings", static_cast<int>(pid_));
  FILE* fp = fopen(path, "re");
  if (fp != nullptr) {
    char line[512];
    uintptr_t range_start = 0;
    uintptr_t range_end = 0;
    int range_prot = -1;
    std::string range_name;

    auto flush = [&]() {
      if (range_start != range_end) {
        backtrace_map_t map;
        map.start = range_start;
        map.end = range_end;
        map.flags = range_prot;
        map.name = range_name;
        map.offset = 0;
        map.load_base = range_start;
        maps_.push_back(map);
      }
    };

    bool first = true;
    while (fgets(line, sizeof(line), fp) != nullptr) {
      if (first) {
        first = false;
        continue;  // CSV header
      }
      uintptr_t start;
      int prot;
      std::string name;
      if (!ParseQnxLine(line, &start, &prot, &name)) {
        continue;
      }
      if (start == range_end && prot == range_prot && name == range_name) {
        range_end = start + 0x1000;
        continue;
      }
      flush();
      range_start = start;
      range_end = start + 0x1000;
      range_prot = prot;
      range_name = name;
    }
    flush();
    fclose(fp);
    return !maps_.empty();
  }

  snprintf(path, sizeof(path), "/proc/%d/maps", static_cast<int>(pid_));
  fp = fopen(path, "re");
  if (fp == nullptr) {
    return false;
  }
  char line[512];
  while (fgets(line, sizeof(line), fp) != nullptr) {
    backtrace_map_t map;
    if (ParseLinuxLine(line, &map)) {
      maps_.push_back(map);
    }
  }
  fclose(fp);
  return !maps_.empty();
}

void BacktraceMap::FillIn(uintptr_t addr, backtrace_map_t* map) {
  for (auto it = maps_.begin(); it != maps_.end(); ++it) {
    if (addr >= it->start && addr < it->end) {
      *map = *it;
      return;
    }
  }
  *map = backtrace_map_t();
}
