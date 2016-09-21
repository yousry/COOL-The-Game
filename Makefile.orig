CC=clang
CXX=clang++

OPT_RELEASE=-O3 -fPIC

INCLUDE=-I bis -I linux \
 -I /usr/local/include -I YAWorld/math -I YAWorld/gfx -I YAWorld/spatial\
 -I YAWorld/util -I YAWorld/audio -I YAWorld/imagedb -I YAWorld/texture -I YAWorld/ui\
 -I /usr/include/bullet -I /usr/include/SOIL\
 -I timeline -I defender -I extern/lz4 -I extern/lodepng\
 -I /usr/local/include/dispatch

LIBRARY=-L /usr/GNUstep/Local/Library/Libraries -L /usr/lib64 -L /usr/local/lib

CFLAGS=-MMD -MP -DGNUSTEP -DGNUSTEP_BASE_LIBRARY=1 -DGNU_RUNTIME=1 -DGNUSTEP_BASE_LIBRARY=1 -fno-strict-aliasing \
 -fexceptions -fobjc-exceptions -D_NATIVE_OBJC_EXCEPTIONS -pthread -fPIC -fno-omit-frame-pointer -Wall \
 -DGSWARN -DGSDIAGNOSE -Wno-import -fgnu-runtime -fconstant-string-class=NSConstantString -I. \
 -I/usr/GNUstep/Local/Library/Headers -I/usr/GNUstep/System/Library/Headers \
 -fobjc-arc -fobjc-runtime=gnustep -fblocks -fexceptions -pthread $(OPT_RELEASE)

CMMFLAGS=-MMD -MP -DGNUSTEP -DGNUSTEP_BASE_LIBRARY=1 -DGNU_RUNTIME=1 -DGNUSTEP_BASE_LIBRARY=1 -fno-strict-aliasing \
 -fexceptions -fobjc-exceptions -D_NATIVE_OBJC_EXCEPTIONS -pthread -fPIC -fno-omit-frame-pointer -Wall \
 -DGSWARN -DGSDIAGNOSE -Wno-import -fgnu-runtime -fconstant-string-class=NSConstantString -I. \
 -I/home/yousry/GNUstep/Library/Headers -I/usr/GNUstep/Local/Library/Headers -I/usr/GNUstep/System/Library/Headers \
 -fobjc-arc -fobjc-runtime=gnustep -fblocks -fexceptions -pthread -std=c++11 -ObjC++ -ffunction-sections -fdata-sections $(OPT_RELEASE)

 CPPFLAGS=$(OPT_RELEASE) -std=c++11 -Wall -ffunction-sections -fdata-sections

LDFLAGS=`gnustep-config --objc-libs` -lbsd -lobjc -fobjc-arc -lgnustep-base -ldispatch\
 -lGL -lglfw -lopenal -lalut -lvorbisfile -lstdc++ -lobjcxx -lz -lGLEW -lfreetype -lglfw\
 -lBulletSoftBody -lBulletDynamics -lBulletCollision -lLinearMath -lpng -lSOIL\
 $(OPT_RELEASE) -fexceptions -fsanitize-memory-track-origins -pthread -Wl


