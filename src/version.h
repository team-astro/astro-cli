#include <astro/astro.h>
#include <astro/memory.h>

namespace astro
{
  struct version
  {
    uint16 major;
    uint16 minor;
    uint16 patch;

    static version parse(const char* input);
    static const char* to_string(version ver, allocator alloc);
  };

  const char* version_fmt = "%d.%d.%d";

  version
  version::parse(const char* input)
  {
    version result = {};

    // TODO: Support suffix strings? ie, "1.0.0-alpha"
    // TODO: Support prefix strings? ie, "v1.0"
    sscanf(input, version_fmt, &result.major, &result.minor, &result.patch);

    return result;
  }

  const char*
  version::to_string(version ver, allocator alloc)
  {
    int size = std::snprintf(nullptr, 0, version_fmt, ver.major, ver.minor, ver.patch) + 1;
    char* result = (char*)alloc.allocate(size);
    std::snprintf(result, size, version_fmt, ver.major, ver.minor, ver.patch);

    return result;
  }
}
