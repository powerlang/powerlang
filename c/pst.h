#ifndef _PST_H_
#define _PST_H_

#include <cstdint>

typedef unsigned long ulong;
typedef unsigned short ushort;
typedef unsigned char uchar;

#define WORD_SIZE 8
#define WORD_SIZE_SHIFT 3

namespace pst {

struct small_header_t;
struct large_header_t;
struct oop_t;

typedef oop_t* slot_t;

void osError();
void error(const char *message);
void debug(const char *message);

}

#endif // _PST_H_

