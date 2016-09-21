// Render Loop for Linux
// (c) 2013 Yousry Abdallah

#define GLFW_INCLUDE_NONE
#include <GLFW/glfw3.h>

#define GL_GLEXT_PROTOTYPES
#define GLCOREARB_PROTOTYPES
#import <GL/glcorearb.h>

#import <time.h>

#import "YAPreferences.h"
#import "YAVector2f.h"
#import "YAOpenAL.h"
#import "HIDReader.h"
#import "YAInterpolationAnimator.h"
#import "YABlockAnimator.h"
#import "YATextModel.h"
#import "YA3DFileFormat.h"
#import "YATextureArray.h"
#import "YAGridModel.h"
#import "YATriangleModel.h"
#import "YAMaterial.h"
#import "YAMatrix3f.h"
#import "YAShapeshifter.h"
#import "YAMatrix4f.h"
#import "YAPerspectiveProjectionInfo.h"
#import "YATransformator.h"
#import "YABasicAnimator.h"
#import "NSMutableArray+QueueAdditions.h"
#import "YAModel.h"
#import "YAImpersonator.h"
#import "YAText2D.h"
#import "YATexture.h"
#import "YAPickMap.h"
#import "YAShadowMap.h"
#import "YAAvatar.h"
#import "YASkyMap.h"
#import "YATransformator.h"
#import "YAShader.h"
#import "YAFogLight.h"
#import "YASpotLight.h"
#import "YAPhongLight.h"
#import "YAGouradLight.h"
#import "YASpotLight.h"
#import "YAVector4f.h"
#import "YALog.h"
#import "YAIngredient.h"
#import "YAImpersonator.h"
#import  "YAVector3f.h"

#import "YARenderLoop.h"

@implementation YARenderLoop : NSObject

static const NSString *TAG = @"RenderLoop";
static YATransformator* transformerBridge;
static void glfw_error_callback(int, const char*);
static void cursor_position_callback(GLFWwindow*, double, double);
static void window_size_callback(GLFWwindow*, int, int);
static void mouse_button_callback(GLFWwindow*, int, int, int);
static void key_callback(GLFWwindow*, int, int, int, int);


static YAVector2f* lastPointBridge;
static volatile NSMutableArray* eventQueueBridge;
static volatile YARenderLoop* masterBridge;

- (id) init
{
	self = [super init];

	if(self) {
		NSLog(@"Initialize Render Loop");

        prefs = [[YAPreferences alloc] init];
        _gammaCorrection = prefs.gamma;

        // The Bridge for the glfw resize callback
        _transformer = [[YATransformator alloc] init];
        transformerBridge = _transformer;
        masterBridge = self;

        disableLoopContext = false;

		[YALog isGLStateOk:TAG message:@"init renderloop state"];

		if(!glfwInit()) {
            NSLog(@"Could not initialze GLFW.");
            return nil;
        }

        glfwSetErrorCallback(glfw_error_callback);

        glfwWindowHint( GLFW_CLIENT_API, GLFW_OPENGL_API );
		glfwWindowHint( GLFW_CONTEXT_VERSION_MAJOR, 3 );
		glfwWindowHint( GLFW_CONTEXT_VERSION_MINOR , 2 );

		glfwWindowHint( GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE );
        glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GL_FALSE);

        glfwWindowHint( GLFW_RED_BITS,      8 );
        glfwWindowHint( GLFW_GREEN_BITS ,   8 );
        glfwWindowHint( GLFW_BLUE_BITS ,    8 );
        glfwWindowHint( GLFW_ALPHA_BITS  ,  8 );
        glfwWindowHint( GLFW_DEPTH_BITS   , 24 );

        glfwWindowHint( GLFW_SAMPLES   , prefs.multispamplingPixel );

        sceneWindow = glfwCreateWindow(1280, 720, "COOL  (c) 2011-2016 Yousry Abdallah (www.yousry.de) Free Edition", NULL, NULL);
	[_transformer setDisplaySize:1280 height:720];

        if(!sceneWindow) {
            NSLog(@"Could not open window.");
            NSLog(@"Please make sure you have the correct driver with OpenGL 3.2 (or later) installed for your graphics card.");
            glfwTerminate();
            return nil;
        }

		[YALog isGLStateOk:TAG message:@"glfw init"];

        glfwMakeContextCurrent(sceneWindow);

        [YALog isGLStateOk:TAG message:@"Glew Init (Catch Enum Error)"];
    }


	return self;
}

- (void) doLoop
{

	while(sceneWindow && !glfwWindowShouldClose(sceneWindow))
	{   now = glfwGetTime();
        [self renderScene];
        glfwPollEvents();
	}

    if(sceneWindow) {
        NSLog(@"Close Window");
        glfwDestroyWindow(sceneWindow);
    }

	NSLog(@"Terminating");
	glfwTerminate();
    [_openAL cleanup];
    exit(EXIT_SUCCESS);
}


