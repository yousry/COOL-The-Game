#define GLFW_INCLUDE_NONE
#include <GLFW/glfw3.h>

#define GL_GLEXT_PROTOTYPES
#define GLCOREARB_PROTOTYPES
#import <GL/glcorearb.h>

#import <unistd.h>
#import <pwd.h>

#import <Foundation/Foundation.h>

#import "YAPreferences.h"
#import "YAGameStateMachine.h"
#import "YAScene.h"
#import "YASceneDevelop.h"
#import "YARenderLoop.h"



int main (int argc, const char * argv[])
{
	@autoreleasepool {

		NSLog(@"Application Startup");

		NSThread* blub = [[NSThread alloc] init];
		[blub start];
		[blub cancel];


		if([NSThread isMultiThreaded])
			NSLog(@"App is multithreaded");
		else
			NSLog(@"App is not isMultiThreaded");

		YARenderLoop* renderLoop = [[YARenderLoop alloc] init];
		[renderLoop prepareOpenGL];
		[renderLoop setUpMetaWorld];

		// YASceneDevelop* scene = [[YASceneDevelop alloc] initIn: renderLoop];
		// [scene setup];

		YAGameStateMachine* gameStateMachine = [[YAGameStateMachine alloc] initWithWorld: renderLoop];
		[gameStateMachine startState];

		NSLog(@"start loop");
		[renderLoop doLoop];
	}

	return 0;
}