SOURCES=YAWorld/math/YAProbability.m\
YAWorld/math/YAMatrix3f.m YAWorld/math/YAMatrix4f.m YAWorld/math/YAQuaternion.m YAWorld/math/YAVector2f.m\
YAWorld/math/YAVector2i.m YAWorld/math/YAVector3f.m YAWorld/math/YAVector4f.m YAWorld/gfx/YAPerspectiveProjectionInfo.m\
YAWorld/gfx/YAVertex.m YAWorld/gfx/YA3DFileFormat.m YAWorld/gfx/YATransformator.m YAWorld/gfx/YAAvatar.m\
YAWorld/gfx/YABasicAnimator.m YAWorld/gfx/YABlockAnimator.m YAWorld/gfx/YATexture.m YAWorld/gfx/YATextureArray.m\
YAWorld/gfx/YAShader.m YAWorld/gfx/YAModel.m YAWorld/gfx/YALight.m YAWorld/gfx/YAGouradLight.m\
YAWorld/gfx/YAFogLight.m YAWorld/gfx/YAGridModel.m YAWorld/gfx/YAShapeshifter.m YAWorld/gfx/YAMaterial.m\
YAWorld/gfx/YAImpersonator.m YAWorld/gfx/YAIngredient.m YAWorld/gfx/YAInterpolationAnimator.m YAWorld/gfx/YAKinematic.m\
YAWorld/gfx/YAPickMap.m YAWorld/gfx/YAShadowMap.m YAWorld/gfx/YASkyMap.m YAWorld/gfx/YASpotLight.m\
YAWorld/gfx/YAText2D.m YAWorld/gfx/YATextModel.m YAWorld/gfx/YATriangleModel.m YAWorld/gfx/YAPhongLight.m\
YAWorld/audio/YAOpenAL.m YAWorld/util/YALog.m YAWorld/util/NSMutableArray+QueueAdditions.m YAWorld/util/NSData+RangeAdditions.m\
YAWorld/util/YADynamicGLAccess.m YAWorld/util/YAGLBufferManager.m YAWorld/util/YAGLExtensions.m YAWorld/util/HIDReader.m\
YAWorld/util/YAPreferences.m timeline/YACondition.m timeline/YATrigger.m timeline/YATimerTrigger.m\
timeline/YASituation.m timeline/YAEvent.m timeline/YAEventChain.m hello.m\
YARenderLoop.m YAScene.m YASceneDevelop.m bis/YAImpersonator+Physic.m\
bis/YASimplexNoise.m bis/YAImprovedNoise.m bis/YATerrain.m bis/YATriangleGrid.m\
bis/YASpheroidMover.m bis/YAPackerMover.m bis/YAMechatronMover.m bis/YALeggitMover.m\
bis/YAHumanoidMover.m bis/YAGollumerMover.m bis/YAFlapperMover.m bis/YABonzoidMover.m\
bis/YASceneUtils.m bis/YAShopAssembler.m bis/YAColonyMap.m bis/YADromedarMover.m\
bis/YAAlienRace.m bis/YAHumanRace.m bis/YAMechatronRace.m bis/YABonzoidRace.m\
bis/YAFlapperRace.m bis/YAGollumerRace.m bis/YALeggiteRace.m bis/YAPackerRace.m\
bis/YASpheroidRace.m bis/YAGameContext.m bis/YAImpGroup.m bis/YAStore.m\
bis/YASoundCollector.m bis/YAGameStateMachine.m bis/YAIntroStage.m bis/YAGamepadStage.m\
bis/YAPlayerColorStage.m bis/YASpeciesStage.m bis/YASummaryStage.m bis/YAInGameStage.m\
bis/YAImpCollector.m bis/YADevelopmentEvent.m bis/YAMapEvents.m bis/YAMoonClockEvent.m\
bis/YAMainEvents.m bis/YAEagleFlightEvents.m bis/YACounterEvent.m bis/YASocketEvents.m\
bis/YAProductionEvent.m bis/YAEagleController.m bis/YAEagleAssembler.m bis/YAMapManagement.m\
bis/YAPlotAuction.m bis/YAAuction.m bis/YAIngredientSetup.m bis/YATerrainEditor.m\
bis/YADevelopmentAI.m bis/YADevelopmentController.m bis/YAFortune.m bis/YAChronograph.m\
bis/YACommoditiesAuction.m bis/YAInertiaMovement.m bis/YAInfoEvents.m bis/YAShopEvent.m\
bis/YABulletEngineTranslator.m

OBJECTS=$(SOURCES:.m=.o)

DEPENDENCIES=$(SOURCES:.m=.d)

EXECUTABLE=COOL

all: $(EXECUTABLE)

$(EXECUTABLE): $(OBJECTS)
	$(CC) $(LIBRARY) $(LDFLAGS) $(OBJECTS) -o $@

%.o: %.m
	$(CC) $(CFLAGS) $(INCLUDE) -c $< -o $@

%.o: %.mm
	$(CC) $(CFLAGS) -ObjC++ $(INCLUDE) -c $< -o $@

clean:
	rm -rf $(OBJECTS) $(EXECUTABLE) $(DEPENDENCIES)
