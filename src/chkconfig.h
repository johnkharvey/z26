
#if defined(LINUX_RTC_TIMING) && (!defined(__linux__))
#error LINUX_RTC_TIMING only makes sense on Linux.
#endif

#if defined(LINUX_RTC_TIMING) && !defined(UNIX_TIMING)
#error LINUX_RTC_TIMING requires UNIX_TIMING to also be defined.
#endif

#if !defined(WINDOWS) && !defined(LINUX_RTC_TIMING) && !defined(UNIX_TIMING)
#warning Using SDL_Delay() timing only. Not recommended on Linux/UNIX (edit config.h)
#endif

