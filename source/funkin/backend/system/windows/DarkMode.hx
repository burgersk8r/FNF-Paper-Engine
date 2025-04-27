package funkin.backend.system.windows;

#if DARK_MODE_WINDOW
@:buildXml('
	<target id="haxe">
		<lib name="dwmapi.lib" if="windows" />
		<lib name="shell32.lib" if="windows" />
		<lib name="gdi32.lib" if="windows" />
		<lib name="ole32.lib" if="windows" />
		<lib name="uxtheme.lib" if="windows" />
	</target>
')

@:cppFileCode('
#include "mmdeviceapi.h"
#include "combaseapi.h"
#include <iostream>
#include <Windows.h>
#include <cstdio>
#include <tchar.h>
#include <dwmapi.h>
#include <winuser.h> 
#include <Shlobj.h>
#include <wingdi.h>
#include <shellapi.h>
#include <uxtheme.h>
')

class DarkMode
{
	@:functionCode('
		int darkMode = enable ? 1 : 0;
		HWND window = FindWindowA(NULL, title.c_str());
		// Look for child windows if top level aint found
		if (window == NULL) window = FindWindowExA(GetActiveWindow(), NULL, NULL, title.c_str());
		if (window != NULL && S_OK != DwmSetWindowAttribute(window, 19, &darkMode, sizeof(darkMode))) {
			DwmSetWindowAttribute(window, 20, &darkMode, sizeof(darkMode));
		}
	')
 
	public static function setDarkMode(title:String, enable:Bool):Void {}
}
#end