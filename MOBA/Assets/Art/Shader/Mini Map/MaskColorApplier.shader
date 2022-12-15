// This shader fills the mesh shape with a color predefined in the code.

Shader "MaskColorApplier.shader"
{
    // The properties block of the Unity shader. In this example this block is empty
    // because the output color is predefined in the fragment shader code.

    Properties
    {
        _MainColor("Color",Color) = (0,0,0,0)
        _ToleranceStep("ToleranceStep", float) =0
        _MainTex("-", 2D) = "white" {}
    }

    SubShader
    { Tags 
        {
            "RenderType" = "Transparent"
            }
        Pass
        {
            ZTest Always
            ZWrite Off
            Cull Off
            CGPROGRAM
            #include "UnityCG.cginc"
            #pragma vertex vert_img
            #pragma fragment BakeMask
            float4 _MainColor;
            float _ToleranceStep;
            sampler2D _MainTex;
            float4 _MainTex_TexelSize;
            float4 BakeMask(v2f_img i) : SV_TARGET
            {
                half4 customColor  = _MainColor;
           
                half4 tex = tex2D(_MainTex, i.uv);
                
                if (tex.a> _ToleranceStep)
                {
                    tex = 1, 1, 1, 1;
                }
                else tex = 0, 0, 0, 0;
                
                customColor *= tex;
                
                return customColor;
            }
            ENDCG
        }
    }
}
/*
// The SubShader block containing the Shader code. 
SubShader
{
    ZTest Off
    ZWrite Off
    Cull Off
    // SubShader Tags define when and under which conditions a SubShader block or
    // a pass is executed.
    Tags
    {
        "RenderType" = "Opaque" "RenderPipeline" = "UniversalRenderPipeline"
    }

    Pass
    {

        // The HLSL code block. Unity SRP uses the HLSL language.
        HLSLPROGRAM
        // This line defines the name of the vertex shader. 
        #pragma vertex vert
        // This line defines the name of the fragment shader. 
        #pragma fragment frag


        // The Core.hlsl file contains definitions of frequently used HLSL
        // macros and functions, and also contains #include references to other
        // HLSL files (for example, Common.hlsl, SpaceTransforms.hlsl, etc.).
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

        // The structure definition defines which variables it contains.
        // This example uses the Attributes structure as an input structure in
        // the vertex shader.
        struct Attributes
        {
            // The positionOS variable contains the vertex positions in object
            // space.
            float4 positionOS : POSITION;
            float2 uv : TEXCOORD0;
        };

        struct Varyings
        {
            // The positions in this struct must have the SV_POSITION semantic.
            float4 positionHCS : SV_POSITION;
            float2 uv : TEXCOORD0;
        };

        float4 _MainColor;
        float4 _BaseMap_ST;
        float _ToleranceStep;

        TEXTURE2D(_BaseMap);
        SAMPLER(sampler_BaseMap);
        // The vertex shader definition with properties defined in the Varyings 
        // structure. The type of the vert function must match the type (struct)
        // that it returns.
        Varyings vert(Attributes IN)
        {
            // Declaring the output object (OUT) with the Varyings struct.
            Varyings OUT;
            // The TransformObjectToHClip function transforms vertex positions
            // from object space to homogenous space
            OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
            OUT.uv = TRANSFORM_TEX(IN.uv, _BaseMap);
            // Returning the output.
            return OUT;
        }

        // The fragment shader definition.            
        half4 frag(Varyings IN) : SV_Target
        {
            // Defining the color variable and returning it.
            half4 customColor;
            customColor = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, IN.uv);
            if (customColor.r + customColor.g + customColor.b > _ToleranceStep)
            {
                customColor = 1, 1, 1, 1;
                customColor *= _MainColor;
            }
            else customColor = 0, 0, 0, 0;

            return customColor;
        }
    
    }
}
*/