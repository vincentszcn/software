#pragma once

#ifndef VC_EXTRALEAN
#define VC_EXTRALEAN		// Exclude rarely-used stuff from Windows headers
#endif

// Modify the following defines if you have to target a platform prior to the ones specified below.
// Refer to MSDN for the latest info on corresponding values for different platforms.
#ifndef WINVER				// Allow use of features specific to Windows 95 and Windows NT 4 or later.
#define WINVER 0x0500		// Change this to the appropriate value to target Windows 98 and Windows 2000 or later.
#endif

#ifndef _WIN32_WINNT		// Allow use of features specific to Windows NT 4 or later.
#define _WIN32_WINNT 0x0500	// Change this to the appropriate value to target Windows 2000 or later.
#endif						

#ifndef _WIN32_WINDOWS		// Allow use of features specific to Windows 98 or later.
#define _WIN32_WINDOWS 0x0500 // Change this to the appropriate value to target Windows Me or later.
#endif

#ifndef _WIN32_IE			// Allow use of features specific to IE 4.0 or later.
#define _WIN32_IE 0x0500	// Change this to the appropriate value to target IE 5.0 or later.
#endif

#define _ATL_CSTRING_EXPLICIT_CONSTRUCTORS	// some CAtlString constructors will be explicit

//	允许程序在退出时检测内存泄漏,并将内存泄漏相关代码的调用堆栈打印出来
//	如果不需要此功能请注释下面一行
#define VLD_MAX_DATA_DUMP 0x100
#define USE_VLD

//	允许程序处理未处理异常，即程序在崩溃时可以得到完整的崩溃信息及调用堆栈
//	如果不需要此功能请注释下面一行
//#define USE_STACK_WALKER

//	使用自定义的TRACE,除TRACE的功能外，可以将调试信息记录于文件中
//	如果不需要此功能请注释下面一行
#define USE_LOG_TRACE
#define BEGIN_NAMESPACE(x)	namespace x {
#define ENDOF_NAMESPACE(x)	}

#include <atlbase.h>
#include <atlconv.h>
#include <atlstr.h>
#include <string>
using std::string;
using std::wstring;
#ifdef _UNICODE
typedef wstring tstring;
#else
typedef string tstring;
#endif
#include <tchar.h>

#include "PPSBaseClasses/AutoLock.h"
#include "StackWalker/WheatyExceptionReport.h"
#include "StackWalker/LogInfo.h"
#include "StackWalker/SEHException.h"

#pragma comment(linker, "/include:?g_WheatyExceptionReport@@3VWheatyExceptionReport@@A")

#include <classbase.h>
#include <netframe/netbase.h>
#include <netframe/datastream.h>
#include <CyHash.h>
typedef CSha1 FID;
typedef CSha1 URLID;
typedef CSha1 CClientID;

#include <boost/utility.hpp>
#include <boost/smart_ptr.hpp>
using namespace boost;

#include <map>
#include <vector>
#include <algorithm>
#include <list>
#include <queue>
using namespace std;


#undef min
#undef max
#define min(x,y)	 ((x)<(y)?(x):(y))
#define max(x,y)	((x)>(y)?(x):(y))

#pragma warning(disable:4702)
#pragma warning(disable:4541)
#define LOGLINE	PTRACE("[TID:%u]Go to %s.%d.\r\n", GetCurrentThreadId(), __FUNCTION__, __LINE__)
struct DefaultPredicate
{
	template <class T> 
		static bool Wrong(const T& obj)
	{
		return !obj;
	}
};
struct DefaultRaiser
{
	template <class T>
		static void Throw(const T&, const std::string& message, const char* locus)
	{
		throw std::runtime_error(message + locus);
	}
};

