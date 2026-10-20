
#pragma once

#include "../libs/EASTL-forge1.51/string.h"

struct eastlBasicString {
    eastlBasicString(const char *str) {
        mData = str;
        mSize = strlen(str);
        mCapacity = mSize + 1;
    }

    eastl::basic_string<char8_t, eastl::allocator_forge> *CastToEASTL() {
        return reinterpret_cast<eastl::basic_string<char8_t, eastl::allocator_forge> *>(this);
    }

    const char *mData;
    size_t mSize;
    size_t mCapacity;
};
static_assert(sizeof(eastlBasicString) == 0x18, "Incorrect eastl::basic_string size");
