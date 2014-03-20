#if defined (__APPLE__) 
#include <mach/mach.h> 
#include <sys/resource.h> 
#endif 
static int gettid() 
{ 
#if defined(__APPLE__) 
  return mach_thread_self(); 
#elif defined(linux) 
  return syscall(__NR_gettid); 
#else 
  return -ENOSYS; 
#endif 
} 
