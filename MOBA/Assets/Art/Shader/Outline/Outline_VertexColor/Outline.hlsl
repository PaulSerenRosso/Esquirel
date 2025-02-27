TEXTURE2D(_CameraVertexColorsTexture);
SAMPLER(sampler_CameraVertexColorsTexture);

TEXTURE2D(_CameraDepthTexture);
SAMPLER(sampler_CameraDepthTexture);

TEXTURE2D(_CameraNormalsTexture);
SAMPLER(sampler_CameraNormalsTexture);
float4 _CameraNormalsTexture_TexelSize;

void Outline_float(float2 UV, float OutlineThickness, float DepthSensitivity, float NormalsSensitivity, out float SceneDepth, out float3 Normals, out float Edges, out float3 VertexColors)
{
    SceneDepth = SAMPLE_TEXTURE2D(_CameraDepthTexture, sampler_CameraDepthTexture, UV).r;
    Normals = SAMPLE_TEXTURE2D(_CameraNormalsTexture, sampler_CameraNormalsTexture, UV);
    VertexColors = SAMPLE_TEXTURE2D(_CameraVertexColorsTexture, sampler_CameraVertexColorsTexture, UV);
    
    float halfScaleFloor = floor(OutlineThickness * 0.5);
    float halfScaleCeil = ceil(OutlineThickness * 0.5);
    float2 Texel = (1.0) / float2( _CameraNormalsTexture_TexelSize.z,  _CameraNormalsTexture_TexelSize.w);
    
    float2 uvSamples[4];
    //float depthSamples[4];
    //float3 normalSamples[4];
    float4 vertexColorSamples[4]; 

    uvSamples[0] = UV - float2(Texel.x, Texel.y) * halfScaleFloor;
    uvSamples[1] = UV + float2(Texel.x, Texel.y) * halfScaleCeil;
    uvSamples[2] = UV + float2(Texel.x * halfScaleCeil, -Texel.y * halfScaleFloor);
    uvSamples[3] = UV + float2(-Texel.x * halfScaleFloor, Texel.y * halfScaleCeil);

    for(int i = 0; i < 4 ; i++)
    {
        vertexColorSamples[i] = SAMPLE_TEXTURE2D(_CameraVertexColorsTexture, sampler_CameraVertexColorsTexture, uvSamples[i]);
    }

    // Vertex Color
    float3 vertexColorFiniteDifference0 = vertexColorSamples[1] - vertexColorSamples[0];
    float3 vertexColorFiniteDifference1 = vertexColorSamples[3] - vertexColorSamples[2];
    float edgeVertexColor = sqrt(dot(vertexColorFiniteDifference0, vertexColorFiniteDifference0) + dot(vertexColorFiniteDifference1, vertexColorFiniteDifference1));
    edgeVertexColor = edgeVertexColor > (1/100000) ? 1 : 0;

    Edges = edgeVertexColor;
}