a::n0:
!= 0
a:!= NULL:NN:
!= NULL
a:!= nullptr:nn:
!= nullptr
a::#d:
#define 
a::#e:
#else
a::#en:
#endif
a:#if 0 ... #endif:#if:
#if 0
$selected$$end$
#endif

a:#ifdef ... #endif:#if:
#ifdef $end$
$selected$
#endif

a:#ifdef guard in a header::
#ifndef $FILE_BASE$_h__
#define $FILE_BASE$_h__

$selected$
#endif // $FILE_BASE$_h__

a:#ifndef ... #endif:#ifn:
#ifndef $end$
$selected$
#endif

a::#im:
#import "$end$"
a::#im:
#import <$end$>
a::#in:
#include "$end$"
a::#in:
#include <$end$>
a::#p:
#pragma 
a::#u:
#undef 
a::bas:
$BaseClassName$::$MethodName$($MethodArgs$);


a::/*-:
/*
 *	$end$
 */
a::/**:
/************************************************************************/
/* $end$                                                                     */
/************************************************************************/
a:://-:
// $end$ [$MONTH$/$DAY$/$YEAR$ %USERNAME%]
a::///:
//////////////////////////////////////////////////////////////////////////

a::sup:
__super::$MethodName$($MethodArgs$);


a:_T():tc:
_T($end$)
a:_T(...)::
_T($selected$)$end$
a::A:
ASSERT($end$)
a::b:
bool
a::class:
class $end$
{
public:
protected:
private:
};

a:class with prompt for name:class:
class $Class_name$
{
public:
	$Class_name$();
	~$Class_name$();
protected:
	$end$
private:
};

a:DEFINE_GUID:guid:
// {$GUID_STRING$} 
DEFINE_GUID($GUID_Name$, 
$GUID_DEFINITION$);

a:do { ... } while ():do:
do 
{
	$selected$
} while ($end$);

a:Doxygen - Class Comment::
/*!
 * \class $classname$
 *
 * \brief $end$
 *
 * \author %USERNAME%
 * \date $MONTHLONGNAME$ $YEAR$
 */

a:Doxygen - Class Comment (Long)::
/*!
 * \class $classname$
 *
 * \ingroup GroupName
 *
 * \brief $end$
 *
 * TODO: long description
 *
 * \note 
 *
 * \author %USERNAME%
 *
 * \version 1.0
 *
 * \date $MONTHLONGNAME$ $YEAR$
 *
 * Contact: user@company.com
 *
 */
a:Doxygen - Header Comment::
/*!
 * \file $FILE_BASE$.$FILE_EXT$
 *
 * \author %USERNAME%
 * \date $MONTHLONGNAME$ $YEAR$
 *
 * $end$
 */

a:Doxygen - Header Comment (Long)::
/*!
 * \file $FILE_BASE$.$FILE_EXT$
 * \date $DATE$ $HOUR$:$MINUTE$
 *
 * \author %USERNAME%
 * Contact: user@company.com
 *
 * \brief $end$
 *
 * TODO: long description
 *
 * \note
*/
a::DW:
DWORD
a:dynamic cast, run code on valid cast:dyna:
$New_type$ *$New_pointer$ = dynamic_cast<$New_type$ *>($Cast_this$);
if (NULL != $New_pointer$)
{
	$end$
}

a::fl:
float
a:for () { ... }:for:
for ($end$)
{
	$selected$
}

a:for loop forward:forr:
for (int $Index$ = 0; $Index$ < $Length$ ; $Index$++)
{
	$end$
}

a:for loop reverse:forr:
for (int $Index$ = $Length$ - 1; $Index$ >= 0 ; $Index$--)
{
	$end$
}

a:GUID IMPLEMENT_OLECREATE:guid:
// {$GUID_STRING$} 
IMPLEMENT_OLECREATE($GUID_Class$, $GUID_ExternalName$, 
$GUID_DEFINITION$);

a:GUID string:guid:
"{$GUID_STRING$}"
a:GUID struct instance:guid:
// {$GUID_STRING$} 
static const GUID $GUID_InstanceName$ = 
{ $GUID_STRUCT$ };

a::HA:
HANDLE
a::HI:
HINSTANCE
a::HR:
HRESULT
a::H:
HWND
a:IDL uuid:uuid:
uuid($GUID_STRING$)
a:if () { ... }:if:
if ($end$)
{
	$selected$
}

a:if () { ... } else { }:if:
if ($end$)
{
	$selected$
} 
else
{
}

a:if () { } else { ... }::
if ($end$)
{
} 
else
{
	$selected$
}

a::ll:
long long
a::LP:
LPARAM
a::LPB:
LPBYTE
a::LPC:
LPCTSTR
a::LPT:
LPTSTR
a::LR:
LRESULT
a:NULL:N:
NULL
a:nullptr:n:
nullptr
a::r:
return
a:return false;:rf:
return false;
a:return true;:rt:
return true;
readme:
Tip: use Create Implementation on "instance" after inserting the snippet.

a:Singleton Class::
class $classname$
{
public:
	~$classname$() { instance = nullptr; }

	static $classname$* Get() 
	{
		if (instance == nullptr)
			instance = new $classname$;
		return instance;
	}
private:
	static $classname$* instance;
};
a::struct:
struct $end$ 
{
};

a::switch:
switch ($end$)
{
	$selected$
}

a::switch:
switch ($end$)
{
case :
	break;
}

a::TC:
TCHAR
a:TRY { ... } CATCH {}:TRY:
TRY 
{
	$selected$
}
CATCH (CMemoryException, e)
{
	$end$
}
END_CATCH

a:try { ... } catch {} catch {} catch {}:try:
try
{
	$selected$
}
catch (CMemoryException* e)
{
	$end$
}
catch (CFileException* e)
{
}
catch (CException* e)
{
}

a::U:
UINT
a::UL:
ULONG
a::ui:
unsigned int
a::ul:
unsigned long
a::usi:
using namespace $end$;

a:while () { ... }:while:
while ($end$)
{
	$selected$
}

a::W:
WORD
a::WP:
WPARAM
