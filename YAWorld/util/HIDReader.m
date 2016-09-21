//
//  HIDReader.m
//
//  Created by Yousry Abdallah on 14.09.11.
//  Copyright 2013 yousry.de. All rights reserved.


#import "YAProbability.h"
#import "YALog.h"
#import "YARenderLoop.h"
#import "HIDReader.h"

#define GAMEPAD_OFFSET 100

#define INPUT_DEVICE_DIRECTORY "/dev/input"
#define EVENT_DEVICE_NAME "event"

@implementation HIDReader  

#include <sys/ioctl.h>
#include <dirent.h>
#include <linux/input.h>

static const NSString* TAG = @"HIDReader";

static int linuxToYAOLG[] = {
     0, GAMEPAD_LEFT_X,       
     1, GAMEPAD_LEFT_Y,       
     3,  GAMEPAD_RIGHT_X,      
     4,  GAMEPAD_RIGHT_Y,      
     304, GAMEPAD_BUTTON_OK,    
     305, GAMEPAD_BUTTON_CANCEL,
     307, GAMEPAD_BUTTON_A,     
     308, GAMEPAD_BUTTON_B,     
     314, GAMEPAD_BUTTON_BACK,  
     315, GAMEPAD_BUTTON_START, 
     310, GAMEPAD_BUTTON_LB,    
     311, GAMEPAD_BUTTON_RB,    
     2, GAMEPAD_BUTTON_LT,    
     5, GAMEPAD_BUTTON_RT,    
     317, GAMEPAD_BUTTON_LEFT,  
     318, GAMEPAD_BUTTON_RIGHT
};

- (id) initWithWorld: (YARenderLoop*) RL
{
    self = [super init];
    
    if(self) {
    	[YALog debug:TAG message:@"initWithWorld"];
        renderLoop = RL;
        _lastCommands = [[NSMutableDictionary alloc] init];
        [self setupGamepad];
    }
    
    return self;
}


static int is_event_device(const struct dirent *dir) {
    return strncmp(EVENT_DEVICE_NAME, dir->d_name, 5) == 0;
}

-(void) readAllDevices
{
    [YALog debug:TAG message:@"readAllDevices"];

    struct dirent **deviceNames;
    int deviceNumber = scandir(INPUT_DEVICE_DIRECTORY, &deviceNames, is_event_device, alphasort);

    for (int i = 0; i < deviceNumber; i++)
    {
        char fname[64];
        int fd = -1;
        char name[256] = "UNKNOWN";

        snprintf(fname, sizeof(fname),
           "%s/%s", INPUT_DEVICE_DIRECTORY, deviceNames[i]->d_name);
        fd = open(fname, O_RDONLY);
        if (fd < 0)
            continue;
        ioctl(fd, EVIOCGNAME(sizeof(name)), name);

        [YALog debug:TAG message:[NSString stringWithFormat:@"New device detected: %s", name]];
        NSString* deviceFile = [NSString stringWithFormat:@"%s", fname];

        if(_devices == nil)
            _devices = [NSArray arrayWithObject:deviceFile];
        else
            _devices = [_devices arrayByAddingObject:deviceFile];

        // NSLog(@"I know now %lu devices.", _devices.count);

        close(fd);
        free(deviceNames[i]);
    }

    [YALog debug:TAG message:@"leaving readAllDevices"];

}

int calcMessageValue(int deviceId, int inputVal, bool asBool) 
{
    int iValue = 0;

    if(asBool) {
        iValue = inputVal;
    } else {
        const float sign = inputVal < 0 ? -1 : 1;
        double dValue = (float)(abs(inputVal)) / 32768.0f;
        dValue = [YAProbability sinPowProb: dValue];
        dValue = dValue * sign * 0.5 + 0.5;
        iValue = (int) (dValue * 255.0);
    }

    const int message = ((int)(deviceId) << 16) + iValue;
    return message;
}


-(void) dispatchDispatch: (int) theDevice deviceFile: (NSString*) deviceFile
{
    [YALog debug:TAG message:[NSString stringWithFormat:@"DISPATCH-DISPATCH: %d", theDevice]];
    __block int deviceId = theDevice;

        timer[deviceId - GAMEPAD_OFFSET] = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, q_default); 

        dispatch_time_t now = dispatch_walltime(DISPATCH_TIME_NOW, 0);
        dispatch_source_set_timer(timer[deviceId - GAMEPAD_OFFSET], now, NSEC_PER_SEC / 60, 5000ull);

        __block int fileDescriptor =  open([deviceFile UTF8String], O_RDONLY);
        if(fileDescriptor < 0) {
            // NSLog(@"Could not open device file.");
            return;
        }

        int rc = ioctl(fileDescriptor, EVIOCGRAB, (void*)1);
        if (!rc)
            ioctl(fileDescriptor, EVIOCGRAB, (void*)0);

        dispatch_source_set_event_handler(timer[deviceId - GAMEPAD_OFFSET], ^{

            const int eventNum = 64;
            struct input_event ev[eventNum];
            int eventStorage[eventNum];
            for(int i = 0; i < eventNum; i++) {
                eventStorage[i] = 50000;
            }

            int rd = read(fileDescriptor, ev, sizeof(struct input_event) * eventNum);
            if (rd < (int) sizeof(struct input_event)) 
                return;

            const int actualEvents = rd / sizeof(struct input_event);

            for (int i = 0; i < actualEvents; i++) {
                if (ev[i].type != EV_SYN) {
                    for(int j = 0; j < 32; j += 2) {
                        if (linuxToYAOLG[j] == ev[i].code) 
                            eventStorage[linuxToYAOLG[j+1]] = ev[i].value;
                    }
                } else if(ev[i].code == SYN_REPORT) {
                    for(int i = 0; i < eventNum; i++) {
                        const int value = eventStorage[i];
                        if(value != 50000)  {

                            const bool isButton = (i == GAMEPAD_BUTTON_OK || i == GAMEPAD_BUTTON_CANCEL || i == GAMEPAD_BUTTON_A || 
                             i == GAMEPAD_BUTTON_B  || i == GAMEPAD_BUTTON_BACK  || i == GAMEPAD_BUTTON_START || 
                             i == GAMEPAD_BUTTON_LB || i == GAMEPAD_BUTTON_RB || i == GAMEPAD_BUTTON_LEFT || i == GAMEPAD_BUTTON_RIGHT);

                            int message = calcMessageValue(deviceId, value, isButton);
                            [renderLoop startEvent:i message:message];
                        }
                    }
                }
            }
        });
}

-(void) setupGamepad
{
	[YALog debug:TAG message:@"Setup read timer."];
    [self readAllDevices];

    // NSLog(@"Before dispatch");
    q_default = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    // NSLog(@"After dispatch");



    __block int deviceId = GAMEPAD_OFFSET;
    for(NSString* deviceFile in _devices) {
        [self dispatchDispatch:deviceId deviceFile:deviceFile];
        dispatch_resume(timer[deviceId - GAMEPAD_OFFSET]);
        deviceId++;
    }
    
	[YALog debug:TAG message:@"leaving"];

}


-(YARenderLoop*) getRenderLoop
{
	return renderLoop;
}

@end