template<typename Ref, typename P, typename R>
class Enforcer
{
public:
	Enforcer(Ref t, const char* locus) : t_(t), locus_(P::Wrong(t) ? locus : 0)
	{
	}
	Ref operator*() const
	{
		if (locus_) R::Throw(t_, msg_, locus_);
		return t_;
	}
	template <class MsgType>
		Enforcer& operator()(const MsgType& msg)
	{
		if (locus_) 
		{
			// Here we have time; no need to be super-efficient
			std::ostringstream ss;
			ss << msg;
			msg_ += ss.str();
		}
		return *this;
	}
private:
	Ref t_;
	std::string msg_;
	const char* const locus_;
};

template <class P, class R, typename T>
inline Enforcer<const T&, P, R> 
MakeEnforcer(const T& t, const char* locus)
{
	return Enforcer<const T&, P, R>(t, locus);
}

template <class P, class R, typename T>
inline Enforcer<T&, P, R> 
MakeEnforcer(T& t, const char* locus)
{
	return Enforcer<T&, P, R>(t, locus);
}

#define ENFORCE(exp) \
	*MakeEnforcer<DefaultPredicate, DefaultRaiser>(\
	(exp), #exp)

#define TestFlag(x,y)	((x)==((x)&(y)))
#define LOG_NOTMATCH(x,y)	PTRACE("%s.%d(%s != %s, %u != %u)\r\n", __FUNCTION__, __LINE__, #x, #y, x, y)
#define LOG_NOTMATCH2(x,y)	PTRACE("%s.%d(%s != %s, %I64u != %I64u)\r\n", __FUNCTION__, __LINE__, #x, #y, x, y)
#define CHECK_PACKAGE_LENGTH(T)	if(package->GetDataLength() < sizeof(T)){LOG_NOTMATCH(package->GetDataLength(), sizeof(T));return E_FAIL;}

extern BOOL SetThreadName(char* pszName);
extern char* GetThreadName(void);
extern void WriteMiniDump(_EXCEPTION_POINTERS* pExcPointers=NULL);

#define NAMETHETHREAD(x)	{char threadName[256]={0};sprintf(threadName, "%s@%d", x, GetCurrentThreadId());SetThreadName(threadName);}
#define WAIT_THREADEXIT(x, y)	{if(WAIT_TIMEOUT==WaitForSingleObject(x, y)){TerminateThread(x, y);PTRACE("Thread not exited safely: %s in %u ms!\r\n", #x, y);}CloseHandle(x);}

#ifdef USE_LOG_TRACE		
#define PTRACE LogInfo::Instance()->WriteLog_Timestamp
#define	LOG_MSG	LogInfo::Instance()->WriteLog
#define DUMPBLOCK	LogInfo::Instance()->WriteLog_Locked
#else
#define PTRACE	TRACE
#define LOG_MSG	TRACE
#define DUMPBLOCK	TRACE
#endif

#ifdef USE_STACK_WALKER
#define DumpCallStack()	WheatyExceptionReport::ShowCallstack()
#define MYASSERT(x)	if(!(x)){PTRACE("[TID:%u]ASSERT FAILED!<%s>(%s at %s.%d)", GetCurrentThreadId(), #x, __TIMESTAMP__, __FUNCTION__, __LINE__);DumpCallStack();}

#define CTRY	try{
#define CCATCH	}						\
	catch(CSEHException* se){WriteMiniDump();PTRACE("[TID:%u]EXCEPTION at <%s>%s.%d)",  GetCurrentThreadId(), __TIMESTAMP__, __FUNCTION__, __LINE__);se->ReportError();delete se;extern void RestartMe(void); RestartMe();			\
	}						\
	catch(...){WriteMiniDump();PTRACE("[TID:%u]EXCEPTION at <%s>%s.%d)",  GetCurrentThreadId(), __TIMESTAMP__, __FUNCTION__, __LINE__);DumpCallStack();extern void RestartMe(void); RestartMe();}
#else
#define CTRY
#define CCATCH
#define MYASSERT	ATLASSERT
#define DumpCallStack()	WheatyExceptionReport::ShowCallstack()
#endif

#include "threadtracer.h"