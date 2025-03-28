/*
	scapix/link/cs/struct.h

	Copyright (c) 2019-2023 Boris Rasin (boris@scapix.com)
*/

#ifndef SCAPIX_LINK_CS_STRUCT_H
#define SCAPIX_LINK_CS_STRUCT_H

#include <type_traits>

namespace scapix::link::cs {

template <typename Struct>
struct struct_;

template <typename T, typename = void>
struct is_struct : std::false_type {};

template <typename T>
struct is_struct<T, std::void_t<typename struct_<T>::fields>> : std::true_type {};

template <typename T>
constexpr bool is_struct_v = is_struct<T>::value;

} // namespace scapix::link::cs

#endif // SCAPIX_LINK_CS_STRUCT_H
