#include <stdarg.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>

/**
 * DNS query handling strategy
 * - Virtual: Use a virtual DNS server to handle DNS queries, also known as Fake-IP mode
 * - OverTcp: Use TCP to send DNS queries to the DNS server
 * - Direct: Do not handle DNS by relying on DNS server bypassing
 */
typedef enum Tun2proxyDns {
  Tun2proxyDns_Virtual = 0,
  Tun2proxyDns_OverTcp,
  Tun2proxyDns_Direct,
} Tun2proxyDns;

typedef enum Tun2proxyVerbosity {
  Tun2proxyVerbosity_Off = 0,
  Tun2proxyVerbosity_Error,
  Tun2proxyVerbosity_Warn,
  Tun2proxyVerbosity_Info,
  Tun2proxyVerbosity_Debug,
  Tun2proxyVerbosity_Trace,
} Tun2proxyVerbosity;

typedef struct Tun2proxyTrafficStatus {
  uint64_t tx;
  uint64_t rx;
} Tun2proxyTrafficStatus;

#ifdef __cplusplus
extern "C" {
#endif // __cplusplus

/**
 * # Safety
 *
 * Run the tun2proxy component with some arguments.
 * Parameters:
 * - proxy_url: the proxy url, e.g. "socks5://127.0.0.1:1080"
 * - tun_fd: the tun file descriptor, it will be owned by tun2proxy
 * - close_fd_on_drop: whether close the tun_fd on drop
 * - packet_information: whether exists packet information in tun_fd
 * - tun_mtu: the tun mtu
 * - dns_strategy: the dns strategy, see ArgDns enum
 * - verbosity: the verbosity level, see ArgVerbosity enum
 */
int tun2proxy_with_fd_run(const char *proxy_url,
                          int tun_fd,
                          bool close_fd_on_drop,
                          bool packet_information,
                          unsigned short tun_mtu,
                          enum Tun2proxyDns dns_strategy,
                          enum Tun2proxyVerbosity verbosity);

/**
 * # Safety
 *
 * Shutdown the tun2proxy component.
 */
int tun2proxy_with_fd_stop(void);

/**
 * # Safety
 *
 * Run the tun2proxy component with some arguments.
 * Parameters:
 * - proxy_url: the proxy url, e.g. "socks5://127.0.0.1:1080"
 * - tun: the tun device name, e.g. "utun5"
 * - bypass: the bypass IP/CIDR, e.g. "123.45.67.0/24"
 * - dns_strategy: the dns strategy, see ArgDns enum
 * - root_privilege: whether to run with root privilege
 * - verbosity: the verbosity level, see ArgVerbosity enum
 */
int tun2proxy_with_name_run(const char *proxy_url,
                            const char *tun,
                            const char *bypass,
                            enum Tun2proxyDns dns_strategy,
                            bool _root_privilege,
                            enum Tun2proxyVerbosity verbosity);

/**
 * # Safety
 *
 * Shutdown the tun2proxy component.
 */
int tun2proxy_with_name_stop(void);

/**
 * # Safety
 *
 * set dump log info callback.
 */
void tun2proxy_set_log_callback(void (*callback)(enum Tun2proxyVerbosity, const char*, void*),
                                void *ctx);

/**
 * # Safety
 *
 * set traffic status callback.
 */
void tun2proxy_set_traffic_status_callback(uint32_t send_interval_secs,
                                           void (*callback)(const struct Tun2proxyTrafficStatus*,
                                                            void*),
                                           void *ctx);

#ifdef __cplusplus
} // extern "C"
#endif // __cplusplus
