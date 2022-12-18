// This shader fills the mesh shape with a color predefined in the code.

Shader "MasksMerger.shader"
{
    // The properties block of the Unity shader. In this example this block is empty
    // because the output color is predefined in the fragment shader code.

    Properties
    {

        _MainTex("-", 2D) = "white" {}
        _SecondTex("-", 2D) = "white" {}
        _ToleranceStep("ToleranceStep", float) =0
    }

    SubShader
    {
        Tags
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
         
            float _ToleranceStep;
            sampler2D _MainTex;
            sampler2D _SecondTex;
            
            float4 BakeMask(v2f_img i) : SV_TARGET
            {
                // si deuxième texture est noir alors je render la première 
                half4 firstTex = tex2D(_MainTex, i.uv);
                half4 secondTex = tex2D(_SecondTex, i.uv);
                  half4 finalColor;
                if (secondTex.a < _ToleranceStep)finalColor = firstTex;
                else
                {

                    float alpha = secondTex.a;
                    float reverseAlpha = 1-secondTex.a;
                    finalColor.r = secondTex.r*alpha+firstTex.r*reverseAlpha;
                    finalColor.g = secondTex.g*alpha+firstTex.g*reverseAlpha;
                    finalColor.b = secondTex.b*alpha+firstTex.b*reverseAlpha;
                    finalColor.a = 1;
                }
                return finalColor;
            }
            ENDCG
        }
    }
}