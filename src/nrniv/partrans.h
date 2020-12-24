#ifndef partrans_h
#define partrans_h

// For consistency between partrans.cpp and
// nrncore_write/callbacks/nrncore_callbacks.h

#ifndef NRNLONGSGID
#define NRNLONGSGID 0
#endif

#if NRNLONGSGID
typedef int64_t sgid_t;
#else
typedef int sgid_t;
#endif

// For direct transfer
// must be same as corresponding struct SetupTransferInfo in CoreNEURON
// see partrans.cpp
struct SetupTransferInfo {
  std::vector<sgid_t> src_sid;
  std::vector<int> src_type;
  std::vector<int> src_index;

  std::vector<sgid_t> tar_sid;
  std::vector<int> tar_type;
  std::vector<int> tar_index;
};
                   
extern "C" {
extern void get_partrans_setup_info(int, int, size_t, SetupTransferInfo**);
}

#endif // partrans_h