- (void) renderScene
{

        if(disableLoopContext == true) {
            glfwMakeContextCurrent(NULL);
            disableLoopContext = false;
            return;
        }

        if(!_drawScene || ![displayLock tryLock])
            return;

        glfwMakeContextCurrent(sceneWindow);
        [YALog isGLStateOk:TAG message:@"Entry OpenGL Bug"];

        [_avatar nextStep];
        __block NSArray* allImps = [impersonators allValues];
        __block NSArray* sortedImpsCache = [allImps sortedArrayUsingComparator:sortOrder];

        int message = 0;
        NSNumber* event = nil;
        bool updateForTime = false;

        glClear( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

        if (skyMap != nil) {
            [self drawSkyMap];
        }


        while(!eventQueue.isEmpty || !updateForTime) {

            id obj = [eventQueue dequeue];
            if( [obj isKindOfClass:[NSNumber class]])
                event = obj;

            if( [obj isKindOfClass:[NSDictionary class]]) {
                event = [(NSDictionary*)obj objectForKey:@"EVENT"];
                message = [[(NSDictionary*)obj objectForKey:@"MESSAGE"] intValue];
            }

            if(_activeAnimation) {

                if ([event intValue] == MOUSE_DOWN) {
                    // Pick mouse position
                    [pickMap setupWrite];

                    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
                    glViewport(0, 0, [pickMap width], [pickMap height]);
                    glCullFace(GL_BACK);

                    lastDrawnModel = nil;
                    for(YAImpersonator *imp in sortedImpsCache)
                        if([imp visible] && [imp clickable])
                            [self materializePick: imp];

                    float xP = lastPoint.x / (float)[_transformer renderWidth];
                    float yP = lastPoint.y / (float)[_transformer renderHeight];
                    int xPick = pickMap.width * xP;
                    int yPick = pickMap.height - pickMap.height * yP;

                    int objectId = [pickMap getImpAtX:xPick Y:yPick];
                    message = objectId;
                }

                if(realtimeAnimators.count != 0) {
                    for(YABasicAnimator* animator in realtimeAnimators) {
                        [animator setStarttime:now];
                    }
                    [animators addObjectsFromArray:realtimeAnimators];
                    realtimeAnimators = [[NSMutableArray alloc] initWithCapacity:2];
                }


                NSMutableArray* removeAnims = nil;
                for(YABasicAnimator* animator in animators)  {
                    [animator setEvent:event];
                    [animator setMessage:message];

                    if(!updateForTime || animator.asyncProcessing )
                        [animator update:now];

                    if([animator deleteme]) {
                        if (removeAnims == nil)
                            removeAnims =  [NSMutableArray array];
                        [removeAnims addObject:animator];
                    }
                }
                [animators removeObjectsInArray:removeAnims];

            }

            updateForTime = true;
        }

        [shadowMap setupWrite];

                [_shadowAvatar setPosition: [[YAVector3f alloc] initVals:[[spotlight position] x] :[[spotlight position] y] :[[spotlight position] z]]];
        [_shadowAvatar setFocus:[spotlight direction]];

        [[_shadowTransformer projectionInfo] setFieldOfView:spotlight.cutoff*2];
        [_shadowTransformer recalcCam];

        glClear(GL_DEPTH_BUFFER_BIT);
        glViewport(0, 0, [_shadowTransformer renderWidth], [_shadowTransformer renderHeight]);

        glCullFace(GL_FRONT);

        lastDrawnModel = nil;
        for(YAImpersonator *imp in sortedImpsCache)
            if([imp visible] && [imp shadowCaster])
                [self materializeDepth: imp];

        glBindFramebuffer(GL_FRAMEBUFFER, 0);
        glCullFace(GL_BACK);
        glDrawBuffer(GL_BACK);
        glPolygonOffset(1.1, 4.0);

        glViewport(0, 0, _transformer.renderWidth, _transformer.renderHeight);

        lastDrawnModel = nil;
        for(YAImpersonator *imp in sortedImpsCache)
            if([imp visible])
                [self materialize: imp];


        glfwSwapBuffers(sceneWindow);

        [displayLock unlock];
}

- (void) prepareOpenGL
{
    [YALog debug:TAG message:@"prepareOpenGL"];
    [YALog isGLStateOk:TAG message:@"prepareOpenGL unhandled Bug in GL Context"];

    if(prefs.vSync)
    	glfwSwapInterval(1);
    else
        glfwSwapInterval(0);

	glfwSetWindowSizeCallback(sceneWindow, window_size_callback);
    glfwSetCursorPosCallback(sceneWindow, cursor_position_callback);
    glfwSetMouseButtonCallback(sceneWindow, mouse_button_callback);
    glfwSetKeyCallback(sceneWindow, key_callback);

    if(prefs.isMultisampling)
        glEnable(GL_MULTISAMPLE);
    else
        glDisable(GL_MULTISAMPLE);

    clearColor = [[YAVector4f alloc] initVals:0.2 :0.4 :0.5 :1.0];
    glClearColor(clearColor.x, clearColor.y, clearColor.z, clearColor.w );
    glFrontFace(GL_CW);
    glEnable(GL_CULL_FACE);

    glCullFace(GL_BACK);
    glEnable(GL_DEPTH_TEST);

    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glEnable(GL_BLEND);

    glEnable(GL_LINE_SMOOTH);
    glHint(GL_LINE_SMOOTH_HINT, GL_NICEST);

    glfwMakeContextCurrent(sceneWindow);

    spotlight = [[YASpotLight alloc] init];
    defaultLight =[[YAGouradLight alloc] init];

    _lights = [NSArray arrayWithObjects:
    	[[YALight alloc] init],
    	[[YAPhongLight alloc] init],
    	defaultLight,
    	spotlight,
    	[[YAFogLight alloc] init],
    	nil];

        _shaders = [NSDictionary dictionaryWithObjectsAndKeys:
               [[YAShader alloc] initResource:@"gourad_reflect" light:@"YAGouradLight"] , @"gourad_reflect",
               [[YAShader alloc] initResource:@"perlin_thrust" light:@"YAGouradLight"] , @"perlin_thrust",
               [[YAShader alloc] initResource:@"heightmap"  light:@"YAGouradLight"] , @"heightmap",
               [[YAShader alloc] initResource:@"shadowmap_heightmap"  light:@"YAGouradLight"] , @"shadowmap_heightmap",
               [[YAShader alloc] initResource:@"gourad" light:@"YAGouradLight"] , @"gourad",
               [[YAShader alloc] initResource:@"stripesGourard" light:@"YAGouradLight"] , @"stripesGourard",
               [[YAShader alloc] initResource:@"gourad_spotlight" light:@"YASpotLight"] , @"gourad_spotlight",
               [[YAShader alloc] initResource:@"ads_texture" light:@"YAGouradLight"] , @"ads_texture",
               [[YAShader alloc] initResource:@"billboard_3d" light:@"YAGouradLight"] , @"billboard_3d",
               [[YAShader alloc] initResource:@"logo" light:@"YAGouradLight"] , @"logo",
               [[YAShader alloc] initResource:@"ads_texture_normal" light:@"YAGouradLight"] , @"ads_texture_normal",
               [[YAShader alloc] initResource:@"ads_texture_spotlight" light:@"YASpotLight"] , @"ads_texture_spotlight",
               [[YAShader alloc] initResource:@"ads_texture_normal_spotlight" light:@"YASpotLight"] , @"ads_texture_normal_spotlight",
               [[YAShader alloc] initResource:@"skymap" light:@"YALight"] , @"skymap",
               [[YAShader alloc] initResource:@"shadowmap" light:@"YALight"] , @"shadowmap",
               [[YAShader alloc] initResource:@"shadowmap_bones" light:@"YALight"] , @"shadowmap_bones",
               [[YAShader alloc] initResource:@"text2d" light:@"YALight"] , @"text2d",
               [[YAShader alloc] initResource:@"ads_texture_bones" light:@"YAGouradLight"] , @"ads_texture_bones",
               [[YAShader alloc] initResource:@"pick" light:@"YALight"] , @"pick",
               [[YAShader alloc] initResource:@"billboard"  light:@"YAGouradLight"] , @"billboard",
               nil];
}

- (void)setUpMetaWorld
{
    [YALog debug:TAG message:@"setUpMetaWorld"];

    displayLock = [NSRecursiveLock new];
    _activeAnimation = false;
    _drawScene = false;
    lastPoint = [[YAVector2f alloc] init];
    lastPointBridge = lastPoint;
    _traceMouseMove = false;

    textures = [[NSMutableDictionary alloc] initWithCapacity: 10];
    _ingredients = [[NSMutableDictionary alloc] initWithCapacity: 10];
    _models = [[NSMutableDictionary alloc] initWithCapacity: 10];
    impersonators = [[NSMutableDictionary alloc] initWithCapacity: 50];

    animators = [[NSMutableArray alloc] initWithCapacity:10];
    realtimeAnimators = [[NSMutableArray alloc] initWithCapacity:2];
    shapeshifters = [[NSMutableDictionary alloc] initWithCapacity:10];


    _avatar = [[YAAvatar alloc] initWithTransformator: _transformer];
    skyMap = nil;


    shadowMap = [[YAShadowMap alloc] initResolution:prefs.shadowBufferRes];
    pickMap = [[YAPickMap alloc] init];

    _shadowTransformer = [[YATransformator alloc] init];
    [_shadowTransformer setDisplaySize:[shadowMap width] height:[shadowMap height]];
    [_shadowTransformer recalcCam];
    _shadowAvatar = [[YAAvatar alloc] initWithTransformator: _shadowTransformer];

    uniqueId = 0;
    fontTexture = [self addTexture:@"font/Knewave-Regular.ttf_sdf.png"];

    [YAText2D setupText:fontTexture];

    eventQueue = [[NSMutableArray alloc] init];
    [eventQueue setUp];
    eventQueueBridge = eventQueue;

    hidReader = [[HIDReader alloc] initWithWorld:self];

    // define sort algorithms
    [self setupSortAlgorithms];
}

- (NSString *)description
{
	return @"None";
}



- (void) createModelFromTriangles: (NSData*)triangleData name: (NSString*) modelName ingredient: (YAIngredient*) ingredient
{
    [YALog debug:TAG message:@"createModelFromTriangles"];
    NSAssert(_models != nil, @"Models not initialized.");

    YATriangleModel* model = [_models objectForKey: modelName];

    if(model != nil) {
        [YALog debug:TAG message:@"Model already exists."];
        return;
    }

    YATexture* texture = nil;

    NSString* textureName = [ingredient texture];

    if (textureName != nil) {
        texture = [self addTexture:textureName];
    }

    if(texture == nil)
        model = [[YATriangleModel alloc] initTriangles:triangleData
                                                shader: [_shaders objectForKey:@"gourad"] texture:nil];
    else {
        if ([ingredient flavour] == Terrain)
            model = [[YATriangleModel alloc] initTriangles:triangleData shader: [_shaders objectForKey:@"terrain"] texture:texture];
        else
            model = [[YATriangleModel alloc] initTriangles:triangleData shader: [_shaders objectForKey:@"ads_texture"] texture:texture];
    }

    [_models setObject:model forKey:modelName];
}

- (void) createModelFromGrid: (NSData*)triangleData name: (NSString*) modelName ingredient: (YAIngredient*) ingredient
{
    [YALog debug:TAG message:@"createModelFromGrid"];
    NSAssert(_models != nil, @"Models not initialized.");

    YAGridModel* model = [_models objectForKey: modelName];

    if(model != nil) {
        [YALog debug:TAG message:@"Model already exists."];
        return;
    }

    // Texture Array for different landforms
    NSArray* textureFileNames = [NSArray arrayWithObjects:@"terrainWater.png", @"terrainGrass.png", @"terrainStone.png", @"terrainSnow.png", nil];
//    NSArray* textureFileNames = [NSArray arrayWithObjects:@"terrainWaterYT.png", @"terrainGrassYT.png", @"terrainStoneYT.png", @"terrainSnowYT.png", nil];
//    NSArray* textureFileNames = [NSArray arrayWithObjects:@"dirtHigh.png", @"grassHigh.png", @"rockHigh.png", @"snowHigh.png", nil];

    YATextureArray* terrainTA = [self addTextureArray:@"terra" withTextures:textureFileNames];

    NSString* textureName = [ingredient texture];
    YATexture* texture = [textures objectForKey:textureName];

    if(texture == nil) {
        [YALog debug:TAG message:@"No texture for model found."];
        model = [[YAGridModel alloc] initTriangles:triangleData
                                            shader: [_shaders objectForKey:@"heightmap"] textures:nil normal:nil];
    } else {
        [YALog debug:TAG message:@"Assigning texture to model."];
        if ([ingredient flavour] == Terrain)
            model = [[YAGridModel alloc] initTriangles:triangleData shader: [_shaders objectForKey:@"heightmap"] textures:terrainTA normal:texture];
        else
            model = [[YAGridModel alloc] initTriangles:triangleData shader: [_shaders objectForKey:@"heightmap"] textures:terrainTA normal:texture];
    }

    [_models setObject:model forKey:modelName];
}


- (void) updateModel: (NSString*) modelName withTriangles: (NSData*) triangleData
{
    YATriangleModel* model = [_models objectForKey: modelName];
    [model updateVBO:triangleData];
}

- (void) addModelWithShader: (NSString*) modelName shader: (NSString*) shaderId ingredient: (YAIngredient*) ingredient
{
    [YALog debug:TAG message:@"addModel"];
    NSAssert(_models != nil, @"Models not initialized.");
    YAModel* model = [_models objectForKey: modelName];

    if(model != nil) {
        [YALog debug:TAG message:@"Model already exists."];
        return;
    }


    YA3DFileFormat* modelFile = [[YA3DFileFormat alloc] initWithResource:modelName];
    NSAssert(modelFile != nil, @"Could not load model file.");

    [modelFile load];
    [modelFile setup];

    NSString* textureName = [modelFile textureName];
    NSString* modelFormat = [modelFile modelFormat];

    if([modelFormat isEqualToString:@"vtnbI"]) {

        YATexture* texture = nil;
        if(ingredient.autoMipMap)
            texture = [self addMipMap:[modelFile textureName]];
        else
            texture = [self addTexture:[modelFile textureName]];

        YATexture* normal = [self addTexture:[modelFile normalName]];

        model = [[YAModel alloc] initVTNBIWithShader: texture
                                              normal: normal
                                        vertexBuffer: modelFile.vboData
                                         indexBuffer: modelFile.iboData
                                              shader: [_shaders objectForKey:shaderId]];
    } else if(textureName == nil || [textureName isEqualToString:@"UNSET"]) {
        model = [[YAModel alloc] initVCNIWithShader: modelFile.vboData
                                        indexBuffer: modelFile.iboData
                                             shader: [_shaders objectForKey:shaderId]];
    } else {
        YATexture* texture = nil;
        if(ingredient.autoMipMap)
            texture = [self addMipMap:[modelFile textureName]];
        else
            texture = [self addTexture:[modelFile textureName]];

        model = [[YAModel alloc] initVTNIWithShader: texture
                                       vertexBuffer: modelFile.vboData
                                        indexBuffer: modelFile.iboData
                                             shader: [_shaders objectForKey:shaderId]];
    }

    [_models setObject:model forKey:modelName];
}

- (void) addModel: (NSString*) modelName ingredient: (YAIngredient*) ingredient
{
    [YALog debug:TAG message:@"addModel"];
    NSAssert(_models, @"Models not initialized.");

    glfwMakeContextCurrent(sceneWindow);

    YAModel* model = [_models objectForKey: modelName];

    if(model != nil) {
        [YALog debug:TAG message:@"Model already exists."];
        return;
    }

    YAText2D* text = nil;
    YA3DFileFormat* modelFile = nil;
    YATexture* texture = nil;
    NSString* textureName = nil;

    switch ([ingredient flavour]) {
        case Text:
            [YALog debug:TAG message:[NSString stringWithFormat:@"create text: %@", [ingredient text] ]];
            text = [[YAText2D alloc] initText:[ingredient text]];
            [text vbos];
            [displayLock lock];
            glfwMakeContextCurrent(sceneWindow);
            model = [[YATextModel alloc] initTrianglesWithShader:fontTexture vertexBuffer:[text vbos] shader:[_shaders objectForKey:@"text2d"] ];
            [displayLock unlock];
            [_models setObject:model forKey:modelName];
            break;
        case Model3D:
            modelFile = [[YA3DFileFormat alloc] initWithResource:modelName];
            NSAssert(modelFile != nil, @"Could not load model file.");
            [modelFile load];
            [modelFile setup];
            textureName = [modelFile textureName];
            if(textureName == nil || [textureName isEqualToString:@"UNSET"]) {
                [displayLock lock];
                glfwMakeContextCurrent(sceneWindow);
                model = [[YAModel alloc] initVCNIWithShader: modelFile.vboData
                                                indexBuffer: modelFile.iboData
                                                     shader: [_shaders objectForKey:@"gourad"]];
                [displayLock unlock];
            } else {
                texture = [self addTexture:[modelFile textureName]];
                [displayLock lock];
                glfwMakeContextCurrent(sceneWindow);
                model = [[YAModel alloc] initVTNIWithShader: texture
                                               vertexBuffer: modelFile.vboData
                                                indexBuffer: modelFile.iboData
                                                     shader: [_shaders objectForKey:@"ads_texture"]];
                [displayLock unlock];
            }
            [_models setObject:model forKey:modelName];
            break;
        default:
            [YALog debug:TAG message:@"Unknown Model Flavour"];
            break;
    }
}

- (YATexture*) addTexture: (NSString*)textureName
{
    [YALog debug:TAG message:@"addTexture"];
    NSAssert(textures != nil, @"Textures not initialized.");

    YATexture* texture = nil;

    if(textureName == nil)
        return nil;

    texture = [textures objectForKey: textureName];
    if (texture == nil) {
        texture = [[YATexture alloc] initWithFilename:textureName];
        if([texture load]) {
            [textures setObject:texture forKey:textureName];
            [YALog debug:TAG message:@"New Texture created."];
        } else {
            [YALog debug:TAG message:@"Could not load texture."];
        }

    } else {
        [YALog debug:TAG message:@"Texture already exists."];
    }

    return texture;
}

- (void) setupSortAlgorithms
{

    __weak YARenderLoop* wWorld = self;
    __weak YAAvatar* wAvatar = _avatar;

    sortIdentity = (^NSComparisonResult(id obj1, id obj2) {
        int v1 = [(YAImpersonator*)obj1 identifier];
        int v2 = [(YAImpersonator*)obj2 identifier];
        if (v1 < v2)
            return NSOrderedAscending;
        else if (v1 > v2)
            return NSOrderedDescending;
        else
            return NSOrderedSame;

    });

    sortShader = (^NSComparisonResult(id obj1, id obj2) {

        // TODO: maybe loosen redundancy for shaderId
        YAImpersonator *impA = (YAImpersonator*) obj1;
        const NSString* ingredientNameA =[impA ingredientName];
        YAIngredient* ingredientA = [wWorld.ingredients objectForKey: ingredientNameA];
        const NSString* modelNameA = [ingredientA model];
        YAModel* modelA = [wWorld.models objectForKey:modelNameA];
        YAShader* shaderA = [wWorld.shaders objectForKey: [modelA shaderId]];
        NSString* v1s = shaderA.name;

        // TODO: create shader priority
        if([v1s isEqualToString:@"logo"])
            v1s = @"zlogo";

        YAImpersonator *impB = (YAImpersonator*) obj2;
        const NSString* ingredientNameB =[impB ingredientName];
        YAIngredient* ingredientB = [wWorld.ingredients objectForKey: ingredientNameB];
        const NSString* modelNameB = [ingredientB model];
        YAModel* modelB = [wWorld.models objectForKey:modelNameB];
        YAShader* shaderB = [wWorld.shaders objectForKey: [modelB shaderId]];
        NSString* v2s = shaderB.name;

        if([v2s isEqualToString:@"logo"])
            v2s = @"zlogo";

        if (v1s < v2s)
            return NSOrderedAscending;
        else if (v1s > v2s)
            return NSOrderedDescending;
        else
            return NSOrderedSame;

    });

    sortDepth = (^NSComparisonResult(id obj1, id obj2) {

        float distA = [((YAImpersonator*)obj1).translation distanceTo:wAvatar.position];
        float distB = [((YAImpersonator*)obj2).translation distanceTo:wAvatar.position];

        if (distA < distB)
            return NSOrderedAscending;
        else if (distA > distB)
            return NSOrderedDescending;
        else
            return NSOrderedSame;

    });

    sortModel = (^NSComparisonResult(id obj1, id obj2) {

        NSString* modelAName = ((YAImpersonator*)obj1).ingredientName;
        NSString* modelBName = ((YAImpersonator*)obj2).ingredientName;

        if (modelAName < modelBName)
            return NSOrderedAscending;
        else if (modelAName > modelBName)
            return NSOrderedDescending;
        else
            return NSOrderedSame;

    });


    // active algorithm
    sortOrder = sortIdentity;
}

- (void) materializePick: (YAImpersonator *) impersonator
{
    const NSString* ingredientName = [impersonator ingredientName];
    YAIngredient* ingredient = [_ingredients objectForKey: ingredientName];
    const NSString* modelName = [ingredient model];
    YAModel* model = [_models objectForKey:modelName];

    const bool successiveDraw = model == lastDrawnModel ? YES : NO;
    lastDrawnModel = model;

    YAShader* shader = [_shaders objectForKey:@"pick"];
    [shader activate];

    if(impersonator.useQuaternionRotation)
        [_transformer setRotateQuatMatrix: [impersonator quatMatrix]];
    else {
        YAVector3f* rotate = [_transformer rotate];
        [rotate setVector:[impersonator rotation]];
        [_transformer setRotateQuatMatrix: nil];
    }

    YAVector3f* scale = [_transformer scale];
    [scale setVector:[impersonator size]];

    YAVector3f* translate = [_transformer translate];
    [translate setVector:[impersonator translation]];

    const YAMatrix4f* world = [_transformer transform];

    GLint location = shader.locMVP;
    if (location != -1)
        glUniformMatrix4fv(location, 1, GL_TRUE, &(world->m[0][0]));

    location = shader.locGObjectIndex;
    if (location != -1)
        glUniform1ui(location, [impersonator identifier]);

    location = shader.locGDrawIndex;
    if (location != -1)
        glUniform1ui(location, 0);

    location = shader.locNow;
    if(location != -1 && !successiveDraw)
        glUniform1f(location, now);

    [YALog isGLStateOk:TAG message:@"materialize pick FAILED"];
    [model draw: shader SuccessiveDraw:successiveDraw];
}

- (void) materializeDepth: (YAImpersonator*) impersonator
{
    const NSString* ingredientName = [impersonator ingredientName];
    YAIngredient* ingredient = [_ingredients objectForKey: ingredientName];
    const NSString* modelName = [ingredient model];
    YAModel* model = [_models objectForKey:modelName];

    const bool successiveDraw = model == lastDrawnModel ? YES : NO;
    lastDrawnModel = model;

    // animated shadows
    YAShapeshifter *shapeshifter = [impersonator shapeshifter];
    YAShader* shader = [_shaders objectForKey:@"shadowmap"];

    // as
    if(shapeshifter != nil)
        shader = [_shaders objectForKey:@"shadowmap_bones"];
    else if (ingredient.flavour == Terrain)
       shader = [_shaders objectForKey:@"shadowmap_heightmap"];

    [shader activate];

    if(impersonator.useQuaternionRotation) {
       [_shadowTransformer setRotateQuatMatrix: [impersonator quatMatrix]];
    } else {
        YAVector3f* rotate = [_shadowTransformer rotate];
        [rotate setVector:[impersonator rotation]];
        [_shadowTransformer setRotateQuatMatrix: nil];
    }

    YAVector3f* scale = [_shadowTransformer scale];
    [scale setVector:[impersonator size]];

    YAVector3f* translate = [_shadowTransformer translate];
    [translate setVector:[impersonator translation]];

    const YAMatrix4f* world = _shadowTransformer.transform;

    GLint location = shader.locMVP;
    if (location != -1)
        glUniformMatrix4fv(location, 1, GL_TRUE, &(world->m[0][0]));

    location = shader.locNormalMapFactor;
    if (location != -1) {
        glUniform1f(location, [impersonator normalMapFactor]);
    }

    // as
    if (shapeshifter != nil ) {
        location = shader.locShapeShifter;
        if(location != -1) {
            [shapeshifter bind:GL_TEXTURE3];
            [impersonator updateShapeshifter];
            glUniform1i(location, 3);
        }
    }

    location = shader.locNow;
    if(location != -1 && !successiveDraw)
        glUniform1f(location, now);

    [YALog isGLStateOk:TAG message:@"materialize depth FAILED"];
    [model draw: shader SuccessiveDraw:successiveDraw];
}

- (void) materialize: (YAImpersonator*) impersonator
{
    const NSString* ingredientName = [impersonator ingredientName];
    YAIngredient* ingredient = [_ingredients objectForKey: ingredientName];
    const NSString* modelName = [ingredient model];
    YAModel* model = [_models objectForKey:modelName];

    const bool successiveDraw = (model == lastDrawnModel) ? YES : NO;
    lastDrawnModel = model;

    YAShader* shader = [_shaders objectForKey: [model shaderId]];
    [shader activate];

    YAMaterial* material = [impersonator material];

    if(impersonator.useQuaternionRotation)
        [_transformer setRotateQuatMatrix: [impersonator quatMatrix]];
    else {
        YAVector3f* rotate = [_transformer rotate];
        [rotate setVector:[impersonator rotation]];
        [_transformer setRotateQuatMatrix: nil];
    }


    YAVector3f* scale = [_transformer scale];
    [scale setVector:[impersonator size]];


    YAVector3f* translate = [_transformer translate];
    [translate setVector:[impersonator translation]];

    const YAMatrix4f* world = [_transformer transform];

    GLint location = shader.locModel;
    if (location != -1)
        glUniformMatrix4fv(location, 1, GL_TRUE, &([_transformer modelMatrix]->m[0][0]));

    location = shader.locEye;
    if (location != -1 && !successiveDraw) {
        YAVector3f* eye = [_transformer eyePos];
        glUniform3f(location, eye.x, eye.y, eye.z);
    }


    location = shader.locRatio;
    if (location != -1 && !successiveDraw) {
        float cl = (float)_transformer.renderHeight / (float)_transformer.renderWidth;
        glUniform1f(location, cl);
    }


    location = shader.locMVP;
    if (location != -1)
        glUniformMatrix4fv(location, 1, GL_TRUE, &(world->m[0][0]));

    // [model writeClientEye:[_transformer eyePos]];
    // [model writeClientMVP:(YAMatrix4f*)world];
    // [model writeClientModel:(YAMatrix4f*)[_transformer modelMatrix]];

    location = shader.locProjectionMatrix;
    if (location != -1 && !successiveDraw)
        glUniformMatrix4fv(location, 1, GL_TRUE, &([_transformer projectionMatrix]->m[0][0]));

    location = shader.locModelViewMatrix;
    if (location != -1)
        glUniformMatrix4fv(location, 1, GL_TRUE, &([_transformer modelviewMatrix]->m[0][0]));


    location = shader.locNormalMatrix;
    if (location != -1) {
        YAMatrix3f* normalMat = [[YAMatrix3f alloc] init];
        [normalMat extractNormalMatrix:[_transformer modelviewMatrix]];
        glUniformMatrix3fv(location, 1, GL_TRUE, &(normalMat->m[0][0]));
    }

    location = shader.locNormalMapFactor;
    if (location != -1) {
        glUniform1f(location, [impersonator normalMapFactor]);
    }

    const NSString* lightName = [shader requiredLight];
    YALight* light = nil;

    NSEnumerator* lightsEnumerator = [_lights objectEnumerator];

    YALight* lt;
    while((lt = [lightsEnumerator nextObject])) {
        if([[lt name] isEqualToString: (NSString*)lightName]) {
            light = lt;
            break;
        }
    }

    YAShapeshifter *shapeshifter = [impersonator shapeshifter];
    if (shapeshifter != nil ) {
        location = shader.locShapeShifter;
        if(location != -1) {
            [shapeshifter bind:GL_TEXTURE3];
            [impersonator updateShapeshifter];
            glUniform1i(location, 3);
        }
    }

    [YALog isGLStateOk:TAG message:@"materialize FAILED"];

    if(!successiveDraw) {
        [light shine:shader transformator:_transformer];

        if(light != defaultLight)
            [defaultLight shine:shader transformator:_transformer];
    }

    [material setup:shader transformator: _transformer GammaCorrection:_gammaCorrection Model:model];

    if (skyMap !=nil && !successiveDraw)
        [skyMap bind: shader];

    if(!successiveDraw)
        [shadowMap bind: shader];

    location = shader.locShadowMVP;
    if (location != -1) {

        if(impersonator.useQuaternionRotation)
            [_shadowTransformer setRotateQuatMatrix: [impersonator quatMatrix]];
        else {
            YAVector3f* rotate = [_shadowTransformer rotate];
            [rotate setVector:[impersonator rotation]];
            [_shadowTransformer setRotateQuatMatrix: nil];
        }

        scale = [_shadowTransformer scale];
        [scale setVector:[impersonator size]];
        translate = [_shadowTransformer translate];
        [translate setVector:[impersonator translation]];

        const YAMatrix4f* shadowWorld = [[[YAMatrix4f alloc] initShadowBiasTransform] mulMatrix4f: [_shadowTransformer transform]];
        glUniformMatrix4fv(location, 1, GL_TRUE, &(shadowWorld->m[0][0]));
    }


    if (![impersonator backfaceCulling])
        glDisable(GL_CULL_FACE);

    location = shader.locNow;
    if(location != -1 && !successiveDraw)
        glUniform1f(location, now);

    [model draw: shader SuccessiveDraw:successiveDraw];

    if (![impersonator backfaceCulling]) // because it was disabled
        glEnable(GL_CULL_FACE);

}

- (void) resetAnimators
{
        for(YABasicAnimator* animator in animators) {
        [animator setStarttime:now];
    }

}

- (void) changeImpsSortOrder: (sort_order) sort
{
    switch (sort) {
        case SORT_IDENTITY:
            sortOrder = sortIdentity;
            break;
        case SORT_SHADER:
            sortOrder = sortShader;
            break;
        case SORT_DEPTH:
            sortOrder = sortDepth;
            break;
        case SORT_MODEL:
            sortOrder = sortModel;
        default:
            break;
    }
}


- (void) setSkyMap: (NSString*) name
{
    skyMap = [[YASkyMap alloc] initResource:name shader:[_shaders objectForKey:@"skymap"]];
    [skyMap load];
    [skyMap setupBuffer];
}

- (void) drawSkyMap
{
    const float hdrMul = 200.0f;
    const float asRatio = 600.0f / 400.0f;

    YAShader* shader = [_shaders objectForKey: @"skymap"];
    [shader activate];

    [[_transformer rotate] setVector:[[YAVector3f alloc] initVals:0.0f :0.0f :0.0f]];
    [[_transformer scale] setVector:[[YAVector3f alloc] initVals:hdrMul :hdrMul * asRatio :hdrMul * asRatio ]];

//    [[transformer translate] setVector:[[YAVector3f alloc] initVals:0.0f :0.0f  :0.0f ]];
//    [[transformer translate] setVector:[avatar position]];
    [[_transformer translate] setVector:[[YAVector3f alloc] initVals:_avatar.position.x :_avatar.position.y :_avatar.position.z ]];

    const YAMatrix4f* world = [_transformer transform];
    int location = shader.locMVP;
    if (location != -1)
        glUniformMatrix4fv(location, 1, GL_TRUE, &(world->m[0][0]));

    [skyMap draw];
}

- (YATextureArray*) addTextureArray: (NSString*) name withTextures: (NSArray*)textureNames
{
    [YALog debug:TAG message:@"addTextureArray"];
    NSAssert(textures != nil, @"Textures not initialized.");

    YATextureArray* textureArray = nil;

    if(name == nil || textureNames == nil )
        return nil;

    textureArray = [textures objectForKey: name];

    if(textureArray != nil) { // multiple exit points but i wont to prevent nesting
        [YALog debug:TAG message:@"TextureArray already exists."];
        return textureArray;
    }

    textureArray = [[YATextureArray alloc] initWithFilenames:textureNames];

    if([textureArray load]) {
        [textures setObject:textureArray forKey:name];
        [YALog debug:TAG message:@"New TextureArray created."];
    } else {
        [YALog debug:TAG message:@"Could not load texture."];
    }

    return textureArray;
}

- (YATexture*) addMipMap: (NSString*)textureName
{
    [YALog debug:TAG message:@"addMipMap"];
    NSAssert(textures != nil, @"Textures not initialized.");

    YATexture* texture = nil;

    if(textureName == nil)
        return nil;

    texture = [textures objectForKey: textureName];
    if (texture == nil) {
        texture = [[YATexture alloc] initWithFilename:textureName];
        if([texture loadMipMap]) {
            [textures setObject:texture forKey:textureName];
            [YALog debug:TAG message:@"New MipMap created."];
        } else {
            [YALog debug:TAG message:@"Could not load texture."];
        }

    } else {
        [YALog debug:TAG message:@"Texture already exists."];
    }

    return texture;
}

- (YAIngredient*) createIngredient: (NSString*) ingredientName
{
    [YALog debug:TAG message:@"createIngredient"];
    NSAssert(_ingredients != nil, @"Ingredients not initialized.");
    YAIngredient* ingredient = [_ingredients objectForKey: ingredientName];

    if(ingredient != nil) {
        [YALog debug:TAG message:@"Ingredient already exists."];
        return nil; // ingredient already exists.
    }

    ingredient = [[YAIngredient alloc] initWithName: ingredientName world: self];

    [displayLock lock];
    [_ingredients setObject:ingredient forKey: ingredientName];
    [displayLock unlock];

    return ingredient;
}

- (int)createImpersonator: (NSString*) name
{
    YAImpersonator* impersonator = [[YAImpersonator alloc] initWithIngredient: name];
    [displayLock lock];
    [impersonators setObject:impersonator forKey:[NSNumber  numberWithInt: [impersonator identifier]]];
    [displayLock unlock];
    return [impersonator identifier];
}


- (YAImpersonator*) getImpersonator: (int) identifier
{
    return [impersonators objectForKey: [NSNumber  numberWithInt: identifier]];
}

- (YABasicAnimator*) createBasicAnimator
{
    [YALog debug:TAG message:@"createBasicAnimator"];
    YABasicAnimator* animator = [[YABasicAnimator alloc] initAt:now];

    [displayLock lock];
    [realtimeAnimators addObject:animator];
    [displayLock unlock];

    return animator;
}


- (YABlockAnimator*) createBlockAnimator
{
    [YALog debug:TAG message:@"createBlockAnimator"];
    YABlockAnimator* animator = [[YABlockAnimator alloc] initAt:now];

    [displayLock lock];
    [realtimeAnimators addObject:animator];
    [displayLock unlock];

    return animator;
}


- (void) addShapeShifter: (NSString*) name
{
    [YALog debug:TAG message:[NSString stringWithFormat:@"add shapeshifter: %@", name]];
    YAShapeshifter* shapeshifter = [[YAShapeshifter alloc] initFromJson:name];

    if(shapeshifter == nil) {
        [YALog debug:TAG message:@"Could not create shapeshifter"];
        return;
    }

    NSString* inherentModelName = [shapeshifter inherentModel];
    YAShapeshifter* oldShifter = [shapeshifters objectForKey: inherentModelName];
    if (oldShifter == nil) {
        [shapeshifters setObject:shapeshifter forKey:inherentModelName];
        [shapeshifter createTBO];
    } else {
        [YALog debug:TAG message:@"Shapeshifter already available."];
    }
    [YALog debug:TAG message:@"Shapeshifter created"];
}

- (int) createImpersonatorWithShapeShifter: (NSString*) name
{
    YAIngredient *ingredient = [_ingredients objectForKey:name];

    if (ingredient == nil)
        [YALog debug:TAG message:@"Ingredient not Found"];

    NSString* modelName = [ingredient model];
    [YALog debug:TAG message:[NSString stringWithFormat:@"Lookup Shapeshifter for model: %@", modelName]];

    YAShapeshifter* shapeshifter  = [shapeshifters objectForKey:modelName];

    YAImpersonator* impersonator = [[YAImpersonator alloc] initWithIngredient: name];

    [displayLock lock];
    [impersonators setObject:impersonator forKey:[NSNumber  numberWithInt: [impersonator identifier]]];
    [displayLock unlock];

    if (shapeshifter == nil)
        [YALog debug:TAG message:@"No Shapeshifter for model found!"];
    else
        [impersonator addShapeshifter:shapeshifter];

    return [impersonator identifier];
}

- (void) removeAllIngredients
{
    [YALog debug:TAG message:@"removeAllIngredient"];
    [self removeAllImpersonators];
    [displayLock lock];
    [shapeshifters removeAllObjects];
    [_ingredients removeAllObjects];
    [_models removeAllObjects];
    [displayLock unlock];
}

- (void) removeAllImpersonators
{
    [YALog debug:TAG message:@"removeAllImpersonators"];

    [displayLock lock];
    impersonators = [[NSMutableDictionary alloc] initWithCapacity: 10];
    [displayLock unlock];
}

- (void) removeImpersonator: (int) identifier
{
    [YALog debug:TAG message:@"removeImpersonator"];

    @try {
        [displayLock lock];
        [impersonators removeObjectForKey:[NSNumber  numberWithInt: identifier]];
        [displayLock unlock];
    } @catch (NSException * e) {
        NSLog(@"Library unlock bug: %@", e);
    }
}

- (int) createImpersonatorFromText: (NSString*) text
{
    [YALog debug:TAG message:@"createImpersonatorFromText"];

    NSString* ingredientName = [NSString stringWithFormat:@"YAText2D_%d", uniqueId++];
    YAIngredient* ingredient = [self createIngredient:ingredientName];
    [ingredient setFlavour:Text];
    [ingredient setText:text];

    // the model is created from ingredient.text and not from the name (= Model File Name)
    [ingredient setModel:ingredientName];

    YAImpersonator* impersonator = [[YAImpersonator alloc] initWithIngredient: ingredientName];

    [displayLock lock];
    [impersonators setObject:impersonator forKey:[NSNumber  numberWithInt: [impersonator identifier]]];
    [displayLock unlock];

    return [impersonator identifier];
}

- (void) createHeightmapTexture: (id<YAHeightMap>) terrain withName: (NSString*) textureName
{
    [YALog debug:TAG message:@"createHeightmapTexture"];
    glfwMakeContextCurrent(sceneWindow);

    NSAssert(textures != nil, @"Textures not initialized.");

    if(textureName == nil) {
        [YALog debug:TAG message:@"Texture name cannot be empty."];
        return;
    }

    YATexture* texture = nil;

    texture = [textures objectForKey: textureName];
    if(texture != nil) {
        [YALog debug:TAG message:[NSString stringWithFormat:@"Texture %@ already exists.", textureName]];
        [displayLock lock];
        [texture update:terrain];
        [displayLock unlock];
        return;
    }

    texture = [[YATexture alloc] initWithName:textureName];
    [texture generate:terrain];

    [textures setObject:texture forKey:textureName];
    [YALog debug:TAG message:@"New Texture created."];

}

- (void) rescaleScene: (float) scale
{
    NSArray* imps = [impersonators allValues];

    for(YAImpersonator* imp in imps) {
        [imp.translation mulScalar:scale];
        [imp.size mulScalar:scale];
    }

    YAVector3f* avatarPosition = [_avatar position];
    [avatarPosition mulScalar:scale];
    [_avatar setPosition:avatarPosition];

    for(YALight* light in _lights) {

        if([light isKindOfClass:[YAGouradLight class]] ) {
            YAGouradLight* lg = (YAGouradLight*) light;
            [[lg position] mulScalar:scale];
        } else if( [light isKindOfClass:[YASpotLight class]]) {
            YASpotLight* ls = (YASpotLight*) light;
            [[ls position] mulScalar:scale];
        }

    }

}

- (void) updateTextIngredient: (NSString*) text Impersomator: (YAImpersonator*) impersonator
{
    NSString* ingredientName = [impersonator ingredientName];
    YAIngredient* ingredient = [_ingredients objectForKey:ingredientName];

    [ingredient setText:text];

    NSString* modelName = [ingredient model];

    [displayLock lock];
    [_models removeObjectForKey:modelName];

    YAText2D* textData = [[YAText2D alloc] initText:[ingredient text]];
    [textData vbos];

    glfwMakeContextCurrent(sceneWindow);
    YAModel* model = [[YATextModel alloc] initTrianglesWithShader:fontTexture vertexBuffer:[textData vbos] shader:[_shaders objectForKey:@"text2d"] ];

    // reuse the old model name
    [_models setObject:model forKey:modelName];
    [displayLock unlock];
}


- (YAInterpolationAnimator*) createInterpolationAnimator
{
    [YALog debug:TAG message:@"createInterpolationAnimator"];
    YAInterpolationAnimator* animator = [[YAInterpolationAnimator alloc] initAt:now];

    [displayLock lock];
    [realtimeAnimators addObject:animator];
    [displayLock unlock];

    return animator;
}

- (void) startEvent: (int) eventId message: (int) messsage
{
    NSDictionary* event = [NSDictionary dictionaryWithObjectsAndKeys:
                           [NSNumber numberWithInt:eventId], @"EVENT",
                           [NSNumber numberWithInt:messsage], @"MESSAGE", nil];

    [eventQueue enqueue:event];
}

- (void) setMultiSampling: (bool) status
{
    if (status == true) {
        glEnable(GL_MULTISAMPLE);
    } else
        glDisable(GL_MULTISAMPLE);
}

- (bool) multiSampling
{
    return glIsEnabled(GL_MULTISAMPLE);
}

- (void) removeAllAnimators
{
    [YALog debug:TAG message:@"removeAllAnimators"];
    [displayLock lock];
    animators = [[NSMutableArray alloc] initWithCapacity:10];
    realtimeAnimators = [[NSMutableArray alloc] initWithCapacity:2];
    [displayLock unlock];
}

- (void) setOpenGLContextToThread
{
        disableLoopContext = true;


     struct timespec delay;
     delay.tv_sec = 0;
     delay.tv_nsec = NSEC_PER_SEC / 60;

        do {
            nanosleep(&delay, NULL);
        } while(disableLoopContext != false);

        glfwMakeContextCurrent(sceneWindow);
        assert(sceneWindow == glfwGetCurrentContext());
}

- (void) freeOpenGLContextFromThread
{
            glfwMakeContextCurrent(NULL);
}

- (int) getGamePadNum
{
    int deviceN = (int)[[hidReader devices] count];
    if(deviceN > 3)
        deviceN = 3;
    return deviceN;
}

- (NSArray*) getAllImpIds
{
    return [impersonators allKeys];
}

- (void) removeIngredient: (NSString*) ingredientName
{
    [YALog debug:TAG message:@"removeIngredient"];
    NSAssert(_ingredients != nil, @"Ingredients not initialized.");
    YAIngredient* ingredient = [_ingredients objectForKey: ingredientName];

    if(ingredient == nil) {
        [YALog debug:TAG message:@"Unknow Ingredient."];
        return;
    }

    NSString* modelName = ingredient.model;

    YAShapeshifter* shapeshifter = [shapeshifters objectForKey:ingredientName];

    [displayLock lock];

    // remove the associated imps
    for(YAImpersonator* imp in [impersonators allValues]) {
        NSString* impIngredientName = imp.ingredientName;
        if([impIngredientName isEqualToString:ingredientName ]) {
            [impersonators removeObjectForKey:[NSNumber  numberWithInt: imp.identifier]];
        }
    }

    // remove the associated shapeshifters
    if(shapeshifter) {
        [shapeshifters removeObjectForKey:ingredientName];
        shapeshifter = nil;
    }

    // remove the ingredient
    [_ingredients removeObjectForKey: ingredientName];
    ingredient = nil;

    if(modelName != nil)
        [_models removeObjectForKey:modelName];

    [displayLock unlock];
}

#pragma mark WINDOW CALLBACK
#pragma mark -

static void glfw_error_callback(int error, const char* description)
{
    NSString* result = [NSString stringWithFormat:@"GLfw error occured [%d]: %s", error, description];
    [YALog debug:TAG message:result];
}

static void window_size_callback(GLFWwindow* window, int width, int height)
{
    if(transformerBridge != nil)
        [transformerBridge setDisplaySize:width height:height];
}

static void cursor_position_callback(GLFWwindow* window, double x, double y)
{
    if(masterBridge.traceMouseMove == YES) {
        if(lastPointBridge.x != x)
            [masterBridge startEvent:MOUSE_MOVE_X message:(int)lastPointBridge.x - x];
        if(lastPointBridge.y != y)
            [masterBridge startEvent:MOUSE_MOVE_Y message:(int)lastPointBridge.y - y];

        int xCenterOffset = 255 + ((x - [masterBridge.transformer renderWidth] / 2) * 512) / [masterBridge.transformer renderWidth];
        int yCenterOffset = 255 + ((y -[masterBridge.transformer renderHeight] / 2) * 512) / [masterBridge.transformer renderHeight];
        xCenterOffset = fmin(fmax(0,xCenterOffset),511);
        yCenterOffset = 511 - fmin(fmax(0,yCenterOffset),511);
        [masterBridge startEvent:MOUSE_VECTOR message:(xCenterOffset << 16) + yCenterOffset];
    }

    lastPointBridge.x = x;
    lastPointBridge.y = y;
}

static void mouse_button_callback(GLFWwindow* window, int button, int action, int mods)
{
    if(button == 0 && action == 1) {
        NSNumber* event = [NSNumber numberWithInt:MOUSE_DOWN];
        [eventQueueBridge enqueue:event];
    } else if(button == 0 && action == 0) {
        NSNumber* event = [NSNumber numberWithInt:MOUSE_UP];
        [eventQueueBridge enqueue:event];
    }
}

static void key_callback(GLFWwindow* window, int key, int scancode, int action, int mods)
{
    int event = -1;

    switch(key) {
        case GLFW_KEY_SPACE: event = SPACE; break;
        case GLFW_KEY_ESCAPE: event = ESCAPE; break;
        case GLFW_KEY_Q: event = KEY_Q; break;
        case GLFW_KEY_W: event = KEY_W; break;
        case GLFW_KEY_E: event = KEY_E; break;
        case GLFW_KEY_R: event = KEY_R; break;
        case GLFW_KEY_T: event = KEY_T; break;
        case GLFW_KEY_Z: event = KEY_Z; break;
        case GLFW_KEY_U: event = KEY_U; break;
        case GLFW_KEY_I: event = KEY_I; break;
        case GLFW_KEY_A: event = KEY_A; break;
        case GLFW_KEY_D: event = KEY_D; break;
        case GLFW_KEY_F: event = KEY_F; break;
        case GLFW_KEY_G: event = KEY_G; break;
        case GLFW_KEY_H: event = KEY_H; break;
        case GLFW_KEY_J: event = KEY_J; break;
        case GLFW_KEY_K: event = KEY_K; break;
        case GLFW_KEY_S: event = KEY_S; break;
        case GLFW_KEY_UP: event = KEY_UP; break;
        case GLFW_KEY_DOWN: event = KEY_DOWN; break;
        case GLFW_KEY_LEFT: event = KEY_LEFT; break;
        case GLFW_KEY_RIGHT: event = KEY_RIGHT; break;
        default: break;
    }

    if(event != -1)
        [masterBridge startEvent:event message:action];
}

@end
