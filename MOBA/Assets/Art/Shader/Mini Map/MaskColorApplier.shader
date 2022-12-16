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
