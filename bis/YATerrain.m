//
//  YATerrain.m
//  BusinessInSpace
//
//  Created by Yousry Abdallah on 11.05.12.
//  Copyright (c) 2012 yousry.de. All rights reserved.
//

#include <bsd/stdlib.h>
#import <math.h>

#import "YAVector2f.h"
#import "YAVector3f.h"
#import "YAVector4f.h"

#import "YAImprovedNoise.h"
#import "YASimplexNoise.h"
#import "YALog.h"
#import "YATerrain.h"

typedef struct {
    int v;
    int h;
} Point;

#define rnd(dsp) (((float) (arc4random() % ((unsigned)RAND_MAX + 1)) / RAND_MAX) * (2.0f * dsp) ) - dsp

@interface YATerrain()

- (void) midPointDisplacement;
- (void) perlinNoise;
- (void) simplexNoise;
- (void) testStructure;
- (void) cleanBorder;

- (void) setupDefaults;

-(float) turbulenceSimplex :(float) pX :(float) pY :(float) seed :(int) octaves;
- (float) turbulence :(float) pX :(float) pY  :(float) seed :(int) octaves;

@end

@implementation YATerrain

@synthesize  terrainDimension;

@synthesize tDisplacement, tAmplitude, tTileBorder, tFrequency, tGain;
@synthesize tLacunarity, tOctaves;

float **heightmap;

void diamondStep(Point a, Point b, Point c, Point d, float displacement);
void squareStep(Point a, Point b, Point c, Point d, Point e, float displacement);
float billowedNoise(float pX, float pY, float seed);

static const NSString* TAG = @"YATerrain";
// does the gamplay change if an altered dimension is used?
static const NSPoint boardDimension = {7,7}; // was {9,5};

- (id) init
{
    self = [super init];
    if (self) {
        terrainDimension = 32 + 1;
        [self setupDefaults];
        heightmap = (float**) calloc(terrainDimension , sizeof(float*));
        for(int i = 0; i < terrainDimension; i++)
            heightmap[i] = (float*)calloc(terrainDimension , sizeof(float));
        
    }
    
    return self;
    
}

- (id) initSize: (int) size
{
    self = [super init];
    if (self) {
        terrainDimension = size;
        [self setupDefaults];
        heightmap = (float**) calloc(terrainDimension , sizeof(float*));
        for(int i = 0; i < terrainDimension; i++)
            heightmap[i] = (float*)calloc(terrainDimension , sizeof(float));
    }
    
    return self;
}


- (void) setupDefaults
{
    // 64 grid
//    tDisplacement = 120.0f;
//    tAmplitude = 80.0f;
//    tFrequency = 0.0055f * (128 / terrainDimension);
//    tGain = 0.5f;
//    tLacunarity = 1.92;
//    tOctaves = 7;

    // 32 grid
    tDisplacement = 122.0f;
    tAmplitude = 66.5f;
    tFrequency = 0.027900;
    tGain = 0.420000;
    tLacunarity = 1.915000;
    tOctaves = 7;

    tTileBorder = terrainDimension * 0.015625;
    _brdSize = terrainDimension * 0.078125f;
    _fieldWidth = ceilf((terrainDimension - 2 * (_brdSize - 1)) / boardDimension.x);
    _fieldHeight = ceilf((terrainDimension - 2 * (_brdSize - 1)) / boardDimension.y);
    

    switch (terrainDimension - 1) {
        case 512:
            _fieldHeight = 72;
            _fieldWidth = 72;
            _brdSize = 4;
            tTileBorder = 2;
            break;
        case 256:
            _fieldHeight = 34;
            _fieldWidth = 34;
            _brdSize = 9;
            tTileBorder = 2;
            break;
        case 128:
            _fieldHeight = 16;
            _fieldWidth = 16;
            _brdSize = 9;
            tTileBorder = 2;
            break;
        case 64:
            _fieldHeight = 8;
            _fieldWidth = 8;
            _brdSize = 4;
            tTileBorder = 1;
            break;
        case 32:
            _fieldHeight = 4;
            _fieldWidth = 4;
            _brdSize = 2;
            tTileBorder = 0;
            break;
        default:
            [YALog debug:TAG message:[NSString stringWithFormat:@"No Terrain Data defined for dimension: %d", terrainDimension]];
            break;
    }
}

