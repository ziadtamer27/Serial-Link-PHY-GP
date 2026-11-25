#ifndef RTW_HEADER_PLL0_cap_host_h__
#define RTW_HEADER_PLL0_cap_host_h__
#ifdef HOST_CAPI_BUILD
#include "rtw_capi.h"
#include "rtw_modelmap.h"

typedef struct {
  rtwCAPI_ModelMappingInfo mmi;
} PLL0_host_DataMapInfo_T;

#ifdef __cplusplus

extern "C"
{

#endif

  void PLL0_host_InitializeDataMapInfo(PLL0_host_DataMapInfo_T *dataMap, const
    char *path);

#ifdef __cplusplus

}

#endif
#endif                                 /* HOST_CAPI_BUILD */
#endif                                 /* RTW_HEADER_PLL0_cap_host_h__ */

/* EOF: PLL0_capi_host.h */
