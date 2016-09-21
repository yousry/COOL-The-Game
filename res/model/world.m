

int ThargoidId = [world createImpersonator: @"Thargoid"];
YAImpersonator* ThargoidImp = [world getImpersonator:ThargoidId];
    [[ThargoidImp rotation] setVector: [[YAVector3f alloc] initVals: -90.0f : 0.0f : 0.0f]];
    [[ThargoidImp translation] setVector: [[YAVector3f alloc] initVals: 0.0f : 0.0f : 0.0f]];
    [[ThargoidImp size] setVector: [[YAVector3f alloc] initVals: 1.0f :1.0f :1.0f]];