- (void) createMountain: (int) x : (int) y
{
    assert(x >= 0 && x < boardDimension.x);
    assert(y >= 0 && y < boardDimension.y);
    
    
    const int heightMapX = x * _fieldWidth + _brdSize;
    const int heightMapY = y * _fieldHeight  + _brdSize;
    
    
    float sum = 0;
    for(int x = heightMapX; x < heightMapX + _fieldWidth; x++) {
        for(int y = heightMapY; y < heightMapY + _fieldHeight; y++) {
            sum += heightmap[x][y];
        }
    }
    
    const float average = sum / (_fieldWidth * _fieldHeight);
    
    for(int x = 0 ; x < _fieldWidth; x++) {
        for(int y = 0; y < _fieldHeight; y++) {
            
            const int xPos = x + heightMapX;
            const int yPos = y + heightMapY;
            
            
            const float centerX = (float)_fieldWidth / 2.0f;
            const float centerY = (float)_fieldHeight / 2.0f;
            
            float maxDist  = powf( 0.0f - centerX, 2) + powf(0.0f - centerY, 2);
            maxDist = sqrtf(maxDist);
            
            float dist = powf( (float)x - centerX, 2) + powf( (float)y - centerY, 2);
            dist = sqrtf(dist);
            
            const float pDist = 1.0f - dist / maxDist;
            heightmap[xPos][yPos] = fminf((heightmap[xPos][yPos] + fmaxf(average, 8) * pDist), 54);
        }
    }
}

- (float) flattenField :(int) x :(int) y {
    [YALog debug:TAG message:@"flattenField"];
    
    assert(x >= 0 && x < boardDimension.x);
    assert(y >= 0 && y < boardDimension.y);
    
    
    const int heightMapX = x * _fieldWidth + _brdSize;
    const int heightMapY = y * _fieldHeight  + _brdSize;
    
    
    float sum = 0;
    for(int x = heightMapX; x < heightMapX + _fieldWidth; x++) {
        for(int y = heightMapY; y < heightMapY + _fieldHeight; y++) {
            sum += heightmap[x][y];
        }
    }
    
    const float average = sum / (_fieldWidth * _fieldHeight);
    
    for(int x = 0 ; x < _fieldWidth; x++) {
        for(int y = 0; y < _fieldHeight; y++) {
            
            const int xPos = x + heightMapX;
            const int yPos = y + heightMapY;
           
            if(x > tTileBorder && x < _fieldWidth - tTileBorder && y > tTileBorder && y < _fieldWidth - tTileBorder )
                heightmap[xPos][yPos] = average;
            else {
                const float centerX = (float)_fieldWidth / 2.0f;
                const float centerY = (float)_fieldHeight / 2.0f;

                float maxDist  = powf( 0.0f - centerX, 2) + powf(0.0f - centerY, 2);
                maxDist = sqrtf(maxDist);
                
                float dist = powf( (float)x - centerX, 2) + powf( (float)y - centerY, 2);
                dist = sqrtf(dist);

                const float pDist = 1.0f - dist / maxDist;
                
                const float range = average -  heightmap[xPos][yPos];
                heightmap[xPos][yPos] = heightmap[xPos][yPos] + (range * pDist);
            }
        }
    }

    
    
    [YALog debug:TAG message:@"flattenField finished"];
    return average;
}



- (void) generate: (float) seed
{
    
    
    [YALog debug:TAG message:@"generate"];
    _seed = seed;
    [self perlinNoise];
    [self cleanBorder];
}


- (void) cleanBorder
{

    int forcedBorder = _brdSize < 5 ? 5 : _brdSize;
    
    for (int a = 0; a < forcedBorder ; a++) {
        for (int b = 0; b < terrainDimension; b++) {
            
            float m = (a < 1) ? 0.0f : a * (1.0f / (float)forcedBorder);

            heightmap[a][b] *= m;
            heightmap[b][a] *= m;
            
            heightmap[(terrainDimension -1) - a][b] *= m;
            heightmap[b][(terrainDimension -1) - a] *= m;
            
        }
    }
}



- (void) testStructure
{
    for (int x = 0; x < terrainDimension; x++)
        for (int y = 0; y < terrainDimension; y++) {
            if((x > 5 && x < 12) || (y > 5 && y < 12) )
                heightmap[x][y] = 80;
        }
}


- (void) simplexNoiseExt
{
    [YALog debug:TAG message:@"simplexNoiseExt"];
    for (int x = 0; x < terrainDimension; x++)
        for (int z = 0; z < terrainDimension; z++) {
            float r = [self turbulenceSimplex:x :z :_seed :tOctaves];
            heightmap[x][z] = r;
        }
    [YALog debug:TAG message:@"simplexNoise finished"];
}


-(float) turbulenceSimplex :(float) pX :(float) pY :(float) seed :(int) octaves
{
    float lacunarity = tLacunarity;
    float gain = tGain;
    float sum = 0;
    float freq = tFrequency, amp = tAmplitude;
    for (int i=0; i < octaves; i++) {
        float n = [YASimplexNoise noise:pX * freq :pY * freq :seed + i / 12 :seed + i / 256];
        sum += n  * amp;
        freq *= lacunarity;
        amp *= gain;
    }
    return sum;
}

