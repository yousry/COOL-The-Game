#define GLFW_INCLUDE_NONE
#import <GL/glcorearb.h>
#import <GLFW/glfw3.h>

#import "YAHeightMap.h"

#import <Foundation/Foundation.h>

@class YAIngredient, YAVector4f, YASpotLight, YAGouradLight, YATransformator,
		YAAvatar, YAShadowMap, YAPickMap, YATexture, YASkyMap, YAModel,
        YABasicAnimator, YAImpersonator, YABlockAnimator, YAInterpolationAnimator,
        HIDReader, YAOpenAL, YAVector2f, YAPreferences;

typedef enum
{
    NONE = -1,
    RETURN = 1,
    MOUSE_DOWN = 2,
    MOUSE_UP = 3,
    USER = 4,
    GAMEPAD_LEFT_X = 5,
    GAMEPAD_LEFT_Y = 6,
    GAMEPAD_RIGHT_X = 7,
    GAMEPAD_RIGHT_Y = 8,
    GAMEPAD_BUTTON_OK = 9,
    GAMEPAD_BUTTON_CANCEL = 10,
    GAMEPAD_BUTTON_A = 11,
    GAMEPAD_BUTTON_B = 12,
    GAMEPAD_BUTTON_BACK = 35,
    GAMEPAD_BUTTON_START = 36,
    GAMEPAD_BUTTON_LB = 37,
    GAMEPAD_BUTTON_RB = 38,
    GAMEPAD_BUTTON_LT = 39,
    GAMEPAD_BUTTON_RT = 40,
    GAMEPAD_BUTTON_LEFT = 41,
    GAMEPAD_BUTTON_RIGHT = 42,
    MOUSE_MOVE_X = 13,
    MOUSE_MOVE_Y = 14,
    SPACE = 15,
    ESCAPE = 16,
    KEY_Q = 17,
    KEY_W = 18,
    KEY_E = 19,
    KEY_R = 20,
    KEY_T = 21,
    KEY_Z = 22,
    KEY_U = 23,
    KEY_I = 24,
    KEY_A = 25,
    KEY_S = 26,
    KEY_D = 27,
    KEY_F = 28,
    KEY_G = 29,
    KEY_H = 30,
    KEY_J = 31,
    KEY_K = 32,
    MOUSE_SCROLL = 33,
    MOUSE_VECTOR = 34,
    KEY_UP = 35,
    KEY_DOWN = 36,
    KEY_LEFT = 37,
    KEY_RIGHT = 38
} event_keyPressed;

typedef enum {
    SORT_DEPTH,
    SORT_IDENTITY,
    SORT_SHADER,
    SORT_MODEL
} sort_order;


@interface YARenderLoop: NSObject {
@private

	GLFWwindow* sceneWindow;

    NSRecursiveLock* displayLock;

	YAVector4f* clearColor;
	YASpotLight* spotlight;
    YAGouradLight* defaultLight;
	YASkyMap* skyMap;
	YAShadowMap* shadowMap;
	YAPickMap* pickMap;
    YATexture* fontTexture;
    uint uniqueId;

    NSMutableDictionary* textures;
    NSMutableDictionary* impersonators;
    NSMutableArray* animators;
    NSMutableArray* realtimeAnimators;
    NSMutableDictionary* shapeshifters;

    YAModel* lastDrawnModel;

    volatile NSMutableArray* eventQueue;
    id sortShader, sortIdentity, sortDepth, sortModel, sortOrder;

    HIDReader* hidReader;

    float now;
    volatile bool disableLoopContext;

    YAVector2f* lastPoint;

    YAPreferences* prefs;
}

- (void) doLoop;
- (void) prepareOpenGL;
- (void) setUpMetaWorld;

- (void) createModelFromTriangles: (NSData*)triangleData name: (NSString*) modelName ingredient: (YAIngredient*) ingredient;
- (void) createModelFromGrid: (NSData*)triangleData name: (NSString*) modelName ingredient: (YAIngredient*) ingredient;
- (void) updateModel: (NSString*) modelName withTriangles: (NSData*) triangleData;
- (void) addModelWithShader: (NSString*) modelName shader: (NSString*) shaderId ingredient: (YAIngredient*) ingredient;
- (void) addModel: (NSString*) modelName ingredient: (YAIngredient*) ingredient;

- (void) resetAnimators;
- (void) changeImpsSortOrder: (sort_order) sort;
- (void) setSkyMap: (NSString*) name;

- (YAIngredient*) createIngredient: (NSString*) ingredientName;
- (int)createImpersonator: (NSString*) name;
- (YAImpersonator*) getImpersonator: (int) identifier;

- (YABasicAnimator*) createBasicAnimator;
- (YABlockAnimator*) createBlockAnimator;
- (void) addShapeShifter: (NSString*) name;
- (int) createImpersonatorWithShapeShifter: (NSString*) name;
- (void) removeAllIngredients;
- (void) removeAllImpersonators;
- (void) removeImpersonator: (int) identifier;
- (int) createImpersonatorFromText: (NSString*) text;
- (void) createHeightmapTexture: (id<YAHeightMap>) terrain withName: (NSString*) textureName;
- (void) rescaleScene: (float) scale;
- (void) updateTextIngredient: (NSString*) text Impersomator: (YAImpersonator*) impersonator;
- (YAInterpolationAnimator*) createInterpolationAnimator;
- (void) startEvent: (int) eventId message: (int) messsage;

- (void) setMultiSampling: (bool) status;
- (bool) multiSampling;
- (void) removeAllAnimators;

- (void) setOpenGLContextToThread;
- (void) freeOpenGLContextFromThread;

- (int) getGamePadNum;

- (NSArray*) getAllImpIds;

- (void) removeIngredient: (NSString*) ingredientName;


@property (strong, readonly) NSArray* lights;
@property (strong, readonly) YATransformator* transformer;
@property (strong, readonly) YATransformator* shadowTransformer;
@property (strong, readonly) YAAvatar* avatar;
@property (strong, readonly) YAAvatar* shadowAvatar;
@property (strong, readonly) NSMutableDictionary* ingredients;
@property (strong, readonly) NSDictionary* shaders;
@property (strong, readonly) NSMutableDictionary* models;

@property (assign, readwrite) bool drawScene;
@property (assign, readwrite) bool activeAnimation;

@property (assign) float gammaCorrection;
@property (weak, readwrite) YAOpenAL* openAL;

@property (assign, readwrite) bool traceMouseMove;
@end