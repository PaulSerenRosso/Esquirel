#ifndef  SHADER_UTILS
#define SHADER_UTILS

//https://www.shadertoy.com/view/lsdXDH
float4 genericDesaturate(float3 color, float factor)
{
    float3 lum = float3(0.299, 0.587, 0.114);
    float3 grey = float3(dot(lum.x, color.x), dot(lum.y, color.y), dot(lum.z, color.z));
    return float4(lerp(color, grey, factor),1.0);
}

//https://www.shadertoy.com/view/lsdXDH
float4 photoshop_desaturate(float3 color)
{
    float blackAndWhite = (min(color.r, min(color.y, color.z)) + max(color.r, max(color.g, color.b))) * 0.5;
    return float4(blackAndWhite.x, blackAndWhite, blackAndWhite, 1.0);
}

float3 CamToWorld (float4x4 inverseMVP, float2 uv, float depth)
{
    //Sample Camera Projection
    float4 pos = float4(uv.x, uv.y, depth, 1.0);
    pos.xyz = pos.xyz * 2.0 - 1.0;
    //Multiply with the Matrice View Projection
    pos = mul(inverseMVP, pos);
    return pos.xyz / pos.w;
}

//LEVELS
//https://gist.github.com/aferriss/9be46b6350a08148da02559278daa244

float3 gammaCorrect(float3 color, float gamma){
    return pow(color, float3((1.0/gamma).xxx));
}

float3 levelRange(float3 color, float minInput, float maxInput){
    return min(max(color - float3(minInput.xxx), float3(0.0,0.0,0.0))
        / (float3(maxInput.xxx) - float3(minInput.xxx)), float3(1.0,1.0,1.0));
}

float3 finalLevels(float3 color, float minInput, float gamma, float maxInput){
    return gammaCorrect(levelRange(color, minInput, maxInput), gamma);
}

//SDF
//https://iquilezles.org/articles/distfunctions2d/
float SDFBox(float2 uv, float2 size)
{
    float2 d = abs(uv)-size;
    return length(max(d,0.0)) + min(max(d.x,d.y),0.0);
}

#endif