- (void) simplexNoise
{
    [YALog debug:TAG message:@"simplexNoise"];
    
    for (int x = 0; x < terrainDimension; x++)
        for (int z = 0; z < terrainDimension; z++) {
            float r = [YASimplexNoise noise:x :z :_seed: 16];
            heightmap[x][z] = r * 40 -40;
        }
    [YALog debug:TAG message:@"simplexNoise finished"];
}


- (void) perlinNoise
{
    [YALog debug:TAG message:@"perlinNoise"];
    
    for (int x = 0; x < terrainDimension; x++)
        for (int z = 0; z < terrainDimension; z++) {
            float r = [ self turbulenceSimplex:x :z :_seed :tOctaves];
            
            heightmap[x][z] = fabs(r) - 7;
        }
    [YALog debug:TAG message:@"perlinNoise finished"];
}


- (float) turbulence :(float) pX :(float) pY  :(float) seed :(int) octaves
{
    float lacunarity = tLacunarity;
    float gain = tGain;
    
    float sum = 0;
    float freq = tFrequency, amp = tAmplitude;
    
    for (int i=0; i < octaves; i++) {
        float n = [YAImprovedNoise noiseAtX: pX * freq Y: pY * freq Z: seed + i / 256];
        sum += n * amp;
        freq *= lacunarity;
        amp *= gain;
    }
    return sum;
}


- (void) midPointDisplacement
{
    [YALog debug:TAG message:@"midPointDisplacement"];
    
    float displacement = tDisplacement;
    
    for (int step = terrainDimension -1; step > 1; step /=2) {
        
        for (int i = 0; i < terrainDimension - 2; i+=step) {
            for(int j=0; j < terrainDimension - 2; j+=step) {
                Point a = {i , j};
                Point b = {i + step, j};
                Point c = {i, j + step};
                Point d = {i + step, j + step};
                diamondStep(a, b, c, d, displacement);
            }
        }
        
        for (int i = 0; i < terrainDimension - 2; i+=step) {
            for(int j=0; j < terrainDimension - 2; j+=step) {
                Point a = {i , j};
                Point b = {i + step, j};
                Point c = {i, j + step};
                Point d = {i + step, j + step};
                Point e = {i + step / 2, j + step / 2};
                
                squareStep(a, b, c, d, e, displacement);
                
            }
        }
        
        displacement *= pow(2, -1.5);
    }
    
    for(int x = 0; x < terrainDimension; x++){
        heightmap[0][x] = 0;
        heightmap[x][0] = 0;
        heightmap[terrainDimension -1][x] = 0;
        heightmap[x][terrainDimension -1] = 0;
        
    }
    
    [YALog debug:TAG message:@"midPointDisplacement finished"];
}

void diamondStep(Point a, Point b, Point c, Point d, float displacement)
{
    Point e = {a.v + ((b.v - a.v) / 2), a.h - ((a.h - c.h) / 2)};
    
    heightmap[e.v][e.h] = (heightmap[a.v][a.h] + heightmap[b.v][b.h] + heightmap[c.v][c.h] + heightmap[d.v][d.h]) / 4.0f + rnd(displacement);
}

void squareStep(Point a, Point b, Point c, Point d, Point e, float displacement)
{
    Point f = {a.v, a.h - ((a.h - c.h) / 2)};
    Point g = {a.v + ((b.v - a.v) / 2), a.h};
    Point h = {b.v, b.h - ((b.h - d.h) / 2)};
    Point i = {c.v + ((d.v - c.v) / 2), c.h};
    
    // recursive end condition
    if(f.v < h.v -1) {
        heightmap[f.v][f.h] = (heightmap[a.v][a.h] + heightmap[c.v][c.h] + heightmap[e.v][e.h] + heightmap[e.v][e.h]) / 4.0f + rnd(displacement);
        heightmap[g.v][g.h] = (heightmap[a.v][a.h] + heightmap[b.v][b.h] + heightmap[e.v][e.h] + heightmap[e.v][e.h]) / 4.0f + rnd(displacement);
        heightmap[h.v][h.h] = (heightmap[b.v][b.h] + heightmap[d.v][d.h] + heightmap[e.v][e.h] + heightmap[e.v][e.h]) / 4.0f + rnd(displacement);
        heightmap[i.v][i.h] = (heightmap[c.v][c.h] + heightmap[d.v][d.h] + heightmap[e.v][e.h] + heightmap[e.v][e.h]) / 4.0f + rnd(displacement);
    }
}

- (float) heightAt :(int) x :(int) y
{
    return heightmap[x][y];
}

float billowedNoise(float pX, float pY, float seed)
{
    float r = [YAImprovedNoise noiseAtX: pX Y: pY Z: seed ];
    return r;
}

- (void)dealloc
{
    [YALog debug:TAG message:@"Releasing hightmap memory."];
    for(int i = 0; i < terrainDimension; i++)
        free(heightmap[i]);
    free(heightmap);
}

@end
