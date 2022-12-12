// Made with Amplify Shader Editor v1.9.1.2
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "S_Map_V2"
{
	Properties
	{
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		[ASEBegin]_DebugVertexPaintingAdding("DebugVertexPaintingAdding", Range( 0 , 1)) = 1
		[Header(Debug Mode)]_GrayscaleDebug("GrayscaleDebug", Range( 0 , 1)) = 0
		_NormalDebug("NormalDebug", Range( 0 , 1)) = 0
		_DesaturateMapDebug("DesaturateMapDebug", Range( 0 , 1)) = 0
		_VertexPaintDebug("VertexPaintDebug", Range( 0 , 1)) = 0
		[Header(Terrain Mask)]_TerrainMask_VertexPaint("TerrainMask_VertexPaint", 2D) = "white" {}
		[Header(Texture 1 Vertex Paint Black)]_T1_Terrain("T1_Terrain", 2D) = "white" {}
		_T1_TerrainNAOH("T1_Terrain NAOH", 2D) = "white" {}
		_T1_Tiling1("T1_Tiling", Range( 1 , 100)) = 10
		_T1_ProceduralTiling1("T1_ProceduralTiling", Range( 0 , 1)) = 0
		[Header(Texture 2 Vertex Paint Red)]_T2_Terrain("T2_Terrain", 2D) = "white" {}
		_T2_TerrainNAOH("T2_Terrain NAOH", 2D) = "white" {}
		_T2_Tilling1("T2_Tilling", Range( 1 , 100)) = 10
		_T2_ProceduralTiling1("T2_ProceduralTiling", Range( 0 , 1)) = 0
		[Header(Texture 3 Vertex Paint Green)]_T3_Terrain("T3_Terrain", 2D) = "white" {}
		_T3_TerrainNAOH("T3_Terrain NAOH", 2D) = "white" {}
		_T3_Tilling1("T3_Tilling", Range( 1 , 100)) = 10
		_T3_ProceduralTiling1("T3_ProceduralTiling", Range( 0 , 1)) = 0
		[Header(Texture 4 Vertex Paint Blue)]_T4_Terrain("T4_Terrain", 2D) = "white" {}
		_T4_TerrainNAOH("T4_Terrain NAOH", 2D) = "white" {}
		_T4_Tilling1("T4_Tilling", Range( 0 , 100)) = 10
		[ASEEnd]_T4_ProceduralTiling1("T4_ProceduralTiling", Range( 0 , 1)) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}


		//_TessPhongStrength( "Tess Phong Strength", Range( 0, 1 ) ) = 0.5
		//_TessValue( "Tess Max Tessellation", Range( 1, 32 ) ) = 16
		//_TessMin( "Tess Min Distance", Float ) = 10
		//_TessMax( "Tess Max Distance", Float ) = 25
		//_TessEdgeLength ( "Tess Edge length", Range( 2, 50 ) ) = 16
		//_TessMaxDisp( "Tess Max Displacement", Float ) = 25
	}

	SubShader
	{
		LOD 0

		

		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Opaque" "Queue"="Geometry" }

		Cull Back
		AlphaToMask Off

		

		HLSLINCLUDE
		#pragma target 4.5
		#pragma prefer_hlslcc gles
		// ensure rendering platforms toggle list is visible

		#ifndef ASE_TESS_FUNCS
		#define ASE_TESS_FUNCS
		float4 FixedTess( float tessValue )
		{
			return tessValue;
		}

		float CalcDistanceTessFactor (float4 vertex, float minDist, float maxDist, float tess, float4x4 o2w, float3 cameraPos )
		{
			float3 wpos = mul(o2w,vertex).xyz;
			float dist = distance (wpos, cameraPos);
			float f = clamp(1.0 - (dist - minDist) / (maxDist - minDist), 0.01, 1.0) * tess;
			return f;
		}

		float4 CalcTriEdgeTessFactors (float3 triVertexFactors)
		{
			float4 tess;
			tess.x = 0.5 * (triVertexFactors.y + triVertexFactors.z);
			tess.y = 0.5 * (triVertexFactors.x + triVertexFactors.z);
			tess.z = 0.5 * (triVertexFactors.x + triVertexFactors.y);
			tess.w = (triVertexFactors.x + triVertexFactors.y + triVertexFactors.z) / 3.0f;
			return tess;
		}

		float CalcEdgeTessFactor (float3 wpos0, float3 wpos1, float edgeLen, float3 cameraPos, float4 scParams )
		{
			float dist = distance (0.5 * (wpos0+wpos1), cameraPos);
			float len = distance(wpos0, wpos1);
			float f = max(len * scParams.y / (edgeLen * dist), 1.0);
			return f;
		}

		float DistanceFromPlane (float3 pos, float4 plane)
		{
			float d = dot (float4(pos,1.0f), plane);
			return d;
		}

		bool WorldViewFrustumCull (float3 wpos0, float3 wpos1, float3 wpos2, float cullEps, float4 planes[6] )
		{
			float4 planeTest;
			planeTest.x = (( DistanceFromPlane(wpos0, planes[0]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos1, planes[0]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos2, planes[0]) > -cullEps) ? 1.0f : 0.0f );
			planeTest.y = (( DistanceFromPlane(wpos0, planes[1]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos1, planes[1]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos2, planes[1]) > -cullEps) ? 1.0f : 0.0f );
			planeTest.z = (( DistanceFromPlane(wpos0, planes[2]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos1, planes[2]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos2, planes[2]) > -cullEps) ? 1.0f : 0.0f );
			planeTest.w = (( DistanceFromPlane(wpos0, planes[3]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos1, planes[3]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos2, planes[3]) > -cullEps) ? 1.0f : 0.0f );
			return !all (planeTest);
		}

		float4 DistanceBasedTess( float4 v0, float4 v1, float4 v2, float tess, float minDist, float maxDist, float4x4 o2w, float3 cameraPos )
		{
			float3 f;
			f.x = CalcDistanceTessFactor (v0,minDist,maxDist,tess,o2w,cameraPos);
			f.y = CalcDistanceTessFactor (v1,minDist,maxDist,tess,o2w,cameraPos);
			f.z = CalcDistanceTessFactor (v2,minDist,maxDist,tess,o2w,cameraPos);

			return CalcTriEdgeTessFactors (f);
		}

		float4 EdgeLengthBasedTess( float4 v0, float4 v1, float4 v2, float edgeLength, float4x4 o2w, float3 cameraPos, float4 scParams )
		{
			float3 pos0 = mul(o2w,v0).xyz;
			float3 pos1 = mul(o2w,v1).xyz;
			float3 pos2 = mul(o2w,v2).xyz;
			float4 tess;
			tess.x = CalcEdgeTessFactor (pos1, pos2, edgeLength, cameraPos, scParams);
			tess.y = CalcEdgeTessFactor (pos2, pos0, edgeLength, cameraPos, scParams);
			tess.z = CalcEdgeTessFactor (pos0, pos1, edgeLength, cameraPos, scParams);
			tess.w = (tess.x + tess.y + tess.z) / 3.0f;
			return tess;
		}

		float4 EdgeLengthBasedTessCull( float4 v0, float4 v1, float4 v2, float edgeLength, float maxDisplacement, float4x4 o2w, float3 cameraPos, float4 scParams, float4 planes[6] )
		{
			float3 pos0 = mul(o2w,v0).xyz;
			float3 pos1 = mul(o2w,v1).xyz;
			float3 pos2 = mul(o2w,v2).xyz;
			float4 tess;

			if (WorldViewFrustumCull(pos0, pos1, pos2, maxDisplacement, planes))
			{
				tess = 0.0f;
			}
			else
			{
				tess.x = CalcEdgeTessFactor (pos1, pos2, edgeLength, cameraPos, scParams);
				tess.y = CalcEdgeTessFactor (pos2, pos0, edgeLength, cameraPos, scParams);
				tess.z = CalcEdgeTessFactor (pos0, pos1, edgeLength, cameraPos, scParams);
				tess.w = (tess.x + tess.y + tess.z) / 3.0f;
			}
			return tess;
		}
		#endif //ASE_TESS_FUNCS
		ENDHLSL

		
		Pass
		{
			
			Name "Forward"
			Tags { "LightMode"="UniversalForward" }

			Blend One Zero, One Zero
			ZWrite On
			ZTest LEqual
			Offset 0 , 0
			ColorMask RGBA

			

			HLSLPROGRAM

			#pragma multi_compile_instancing
			#define ASE_SRP_VERSION 101001


			#pragma vertex vert
			#pragma fragment frag

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

			

			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					float3 worldPos : TEXCOORD0;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					float4 shadowCoord : TEXCOORD1;
				#endif
				#ifdef ASE_FOG
					float fogFactor : TEXCOORD2;
				#endif
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _TerrainMask_VertexPaint_ST;
			float _T1_Tiling1;
			float _T1_ProceduralTiling1;
			float _GrayscaleDebug;
			float _VertexPaintDebug;
			float _T2_Tilling1;
			float _T2_ProceduralTiling1;
			float _T3_Tilling1;
			float _T3_ProceduralTiling1;
			float _T4_Tilling1;
			float _T4_ProceduralTiling1;
			float _DesaturateMapDebug;
			float _DebugVertexPaintingAdding;
			float _NormalDebug;
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			sampler2D _T1_Terrain;
			sampler2D _T2_Terrain;
			sampler2D _TerrainMask_VertexPaint;
			sampler2D _T3_Terrain;
			sampler2D _T4_Terrain;
			sampler2D _T1_TerrainNAOH;
			sampler2D _T2_TerrainNAOH;
			sampler2D _T3_TerrainNAOH;
			sampler2D _T4_TerrainNAOH;


			void StochasticTiling( float2 UV, out float2 UV1, out float2 UV2, out float2 UV3, out float W1, out float W2, out float W3 )
			{
				float2 vertex1, vertex2, vertex3;
				// Scaling of the input
				float2 uv = UV * 3.464; // 2 * sqrt (3)
				// Skew input space into simplex triangle grid
				const float2x2 gridToSkewedGrid = float2x2( 1.0, 0.0, -0.57735027, 1.15470054 );
				float2 skewedCoord = mul( gridToSkewedGrid, uv );
				// Compute local triangle vertex IDs and local barycentric coordinates
				int2 baseId = int2( floor( skewedCoord ) );
				float3 temp = float3( frac( skewedCoord ), 0 );
				temp.z = 1.0 - temp.x - temp.y;
				if ( temp.z > 0.0 )
				{
					W1 = temp.z;
					W2 = temp.y;
					W3 = temp.x;
					vertex1 = baseId;
					vertex2 = baseId + int2( 0, 1 );
					vertex3 = baseId + int2( 1, 0 );
				}
				else
				{
					W1 = -temp.z;
					W2 = 1.0 - temp.y;
					W3 = 1.0 - temp.x;
					vertex1 = baseId + int2( 1, 1 );
					vertex2 = baseId + int2( 1, 0 );
					vertex3 = baseId + int2( 0, 1 );
				}
				UV1 = UV + frac( sin( mul( float2x2( 127.1, 311.7, 269.5, 183.3 ), vertex1 ) ) * 43758.5453 );
				UV2 = UV + frac( sin( mul( float2x2( 127.1, 311.7, 269.5, 183.3 ), vertex2 ) ) * 43758.5453 );
				UV3 = UV + frac( sin( mul( float2x2( 127.1, 311.7, 269.5, 183.3 ), vertex3 ) ) * 43758.5453 );
				return;
			}
			

			VertexOutput VertexFunction ( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				o.ase_texcoord3.xy = v.ase_texcoord.xy;
				o.ase_color = v.ase_color;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord3.zw = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = defaultVertexValue;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				float4 positionCS = TransformWorldToHClip( positionWS );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					o.worldPos = positionWS;
				#endif

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = positionCS;
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif

				#ifdef ASE_FOG
					o.fogFactor = ComputeFogFactor( positionCS.z );
				#endif

				o.clipPos = positionCS;

				return o;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_color : COLOR;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_texcoord = v.ase_texcoord;
				o.ase_color = v.ase_color;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
			   return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				o.ase_color = patch[0].ase_color * bary.x + patch[1].ase_color * bary.y + patch[2].ase_color * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag ( VertexOutput IN  ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					float3 WorldPosition = IN.worldPos;
				#endif

				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif

				float T1_Tiling361 = _T1_Tiling1;
				float2 temp_cast_0 = (T1_Tiling361).xx;
				float2 texCoord61 = IN.ase_texcoord3.xy * temp_cast_0 + float2( 0,0 );
				float localStochasticTiling2_g14 = ( 0.0 );
				float2 Input_UV145_g14 = texCoord61;
				float2 UV2_g14 = Input_UV145_g14;
				float2 UV12_g14 = float2( 0,0 );
				float2 UV22_g14 = float2( 0,0 );
				float2 UV32_g14 = float2( 0,0 );
				float W12_g14 = 0.0;
				float W22_g14 = 0.0;
				float W32_g14 = 0.0;
				StochasticTiling( UV2_g14 , UV12_g14 , UV22_g14 , UV32_g14 , W12_g14 , W22_g14 , W32_g14 );
				float2 temp_output_10_0_g14 = ddx( Input_UV145_g14 );
				float2 temp_output_12_0_g14 = ddy( Input_UV145_g14 );
				float4 Output_2D293_g14 = ( ( tex2D( _T1_Terrain, UV12_g14, temp_output_10_0_g14, temp_output_12_0_g14 ) * W12_g14 ) + ( tex2D( _T1_Terrain, UV22_g14, temp_output_10_0_g14, temp_output_12_0_g14 ) * W22_g14 ) + ( tex2D( _T1_Terrain, UV32_g14, temp_output_10_0_g14, temp_output_12_0_g14 ) * W32_g14 ) );
				float T1_ProceduralTiling362 = _T1_ProceduralTiling1;
				float4 lerpResult64 = lerp( tex2D( _T1_Terrain, texCoord61 ) , Output_2D293_g14 , T1_ProceduralTiling362);
				float4 temp_output_66_0 = ( lerpResult64 * 1.0 );
				float grayscale68 = Luminance(temp_output_66_0.rgb);
				float4 temp_cast_2 = (grayscale68).xxxx;
				float DebugGrayscale45 = _GrayscaleDebug;
				float4 lerpResult69 = lerp( temp_output_66_0 , temp_cast_2 , DebugGrayscale45);
				float4 T1_RGB71 = lerpResult69;
				float4 color50 = IsGammaSpace() ? float4(0,0,0,0) : float4(0,0,0,0);
				float4 DebugColor151 = color50;
				float DebugVertexPainting46 = _VertexPaintDebug;
				float4 lerpResult147 = lerp( T1_RGB71 , DebugColor151 , DebugVertexPainting46);
				float T2_Tilling363 = _T2_Tilling1;
				float2 temp_cast_3 = (T2_Tilling363).xx;
				float2 texCoord104 = IN.ase_texcoord3.xy * temp_cast_3 + float2( 0,0 );
				float localStochasticTiling2_g17 = ( 0.0 );
				float2 Input_UV145_g17 = texCoord104;
				float2 UV2_g17 = Input_UV145_g17;
				float2 UV12_g17 = float2( 0,0 );
				float2 UV22_g17 = float2( 0,0 );
				float2 UV32_g17 = float2( 0,0 );
				float W12_g17 = 0.0;
				float W22_g17 = 0.0;
				float W32_g17 = 0.0;
				StochasticTiling( UV2_g17 , UV12_g17 , UV22_g17 , UV32_g17 , W12_g17 , W22_g17 , W32_g17 );
				float2 temp_output_10_0_g17 = ddx( Input_UV145_g17 );
				float2 temp_output_12_0_g17 = ddy( Input_UV145_g17 );
				float4 Output_2D293_g17 = ( ( tex2D( _T2_Terrain, UV12_g17, temp_output_10_0_g17, temp_output_12_0_g17 ) * W12_g17 ) + ( tex2D( _T2_Terrain, UV22_g17, temp_output_10_0_g17, temp_output_12_0_g17 ) * W22_g17 ) + ( tex2D( _T2_Terrain, UV32_g17, temp_output_10_0_g17, temp_output_12_0_g17 ) * W32_g17 ) );
				float T2_ProceduralTiling364 = _T2_ProceduralTiling1;
				float4 lerpResult111 = lerp( tex2D( _T2_Terrain, texCoord104 ) , Output_2D293_g17 , T2_ProceduralTiling364);
				float4 temp_output_110_0 = ( lerpResult111 * 1.0 );
				float grayscale109 = Luminance(temp_output_110_0.rgb);
				float4 temp_cast_5 = (grayscale109).xxxx;
				float4 lerpResult113 = lerp( temp_output_110_0 , temp_cast_5 , DebugGrayscale45);
				float4 T2_RGB114 = lerpResult113;
				float4 color53 = IsGammaSpace() ? float4(1,0,0.03653574,0) : float4(1,0,0.002827844,0);
				float4 DebugColor252 = color53;
				float4 lerpResult151 = lerp( T2_RGB114 , DebugColor252 , DebugVertexPainting46);
				float2 uv_TerrainMask_VertexPaint = IN.ase_texcoord3.xy * _TerrainMask_VertexPaint_ST.xy + _TerrainMask_VertexPaint_ST.zw;
				float4 tex2DNode166 = tex2D( _TerrainMask_VertexPaint, uv_TerrainMask_VertexPaint );
				float4 lerpResult150 = lerp( lerpResult147 , lerpResult151 , ( tex2DNode166.r * 2.0 ));
				float T3_Tilling365 = _T3_Tilling1;
				float2 temp_cast_6 = (T3_Tilling365).xx;
				float2 texCoord118 = IN.ase_texcoord3.xy * temp_cast_6 + float2( 0,0 );
				float localStochasticTiling2_g16 = ( 0.0 );
				float2 Input_UV145_g16 = texCoord118;
				float2 UV2_g16 = Input_UV145_g16;
				float2 UV12_g16 = float2( 0,0 );
				float2 UV22_g16 = float2( 0,0 );
				float2 UV32_g16 = float2( 0,0 );
				float W12_g16 = 0.0;
				float W22_g16 = 0.0;
				float W32_g16 = 0.0;
				StochasticTiling( UV2_g16 , UV12_g16 , UV22_g16 , UV32_g16 , W12_g16 , W22_g16 , W32_g16 );
				float2 temp_output_10_0_g16 = ddx( Input_UV145_g16 );
				float2 temp_output_12_0_g16 = ddy( Input_UV145_g16 );
				float4 Output_2D293_g16 = ( ( tex2D( _T3_Terrain, UV12_g16, temp_output_10_0_g16, temp_output_12_0_g16 ) * W12_g16 ) + ( tex2D( _T3_Terrain, UV22_g16, temp_output_10_0_g16, temp_output_12_0_g16 ) * W22_g16 ) + ( tex2D( _T3_Terrain, UV32_g16, temp_output_10_0_g16, temp_output_12_0_g16 ) * W32_g16 ) );
				float T3_ProceduralTiling366 = _T3_ProceduralTiling1;
				float4 lerpResult124 = lerp( tex2D( _T3_Terrain, texCoord118 ) , Output_2D293_g16 , T3_ProceduralTiling366);
				float4 temp_output_123_0 = ( lerpResult124 * 1.0 );
				float grayscale122 = Luminance(temp_output_123_0.rgb);
				float4 temp_cast_8 = (grayscale122).xxxx;
				float4 lerpResult126 = lerp( temp_output_123_0 , temp_cast_8 , DebugGrayscale45);
				float4 T3_RGB130 = lerpResult126;
				float4 color55 = IsGammaSpace() ? float4(0,1,0.002223969,0) : float4(0,1,0.0001721338,0);
				float4 DebugColor354 = color55;
				float4 lerpResult157 = lerp( T3_RGB130 , DebugColor354 , DebugVertexPainting46);
				float4 lerpResult155 = lerp( lerpResult150 , lerpResult157 , ( tex2DNode166.g * 2.0 ));
				float T4_Tilling368 = _T4_Tilling1;
				float2 temp_cast_9 = (T4_Tilling368).xx;
				float2 texCoord132 = IN.ase_texcoord3.xy * temp_cast_9 + float2( 0,0 );
				float localStochasticTiling2_g15 = ( 0.0 );
				float2 Input_UV145_g15 = texCoord132;
				float2 UV2_g15 = Input_UV145_g15;
				float2 UV12_g15 = float2( 0,0 );
				float2 UV22_g15 = float2( 0,0 );
				float2 UV32_g15 = float2( 0,0 );
				float W12_g15 = 0.0;
				float W22_g15 = 0.0;
				float W32_g15 = 0.0;
				StochasticTiling( UV2_g15 , UV12_g15 , UV22_g15 , UV32_g15 , W12_g15 , W22_g15 , W32_g15 );
				float2 temp_output_10_0_g15 = ddx( Input_UV145_g15 );
				float2 temp_output_12_0_g15 = ddy( Input_UV145_g15 );
				float4 Output_2D293_g15 = ( ( tex2D( _T4_Terrain, UV12_g15, temp_output_10_0_g15, temp_output_12_0_g15 ) * W12_g15 ) + ( tex2D( _T4_Terrain, UV22_g15, temp_output_10_0_g15, temp_output_12_0_g15 ) * W22_g15 ) + ( tex2D( _T4_Terrain, UV32_g15, temp_output_10_0_g15, temp_output_12_0_g15 ) * W32_g15 ) );
				float T4_ProceduralTiling367 = _T4_ProceduralTiling1;
				float4 lerpResult137 = lerp( tex2D( _T4_Terrain, texCoord132 ) , Output_2D293_g15 , T4_ProceduralTiling367);
				float4 temp_output_136_0 = ( lerpResult137 * 1.0 );
				float grayscale135 = Luminance(temp_output_136_0.rgb);
				float4 temp_cast_11 = (grayscale135).xxxx;
				float4 lerpResult139 = lerp( temp_output_136_0 , temp_cast_11 , DebugGrayscale45);
				float4 T4_RGB144 = lerpResult139;
				float4 color56 = IsGammaSpace() ? float4(0.00126791,0,1,0) : float4(9.813545E-05,0,1,0);
				float4 DebugColor457 = color56;
				float4 lerpResult161 = lerp( T4_RGB144 , DebugColor457 , DebugVertexPainting46);
				float4 lerpResult165 = lerp( lerpResult155 , lerpResult161 , ( tex2DNode166.b * 2.0 ));
				float DebugDesaturateMap410 = _DesaturateMapDebug;
				float3 desaturateInitialColor415 = lerpResult165.rgb;
				float desaturateDot415 = dot( desaturateInitialColor415, float3( 0.299, 0.587, 0.114 ));
				float3 desaturateVar415 = lerp( desaturateInitialColor415, desaturateDot415.xxx, DebugDesaturateMap410 );
				float3 AllAlbedoCombined168 = desaturateVar415;
				float4 break187 = saturate( ( IN.ase_color * 2.0 ) );
				float3 desaturateInitialColor417 = max( max( max( ( T1_RGB71 * ( 1.0 - saturate( ( ( break187.r + break187.g ) + break187.b ) ) ) ) , ( break187.r * T2_RGB114 ) ) , ( break187.g * T3_RGB130 ) ) , ( break187.b * T4_RGB144 ) ).rgb;
				float desaturateDot417 = dot( desaturateInitialColor417, float3( 0.299, 0.587, 0.114 ));
				float3 desaturateVar417 = lerp( desaturateInitialColor417, desaturateDot417.xxx, DebugDesaturateMap410 );
				float3 AllAlbedoVertexPaint208 = desaturateVar417;
				float3 blendOpSrc254 = AllAlbedoCombined168;
				float3 blendOpDest254 = AllAlbedoVertexPaint208;
				float3 lerpResult215 = lerp( AllAlbedoCombined168 , (( blendOpDest254 > 0.5 ) ? ( 1.0 - 2.0 * ( 1.0 - blendOpDest254 ) * ( 1.0 - blendOpSrc254 ) ) : ( 2.0 * blendOpDest254 * blendOpSrc254 ) ) , _DebugVertexPaintingAdding);
				float localStochasticTiling2_g10 = ( 0.0 );
				float2 temp_cast_15 = (T1_Tiling361).xx;
				float2 texCoord257 = IN.ase_texcoord3.xy * temp_cast_15 + float2( 0,0 );
				float2 Input_UV145_g10 = texCoord257;
				float2 UV2_g10 = Input_UV145_g10;
				float2 UV12_g10 = float2( 0,0 );
				float2 UV22_g10 = float2( 0,0 );
				float2 UV32_g10 = float2( 0,0 );
				float W12_g10 = 0.0;
				float W22_g10 = 0.0;
				float W32_g10 = 0.0;
				StochasticTiling( UV2_g10 , UV12_g10 , UV22_g10 , UV32_g10 , W12_g10 , W22_g10 , W32_g10 );
				float2 temp_output_10_0_g10 = ddx( Input_UV145_g10 );
				float2 temp_output_12_0_g10 = ddy( Input_UV145_g10 );
				float4 Output_2D293_g10 = ( ( tex2D( _T1_TerrainNAOH, UV12_g10, temp_output_10_0_g10, temp_output_12_0_g10 ) * W12_g10 ) + ( tex2D( _T1_TerrainNAOH, UV22_g10, temp_output_10_0_g10, temp_output_12_0_g10 ) * W22_g10 ) + ( tex2D( _T1_TerrainNAOH, UV32_g10, temp_output_10_0_g10, temp_output_12_0_g10 ) * W32_g10 ) );
				float4 lerpResult260 = lerp( Output_2D293_g10 , tex2D( _T1_TerrainNAOH, texCoord257 ) , T1_ProceduralTiling362);
				float4 T1_NAOH262 = lerpResult260;
				float localStochasticTiling2_g11 = ( 0.0 );
				float2 temp_cast_16 = (T2_Tilling363).xx;
				float2 texCoord274 = IN.ase_texcoord3.xy * temp_cast_16 + float2( 0,0 );
				float2 Input_UV145_g11 = texCoord274;
				float2 UV2_g11 = Input_UV145_g11;
				float2 UV12_g11 = float2( 0,0 );
				float2 UV22_g11 = float2( 0,0 );
				float2 UV32_g11 = float2( 0,0 );
				float W12_g11 = 0.0;
				float W22_g11 = 0.0;
				float W32_g11 = 0.0;
				StochasticTiling( UV2_g11 , UV12_g11 , UV22_g11 , UV32_g11 , W12_g11 , W22_g11 , W32_g11 );
				float2 temp_output_10_0_g11 = ddx( Input_UV145_g11 );
				float2 temp_output_12_0_g11 = ddy( Input_UV145_g11 );
				float4 Output_2D293_g11 = ( ( tex2D( _T2_TerrainNAOH, UV12_g11, temp_output_10_0_g11, temp_output_12_0_g11 ) * W12_g11 ) + ( tex2D( _T2_TerrainNAOH, UV22_g11, temp_output_10_0_g11, temp_output_12_0_g11 ) * W22_g11 ) + ( tex2D( _T2_TerrainNAOH, UV32_g11, temp_output_10_0_g11, temp_output_12_0_g11 ) * W32_g11 ) );
				float4 lerpResult267 = lerp( Output_2D293_g11 , tex2D( _T2_TerrainNAOH, texCoord274 ) , T2_ProceduralTiling364);
				float4 T2_NAOH268 = lerpResult267;
				float4 tex2DNode322 = tex2D( _TerrainMask_VertexPaint, uv_TerrainMask_VertexPaint );
				float4 lerpResult327 = lerp( T1_NAOH262 , T2_NAOH268 , ( tex2DNode322.r * 2.0 ));
				float localStochasticTiling2_g12 = ( 0.0 );
				float2 temp_cast_17 = (T3_Tilling365).xx;
				float2 texCoord287 = IN.ase_texcoord3.xy * temp_cast_17 + float2( 0,0 );
				float2 Input_UV145_g12 = texCoord287;
				float2 UV2_g12 = Input_UV145_g12;
				float2 UV12_g12 = float2( 0,0 );
				float2 UV22_g12 = float2( 0,0 );
				float2 UV32_g12 = float2( 0,0 );
				float W12_g12 = 0.0;
				float W22_g12 = 0.0;
				float W32_g12 = 0.0;
				StochasticTiling( UV2_g12 , UV12_g12 , UV22_g12 , UV32_g12 , W12_g12 , W22_g12 , W32_g12 );
				float2 temp_output_10_0_g12 = ddx( Input_UV145_g12 );
				float2 temp_output_12_0_g12 = ddy( Input_UV145_g12 );
				float4 Output_2D293_g12 = ( ( tex2D( _T3_TerrainNAOH, UV12_g12, temp_output_10_0_g12, temp_output_12_0_g12 ) * W12_g12 ) + ( tex2D( _T3_TerrainNAOH, UV22_g12, temp_output_10_0_g12, temp_output_12_0_g12 ) * W22_g12 ) + ( tex2D( _T3_TerrainNAOH, UV32_g12, temp_output_10_0_g12, temp_output_12_0_g12 ) * W32_g12 ) );
				float4 lerpResult281 = lerp( Output_2D293_g12 , tex2D( _T3_TerrainNAOH, texCoord287 ) , T3_ProceduralTiling366);
				float4 T3_NAOH305 = lerpResult281;
				float4 lerpResult311 = lerp( lerpResult327 , T3_NAOH305 , ( tex2DNode322.g * 2.0 ));
				float localStochasticTiling2_g13 = ( 0.0 );
				float2 temp_cast_18 = (T4_Tilling368).xx;
				float2 texCoord296 = IN.ase_texcoord3.xy * temp_cast_18 + float2( 0,0 );
				float2 Input_UV145_g13 = texCoord296;
				float2 UV2_g13 = Input_UV145_g13;
				float2 UV12_g13 = float2( 0,0 );
				float2 UV22_g13 = float2( 0,0 );
				float2 UV32_g13 = float2( 0,0 );
				float W12_g13 = 0.0;
				float W22_g13 = 0.0;
				float W32_g13 = 0.0;
				StochasticTiling( UV2_g13 , UV12_g13 , UV22_g13 , UV32_g13 , W12_g13 , W22_g13 , W32_g13 );
				float2 temp_output_10_0_g13 = ddx( Input_UV145_g13 );
				float2 temp_output_12_0_g13 = ddy( Input_UV145_g13 );
				float4 Output_2D293_g13 = ( ( tex2D( _T4_TerrainNAOH, UV12_g13, temp_output_10_0_g13, temp_output_12_0_g13 ) * W12_g13 ) + ( tex2D( _T4_TerrainNAOH, UV22_g13, temp_output_10_0_g13, temp_output_12_0_g13 ) * W22_g13 ) + ( tex2D( _T4_TerrainNAOH, UV32_g13, temp_output_10_0_g13, temp_output_12_0_g13 ) * W32_g13 ) );
				float4 lerpResult294 = lerp( Output_2D293_g13 , tex2D( _T4_TerrainNAOH, texCoord296 ) , T4_ProceduralTiling367);
				float4 T4_NAOH306 = lerpResult294;
				float4 lerpResult320 = lerp( lerpResult311 , T4_NAOH306 , ( tex2DNode322.b * 2.0 ));
				float4 AllNormal_Combined321 = lerpResult320;
				float DebugNormal43 = _NormalDebug;
				float4 lerpResult348 = lerp( float4( lerpResult215 , 0.0 ) , AllNormal_Combined321 , DebugNormal43);
				
				float3 BakedAlbedo = 0;
				float3 BakedEmission = 0;
				float3 Color = lerpResult348.rgb;
				float Alpha = 1;
				float AlphaClipThreshold = 0.5;
				float AlphaClipThresholdShadow = 0.5;

				#ifdef _ALPHATEST_ON
					clip( Alpha - AlphaClipThreshold );
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif

				#ifdef ASE_FOG
					Color = MixFog( Color, IN.fogFactor );
				#endif

				return half4( Color, Alpha );
			}
			ENDHLSL
		}

		
		Pass
		{
			
			Name "ShadowCaster"
			Tags { "LightMode"="ShadowCaster" }

			ZWrite On
			ZTest LEqual
			AlphaToMask Off
			ColorMask 0

			HLSLPROGRAM

			#pragma multi_compile_instancing
			#define ASE_SRP_VERSION 101001


			#pragma vertex vert
			#pragma fragment frag

			

			#define SHADERPASS SHADERPASS_SHADOWCASTER

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

			

			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					float3 worldPos : TEXCOORD0;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					float4 shadowCoord : TEXCOORD1;
				#endif
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _TerrainMask_VertexPaint_ST;
			float _T1_Tiling1;
			float _T1_ProceduralTiling1;
			float _GrayscaleDebug;
			float _VertexPaintDebug;
			float _T2_Tilling1;
			float _T2_ProceduralTiling1;
			float _T3_Tilling1;
			float _T3_ProceduralTiling1;
			float _T4_Tilling1;
			float _T4_ProceduralTiling1;
			float _DesaturateMapDebug;
			float _DebugVertexPaintingAdding;
			float _NormalDebug;
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			

			
			float3 _LightDirection;
			#if ASE_SRP_VERSION >= 110000
				float3 _LightPosition;
			#endif

			VertexOutput VertexFunction( VertexInput v )
			{
				VertexOutput o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );

				

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = defaultVertexValue;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					o.worldPos = positionWS;
				#endif

				float3 normalWS = TransformObjectToWorldDir( v.ase_normal );

				#if ASE_SRP_VERSION >= 110000
					#if _CASTING_PUNCTUAL_LIGHT_SHADOW
						float3 lightDirectionWS = normalize(_LightPosition - positionWS);
					#else
						float3 lightDirectionWS = _LightDirection;
					#endif

					float4 clipPos = TransformWorldToHClip(ApplyShadowBias(positionWS, normalWS, lightDirectionWS));

					#if UNITY_REVERSED_Z
						clipPos.z = min(clipPos.z, UNITY_NEAR_CLIP_VALUE);
					#else
						clipPos.z = max(clipPos.z, UNITY_NEAR_CLIP_VALUE);
					#endif
				#else
					float4 clipPos = TransformWorldToHClip( ApplyShadowBias( positionWS, normalWS, _LightDirection ) );

					#if UNITY_REVERSED_Z
						clipPos.z = min(clipPos.z, clipPos.w * UNITY_NEAR_CLIP_VALUE);
					#else
						clipPos.z = max(clipPos.z, clipPos.w * UNITY_NEAR_CLIP_VALUE);
					#endif
				#endif

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = clipPos;
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif

				o.clipPos = clipPos;

				return o;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
			   return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag(VertexOutput IN  ) : SV_TARGET
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					float3 WorldPosition = IN.worldPos;
				#endif

				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif

				

				float Alpha = 1;
				float AlphaClipThreshold = 0.5;
				float AlphaClipThresholdShadow = 0.5;

				#ifdef _ALPHATEST_ON
					#ifdef _ALPHATEST_SHADOW_ON
						clip(Alpha - AlphaClipThresholdShadow);
					#else
						clip(Alpha - AlphaClipThreshold);
					#endif
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif
				return 0;
			}
			ENDHLSL
		}

		
		Pass
		{
			
			Name "DepthOnly"
			Tags { "LightMode"="DepthOnly" }

			ZWrite On
			ColorMask 0
			AlphaToMask Off

			HLSLPROGRAM

			#pragma multi_compile_instancing
			#define ASE_SRP_VERSION 101001


			#pragma vertex vert
			#pragma fragment frag

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

			

			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 worldPos : TEXCOORD0;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				float4 shadowCoord : TEXCOORD1;
				#endif
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _TerrainMask_VertexPaint_ST;
			float _T1_Tiling1;
			float _T1_ProceduralTiling1;
			float _GrayscaleDebug;
			float _VertexPaintDebug;
			float _T2_Tilling1;
			float _T2_ProceduralTiling1;
			float _T3_Tilling1;
			float _T3_ProceduralTiling1;
			float _T4_Tilling1;
			float _T4_ProceduralTiling1;
			float _DesaturateMapDebug;
			float _DebugVertexPaintingAdding;
			float _NormalDebug;
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			

			
			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = defaultVertexValue;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					o.worldPos = positionWS;
				#endif

				o.clipPos = TransformWorldToHClip( positionWS );
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = o.clipPos;
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif

				return o;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
			   return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag(VertexOutput IN  ) : SV_TARGET
			{
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					float3 WorldPosition = IN.worldPos;
				#endif

				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif

				

				float Alpha = 1;
				float AlphaClipThreshold = 0.5;

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif
				return 0;
			}
			ENDHLSL
		}

	
	}
	
	CustomEditor "UnityEditor.ShaderGraphUnlitGUI"
	Fallback "Hidden/InternalErrorShader"
	
}
/*ASEBEGIN
Version=19102
Node;AmplifyShaderEditor.CommentaryNode;145;-7576.235,1189.608;Inherit;False;1504.598;1472.612;Other Parameters;3;41;48;369;;0,0,0,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;369;-6813.206,1239.094;Inherit;False;641.2139;744.564;Tiling Controller Texture;16;361;362;363;364;365;366;367;368;353;355;356;354;358;357;360;359;;1,0,0,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;308;-4274,-2482;Inherit;False;3709.769;2808;Texture RGBA;8;72;16;23;29;35;102;117;131;;1,0.4661931,0,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;307;-7498.852,-2491.554;Inherit;False;3081.05;2439.487;NAOH NormalMap Ambiant Occlusion Height;8;264;171;265;266;279;280;292;293;;0.1278601,0.1179245,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;264;-6154.443,-2441.554;Inherit;False;1683.34;546.8347;NAOH Texture 1;8;255;257;259;256;260;262;378;379;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;245;-2928.581,1573.241;Inherit;False;2608.714;828.0642;Vertex Painting;23;418;417;208;198;191;196;200;190;188;197;195;193;206;199;194;205;204;203;201;202;189;187;186;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;169;-2928,352;Inherit;False;2162.044;1179.899;Texture Set By Vertex Color;26;168;164;163;162;400;401;402;166;160;152;153;151;150;149;146;148;147;165;159;158;161;157;155;154;415;416;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;72;-2944,-2432;Inherit;False;2313.769;659.8782;Albedo Texture 1;13;58;61;59;63;67;68;66;64;70;69;71;376;399;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;48;-7528.01,1837.015;Inherit;False;641.4331;792.4948;Debug Vertex Color;8;57;54;52;51;56;55;53;50;;0.571486,0,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;41;-7522.855,1235.608;Inherit;False;634;565;Debug Variables;10;44;47;42;409;411;45;46;43;410;412;;0.5367103,0,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;16;-4224,-2432;Inherit;False;1202;443;Textures Terrain 1;5;10;11;12;15;22;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;23;-4208,-1744;Inherit;False;1202;443;Textures Terrain 2;5;28;26;25;24;27;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;29;-4208,-1024;Inherit;False;1202;443;Textures Terrain 3;5;34;33;32;31;30;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;35;-4224,-336;Inherit;False;1202;443;Textures Terrain 4;5;40;39;38;37;36;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;102;-2944,-1744;Inherit;False;2313.769;659.8782;Albedo Texture 2;13;113;112;111;110;109;108;106;105;104;103;114;374;375;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;117;-2928,-1040;Inherit;False;2313.769;659.8782;Albedo Texture 2;13;130;129;127;126;125;124;123;122;121;119;118;372;373;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;131;-2944,-336;Inherit;False;2313.769;659.8782;Albedo Texture 2;13;144;141;140;139;138;137;136;135;134;133;132;370;371;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;171;-7440.185,-2439.427;Inherit;False;1202;443;Textures Terrain NAOH 1;4;175;174;173;172;;1,1,1,1;0;0
Node;AmplifyShaderEditor.StickyNoteNode;181;-2917.163,-2896.279;Inherit;False;567.8623;332.1456;A demande au GA;;1,1,1,1;Demander les maps dont ils ont besoin pour pouvoir préparer le packing$;0;0
Node;AmplifyShaderEditor.SaturateNode;186;-2543.889,2054.815;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.BreakToComponentsNode;187;-2393.889,2053.815;Inherit;False;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;189;-2699.58,2055.539;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;202;-2029.905,1725.783;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;201;-2223.903,1724.783;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;203;-1856.029,1726.228;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;204;-1675.029,1725.228;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;205;-1465.029,1700.228;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;194;-1006.874,2155.306;Inherit;False;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;199;-1159.904,2026.783;Inherit;False;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;206;-1391.029,1961.228;Inherit;False;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;193;-1404.656,2238.725;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;195;-1527.656,2107.725;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;197;-1787.242,1978.011;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.VertexColorNode;188;-2878.581,2058.539;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;190;-2856.58,2250.54;Inherit;False;Constant;_Float4;Float 0;0;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;265;-6151.142,-1833.533;Inherit;False;1683.34;546.8347;NAOH Texture 2;8;277;274;273;268;267;276;380;381;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;266;-7436.889,-1831.406;Inherit;False;1202;443;Textures Terrain NAOH 2;4;272;271;270;269;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;279;-6163.107,-1206.923;Inherit;False;1683.34;546.8347;NAOH Texture 1;8;305;290;289;287;286;281;382;383;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;280;-7448.852,-1204.796;Inherit;False;1202;443;Textures Terrain NAOH 3;4;285;284;283;282;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;292;-6159.807,-598.9022;Inherit;False;1683.34;546.8347;NAOH Texture 2;8;306;304;299;298;296;294;384;385;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;293;-7445.556,-596.7753;Inherit;False;1202;443;Textures Terrain NAOH 2;4;303;302;301;295;;1,1,1,1;0;0
Node;AmplifyShaderEditor.LerpOp;260;-4908.784,-2384.201;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;174;-6880.184,-2375.427;Inherit;True;Property;_T_1_TextureSample1;T_1_Texture Sample;1;0;Create;True;0;0;0;False;0;False;10;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexturePropertyNode;173;-7392.185,-2375.427;Inherit;True;Property;_T1_TerrainNAOH;T1_Terrain NAOH;8;0;Create;True;0;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RegisterLocalVarNode;175;-7104.185,-2375.427;Inherit;False;T1_NAOH_Textures;-1;True;1;0;SAMPLER2D;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.GetLocalVarNode;255;-6064.195,-2391.554;Inherit;False;175;T1_NAOH_Textures;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;257;-5806.444,-2256.719;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;259;-5548.443,-2124.719;Inherit;True;Property;_TextureSample28;Texture Sample 24;7;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;256;-5545.709,-2385.979;Inherit;False;Procedural Sample;-1;;10;f5379ff72769e2b4495e5ce2f004d8d4;2,157,0,315,0;7;82;SAMPLER2D;0;False;158;SAMPLER2DARRAY;0;False;183;FLOAT;0;False;5;FLOAT2;0,0;False;80;FLOAT3;0,0,0;False;104;FLOAT2;1,1;False;74;SAMPLERSTATE;0;False;5;COLOR;0;FLOAT;32;FLOAT;33;FLOAT;34;FLOAT;35
Node;AmplifyShaderEditor.LerpOp;267;-4905.483,-1776.179;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;274;-5803.143,-1648.698;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;277;-5542.408,-1777.958;Inherit;False;Procedural Sample;-1;;11;f5379ff72769e2b4495e5ce2f004d8d4;2,157,0,315,0;7;82;SAMPLER2D;0;False;158;SAMPLER2DARRAY;0;False;183;FLOAT;0;False;5;FLOAT2;0,0;False;80;FLOAT3;0,0,0;False;104;FLOAT2;1,1;False;74;SAMPLERSTATE;0;False;5;COLOR;0;FLOAT;32;FLOAT;33;FLOAT;34;FLOAT;35
Node;AmplifyShaderEditor.TexturePropertyNode;271;-7388.889,-1767.406;Inherit;True;Property;_T2_TerrainNAOH;T2_Terrain NAOH;12;0;Create;True;0;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SamplerNode;270;-6876.883,-1767.406;Inherit;True;Property;_T_2__NAOH_TextureSample;T_2__NAOH_Texture Sample;1;0;Create;True;0;0;0;False;0;False;10;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;272;-7100.887,-1767.406;Inherit;False;T2_NAOH_Textures;-1;True;1;0;SAMPLER2D;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.GetLocalVarNode;273;-6060.894,-1783.533;Inherit;False;272;T2_NAOH_Textures;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;262;-4695.102,-2390.745;Inherit;False;T1_NAOH;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;268;-4691.801,-1782.724;Inherit;False;T2_NAOH;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;281;-4917.449,-1149.569;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;282;-7384.852,-932.7963;Inherit;False;0;10;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;283;-6888.849,-1140.796;Inherit;True;Property;_T__TextureSample2;T_1_Texture Sample;1;0;Create;True;0;0;0;False;0;False;10;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;287;-5815.108,-1022.088;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;289;-5557.107,-890.0883;Inherit;True;Property;_TextureSample30;Texture Sample 24;7;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;290;-5554.374,-1151.348;Inherit;False;Procedural Sample;-1;;12;f5379ff72769e2b4495e5ce2f004d8d4;2,157,0,315,0;7;82;SAMPLER2D;0;False;158;SAMPLER2DARRAY;0;False;183;FLOAT;0;False;5;FLOAT2;0,0;False;80;FLOAT3;0,0,0;False;104;FLOAT2;1,1;False;74;SAMPLERSTATE;0;False;5;COLOR;0;FLOAT;32;FLOAT;33;FLOAT;34;FLOAT;35
Node;AmplifyShaderEditor.LerpOp;294;-4914.147,-541.5482;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;295;-7381.556,-324.7751;Inherit;False;0;10;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;296;-5811.808,-414.0672;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;298;-5553.807,-282.067;Inherit;True;Property;_TextureSample31;Texture Sample 24;7;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;299;-5551.073,-543.3273;Inherit;False;Procedural Sample;-1;;13;f5379ff72769e2b4495e5ce2f004d8d4;2,157,0,315,0;7;82;SAMPLER2D;0;False;158;SAMPLER2DARRAY;0;False;183;FLOAT;0;False;5;FLOAT2;0,0;False;80;FLOAT3;0,0,0;False;104;FLOAT2;1,1;False;74;SAMPLERSTATE;0;False;5;COLOR;0;FLOAT;32;FLOAT;33;FLOAT;34;FLOAT;35
Node;AmplifyShaderEditor.SamplerNode;302;-6885.547,-532.7753;Inherit;True;Property;_T_4__NAOH_TextureSample;T_4__NAOH_Texture Sample;1;0;Create;True;0;0;0;False;0;False;10;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;269;-7380.492,-1563.958;Inherit;False;0;10;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;276;-5551.225,-1574.465;Inherit;True;Property;_TextureSample29;Texture Sample 24;7;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;285;-7112.852,-1140.796;Inherit;False;T3_NAOH_Textures;-1;True;1;0;SAMPLER2D;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.TexturePropertyNode;284;-7400.852,-1140.796;Inherit;True;Property;_T3_TerrainNAOH;T3_Terrain NAOH;16;0;Create;True;0;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.TexturePropertyNode;301;-7397.556,-532.7753;Inherit;True;Property;_T4_TerrainNAOH;T4_Terrain NAOH;20;0;Create;True;0;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RegisterLocalVarNode;303;-7109.554,-532.7753;Inherit;False;T4_NAOH_Textures;-1;True;1;0;SAMPLER2D;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.GetLocalVarNode;304;-6069.559,-548.9022;Inherit;False;303;T4_NAOH_Textures;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.GetLocalVarNode;286;-6072.859,-1156.923;Inherit;False;285;T3_NAOH_Textures;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;305;-4703.767,-1156.114;Inherit;False;T3_NAOH;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;306;-4700.465,-548.0933;Inherit;False;T4_NAOH;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;59;-2304,-2352;Inherit;True;Procedural Sample;-1;;14;f5379ff72769e2b4495e5ce2f004d8d4;2,157,0,315,0;7;82;SAMPLER2D;0;False;158;SAMPLER2DARRAY;0;False;183;FLOAT;0;False;5;FLOAT2;0,0;False;80;FLOAT3;0,0,0;False;104;FLOAT2;1,1;False;74;SAMPLERSTATE;0;False;5;COLOR;0;FLOAT;32;FLOAT;33;FLOAT;34;FLOAT;35
Node;AmplifyShaderEditor.RangedFloatNode;67;-1696,-2224;Inherit;False;Constant;_Float0;Float 0;7;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;66;-1520,-2368;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;64;-1712,-2368;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;70;-1376,-2208;Inherit;False;45;DebugGrayscale;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;69;-1120,-2368;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;58;-2880,-2352;Inherit;False;11;T1_Textures;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.SamplerNode;12;-3664,-2368;Inherit;True;Property;_T_1_TextureSample;T_1_Texture Sample;1;0;Create;True;0;0;0;False;0;False;10;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;11;-3888,-2368;Inherit;False;T1_Textures;-1;True;1;0;SAMPLER2D;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.TexturePropertyNode;10;-4176,-2368;Inherit;True;Property;_T1_Terrain;T1_Terrain;7;1;[Header];Create;True;1;Texture 1 Vertex Paint Black;0;0;False;0;False;None;4f359a34160143c49b2a6bf43e1a5e42;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SamplerNode;63;-2352,-2000;Inherit;True;Property;_TextureSample24;Texture Sample 24;7;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;26;-3648,-1696;Inherit;True;Property;_T_2_TextureSample;T_2_Texture Sample;1;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;34;-3648,-976;Inherit;True;Property;_T_3_TextureSample;T_3_Texture Sample;1;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;28;-4144,-1488;Inherit;False;0;24;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;31;-4144,-768;Inherit;False;0;33;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;30;-3872,-976;Inherit;False;T3_Textures;-1;True;1;0;SAMPLER2D;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;25;-3872,-1696;Inherit;False;T2_Textures;-1;True;1;0;SAMPLER2D;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;104;-2640,-1440;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;106;-2352,-1312;Inherit;True;Property;_TextureSample25;Texture Sample 24;7;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;108;-1680,-1536;Inherit;False;Constant;_Float1;Float 0;7;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCGrayscale;109;-1344,-1600;Inherit;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;110;-1504,-1696;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;111;-1712,-1696;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;112;-1376,-1520;Inherit;False;45;DebugGrayscale;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;113;-1120,-1696;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;103;-2848,-1664;Inherit;False;25;T2_Textures;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;114;-848,-1696;Inherit;False;T2_RGB;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;118;-2624,-736;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;119;-2336,-608;Inherit;True;Property;_TextureSample26;Texture Sample 24;7;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;121;-1680,-832;Inherit;False;Constant;_Float2;Float 0;7;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCGrayscale;122;-1344,-896;Inherit;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;123;-1504,-992;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;124;-1696,-992;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;125;-1360,-816;Inherit;False;45;DebugGrayscale;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;126;-1104,-976;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;127;-2848,-960;Inherit;False;30;T3_Textures;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;130;-832,-992;Inherit;False;T3_RGB;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;39;-3664,-288;Inherit;True;Property;_T_4_TextureSample;T_4_Texture Sample;1;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;36;-4160,-80;Inherit;False;0;38;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;40;-3888,-288;Inherit;False;T4_Textures;-1;True;1;0;SAMPLER2D;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;132;-2640,-32;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;133;-2352,96;Inherit;True;Property;_TextureSample27;Texture Sample 24;7;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;134;-1696,-128;Inherit;False;Constant;_Float3;Float 0;7;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCGrayscale;135;-1360,-192;Inherit;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;136;-1504,-288;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;137;-1712,-288;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;138;-1376,-112;Inherit;False;45;DebugGrayscale;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;139;-1120,-288;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;140;-2304,-256;Inherit;True;Procedural Sample;-1;;15;f5379ff72769e2b4495e5ce2f004d8d4;2,157,0,315,0;7;82;SAMPLER2D;0;False;158;SAMPLER2DARRAY;0;False;183;FLOAT;0;False;5;FLOAT2;0,0;False;80;FLOAT3;0,0,0;False;104;FLOAT2;1,1;False;74;SAMPLERSTATE;0;False;5;COLOR;0;FLOAT;32;FLOAT;33;FLOAT;34;FLOAT;35
Node;AmplifyShaderEditor.GetLocalVarNode;141;-2864,-256;Inherit;False;40;T4_Textures;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;144;-848,-288;Inherit;False;T4_RGB;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TexturePropertyNode;24;-4160,-1696;Inherit;True;Property;_T2_Terrain;T2_Terrain;11;1;[Header];Create;True;1;Texture 2 Vertex Paint Red;0;0;False;0;False;None;401bbb72c9170f343bd105e06e7880b0;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.TexturePropertyNode;33;-4160,-976;Inherit;True;Property;_T3_Terrain;T3_Terrain;15;1;[Header];Create;True;1;Texture 3 Vertex Paint Green;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.TexturePropertyNode;38;-4176,-288;Inherit;True;Property;_T4_Terrain;T4_Terrain;19;1;[Header];Create;True;1;Texture 4 Vertex Paint Blue;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.FunctionNode;129;-2288,-960;Inherit;True;Procedural Sample;-1;;16;f5379ff72769e2b4495e5ce2f004d8d4;2,157,0,315,0;7;82;SAMPLER2D;0;False;158;SAMPLER2DARRAY;0;False;183;FLOAT;0;False;5;FLOAT2;0,0;False;80;FLOAT3;0,0,0;False;104;FLOAT2;1,1;False;74;SAMPLERSTATE;0;False;5;COLOR;0;FLOAT;32;FLOAT;33;FLOAT;34;FLOAT;35
Node;AmplifyShaderEditor.FunctionNode;105;-2304,-1664;Inherit;True;Procedural Sample;-1;;17;f5379ff72769e2b4495e5ce2f004d8d4;2,157,0,315,0;7;82;SAMPLER2D;0;False;158;SAMPLER2DARRAY;0;False;183;FLOAT;0;False;5;FLOAT2;0,0;False;80;FLOAT3;0,0,0;False;104;FLOAT2;1,1;False;74;SAMPLERSTATE;0;False;5;COLOR;0;FLOAT;32;FLOAT;33;FLOAT;34;FLOAT;35
Node;AmplifyShaderEditor.RegisterLocalVarNode;27;-3248,-1696;Inherit;False;T2_Albedo_Texture;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;32;-3248,-976;Inherit;False;T3_Albedo_Texture;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;37;-3264,-288;Inherit;False;T4_Albedo_Texture;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;15;-3262,-2368;Inherit;False;T1_Albedo_Texture;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;154;-2880,880;Inherit;False;46;DebugVertexPainting;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;155;-1904,832;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;157;-2160,848;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;158;-2432,848;Inherit;False;130;T3_RGB;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;159;-2448,944;Inherit;False;54;DebugColor3;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;147;-2544,400;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;148;-2832,496;Inherit;False;51;DebugColor1;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;146;-2816,400;Inherit;False;71;T1_RGB;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;149;-2880,592;Inherit;False;46;DebugVertexPainting;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;150;-2288,672;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;151;-2544,688;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;153;-2816,688;Inherit;False;114;T2_RGB;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;152;-2832,784;Inherit;False;52;DebugColor2;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;309;-7579.588,-21.17186;Inherit;False;2056.007;1181.899;Normal By Vertex Color;14;322;405;404;403;325;321;333;335;331;332;329;327;320;311;;1,1,1,1;0;0
Node;AmplifyShaderEditor.LerpOp;311;-6474.588,458.8281;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;320;-6090.588,794.8281;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;327;-6932.588,299.8282;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;329;-7210.588,317.8282;Inherit;False;268;T2_NAOH;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;332;-6699.623,489.3104;Inherit;False;305;T3_NAOH;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;331;-6316.623,814.3105;Inherit;False;306;T4_NAOH;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;335;-5898.759,919.7325;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;333;-6102.266,978.4011;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;321;-5786.588,793.8281;Inherit;False;AllNormal_Combined;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;213;634.9486,-1659.422;Inherit;False;Property;_DebugVertexPaintingAdding;DebugVertexPaintingAdding;0;1;[Header];Create;True;0;0;0;False;0;False;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;215;1018.107,-1918.514;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;210;298.0796,-1792.283;Inherit;False;208;AllAlbedoVertexPaint;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.BlendOpsNode;254;593.3951,-1815.775;Inherit;False;Overlay;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;183;301.6037,-1916.152;Inherit;False;168;AllAlbedoCombined;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;348;1270.158,-1917.503;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;349;949.1581,-1790.503;Inherit;False;321;AllNormal_Combined;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;351;984.1581,-1701.503;Inherit;False;43;DebugNormal;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;371;-2837.484,-11.93823;Inherit;False;368;T4_Tilling;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;370;-1995.869,-125.7466;Inherit;False;367;T4_ProceduralTiling;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;372;-2833.533,-720.7291;Inherit;False;365;T3_Tilling;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;373;-1991.919,-834.5376;Inherit;False;366;T3_ProceduralTiling;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;374;-2835.456,-1421.364;Inherit;False;363;T2_Tilling;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;379;-5191.725,-2239.871;Inherit;False;362;T1_ProceduralTiling;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;380;-5164.562,-1637.57;Inherit;False;364;T2_ProceduralTiling;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;383;-6031.644,-1008.532;Inherit;False;365;T3_Tilling;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;382;-5191.029,-1016.738;Inherit;False;366;T3_ProceduralTiling;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;385;-5192.014,-406.0318;Inherit;False;367;T4_ProceduralTiling;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;384;-6032.629,-397.8258;Inherit;False;368;T4_Tilling;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;387;1794.501,-1677.614;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ExtraPrePass;0;0;ExtraPrePass;5;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;5;True;12;all;0;False;True;1;1;False;;0;False;;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;0;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;389;1794.501,-1677.614;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ShadowCaster;0;2;ShadowCaster;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;False;False;True;False;False;False;False;0;False;;False;False;False;False;False;False;False;False;False;True;1;False;;True;3;False;;False;True;1;LightMode=ShadowCaster;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;390;1794.501,-1677.614;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthOnly;0;3;DepthOnly;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;False;False;True;False;False;False;False;0;False;;False;False;False;False;False;False;False;False;False;True;1;False;;False;False;True;1;LightMode=DepthOnly;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;391;1794.501,-1677.614;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;Meta;0;4;Meta;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Meta;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TFHCGrayscale;68;-1360,-2288;Inherit;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;381;-6005.177,-1629.364;Inherit;False;363;T2_Tilling;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;378;-6034.34,-2236.665;Inherit;False;361;T1_Tiling;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;376;-2001.904,-2205.265;Inherit;False;362;T1_ProceduralTiling;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;61;-2640,-2112;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;172;-7376.185,-2167.427;Inherit;False;0;10;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;71;-848,-2368;Inherit;False;T1_RGB;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;399;-2862.186,-2096.455;Inherit;False;361;T1_Tiling;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;22;-4160,-2160;Inherit;False;0;10;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;200;-1741.568,1623.241;Inherit;False;71;T1_RGB;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;196;-1777.656,2176.725;Inherit;False;130;T3_RGB;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;191;-1647.874,2298.306;Inherit;False;144;T4_RGB;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;198;-2033.905,2073.783;Inherit;False;114;T2_RGB;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;325;-7204.588,224.8281;Inherit;False;262;T1_NAOH;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;375;-1993.841,-1532.572;Inherit;False;364;T2_ProceduralTiling;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;160;-2496,1040;Inherit;False;46;DebugVertexPainting;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;166;-2909,1282;Inherit;True;Property;_TerrainMask_VertexPaint;TerrainMask_VertexPaint;6;1;[Header];Create;True;1;Terrain Mask;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;402;-2544,1408;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;401;-2544,1312;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;400;-2546.89,1190.998;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;322;-7536,848;Inherit;True;Property;_TerrainMask_VertexPaint1;TerrainMask_VertexPaint;6;1;[Header];Create;True;1;Terrain Mask;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;166;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;403;-7104,928;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;404;-7100.706,818.3354;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;405;-7104,704;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;388;2460.501,-1920.614;Float;False;True;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;S_Map_V2;2992e84f91cbeb14eab234972e07ea9d;True;Forward;0;1;Forward;8;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;5;True;12;all;0;False;True;1;1;False;;0;False;;1;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;1;LightMode=UniversalForward;False;False;0;Hidden/InternalErrorShader;0;0;Standard;22;Surface;0;0;  Blend;0;0;Two Sided;1;0;Cast Shadows;1;0;  Use Shadow Threshold;0;0;Receive Shadows;1;0;GPU Instancing;1;0;LOD CrossFade;0;0;Built-in Fog;0;0;DOTS Instancing;0;0;Meta Pass;0;0;Extra Pre Pass;0;0;Tessellation;0;0;  Phong;0;0;  Strength;0.5,False,;0;  Type;0;0;  Tess;16,False,;0;  Min;10,False,;0;  Max;25,False,;0;  Edge Length;16,False,;0;  Max Displacement;25,False,;0;Vertex Position,InvertActionOnDeselection;1;0;0;5;False;True;True;True;False;False;;False;0
Node;AmplifyShaderEditor.RangedFloatNode;47;-7489,1393;Inherit;False;Property;_VertexPaintDebug;VertexPaintDebug;5;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;50;-7489,1905;Inherit;False;Constant;_DebugColor1;DebugColor1;7;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;53;-7489,2081;Inherit;False;Constant;_DebugColor2;DebugColor2;7;0;Create;True;0;0;0;False;0;False;1,0,0.03653574,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;55;-7489,2257;Inherit;False;Constant;_DebugColor3;DebugColor3;7;0;Create;True;0;0;0;False;0;False;0,1,0.002223969,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;56;-7489,2433;Inherit;False;Constant;_DebugColor4;DebugColor2;7;0;Create;True;0;0;0;False;0;False;0.00126791,0,1,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;51;-7105,1905;Inherit;False;DebugColor1;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;52;-7105,2081;Inherit;False;DebugColor2;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;54;-7105,2257;Inherit;False;DebugColor3;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;57;-7105,2433;Inherit;False;DebugColor4;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;359;-6789,1292;Inherit;False;Property;_T1_Tiling1;T1_Tiling;9;0;Create;True;0;0;0;False;0;False;10;34.2;1;100;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;360;-6789,1372;Inherit;False;Property;_T1_ProceduralTiling1;T1_ProceduralTiling;10;0;Create;True;0;0;0;False;0;False;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;357;-6789,1468;Inherit;False;Property;_T2_Tilling1;T2_Tilling;13;0;Create;True;0;0;0;False;0;False;10;24.5;1;100;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;358;-6789,1548;Inherit;False;Property;_T2_ProceduralTiling1;T2_ProceduralTiling;14;0;Create;True;0;0;0;False;0;False;0;0.247;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;354;-6789,1644;Inherit;False;Property;_T3_Tilling1;T3_Tilling;17;0;Create;True;0;0;0;False;0;False;10;10;1;100;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;356;-6789,1724;Inherit;False;Property;_T3_ProceduralTiling1;T3_ProceduralTiling;18;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;355;-6789,1820;Inherit;False;Property;_T4_ProceduralTiling1;T4_ProceduralTiling;22;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;353;-6789,1900;Inherit;False;Property;_T4_Tilling1;T4_Tilling;21;0;Create;True;0;0;0;False;0;False;10;10;0;100;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;368;-6405,1900;Inherit;False;T4_Tilling;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;367;-6405,1820;Inherit;False;T4_ProceduralTiling;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;366;-6405,1724;Inherit;False;T3_ProceduralTiling;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;365;-6405,1644;Inherit;False;T3_Tilling;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;364;-6405,1548;Inherit;False;T2_ProceduralTiling;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;363;-6405,1468;Inherit;False;T2_Tilling;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;362;-6405,1372;Inherit;False;T1_ProceduralTiling;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;361;-6405,1292;Inherit;False;T1_Tiling;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;42;-7489,1473;Inherit;False;Property;_NormalDebug;NormalDebug;2;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;43;-7105,1473;Inherit;False;DebugNormal;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;46;-7105,1393;Inherit;False;DebugVertexPainting;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;409;-7488,1552;Inherit;False;Property;_DesaturateMapDebug;DesaturateMapDebug;3;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;411;-7488,1632;Inherit;False;Property;_ThresholdMap;ThresholdMap;4;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;412;-7104,1632;Inherit;False;DebugThreshold;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;410;-7104,1552;Inherit;False;DebugDesaturateMap;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;44;-7489,1313;Inherit;False;Property;_GrayscaleDebug;GrayscaleDebug;1;1;[Header];Create;True;1;Debug Mode;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;45;-7105,1313;Inherit;False;DebugGrayscale;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;165;-1520,1152;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;161;-1793,1175;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;162;-2049,1143;Inherit;False;144;T4_RGB;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;163;-2065,1239;Inherit;False;57;DebugColor4;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;164;-2113,1335;Inherit;False;46;DebugVertexPainting;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;168;-1004,1149;Inherit;False;AllAlbedoCombined;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DesaturateOpNode;415;-1296,1152;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;416;-1597.826,1285.18;Inherit;False;410;DebugDesaturateMap;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;208;-640,2144;Inherit;False;AllAlbedoVertexPaint;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DesaturateOpNode;417;-848,2148;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;418;-1111,2273;Inherit;False;410;DebugDesaturateMap;1;0;OBJECT;;False;1;FLOAT;0
WireConnection;186;0;189;0
WireConnection;187;0;186;0
WireConnection;189;0;188;0
WireConnection;189;1;190;0
WireConnection;202;0;201;0
WireConnection;202;1;187;2
WireConnection;201;0;187;0
WireConnection;201;1;187;1
WireConnection;203;0;202;0
WireConnection;204;0;203;0
WireConnection;205;0;200;0
WireConnection;205;1;204;0
WireConnection;194;0;199;0
WireConnection;194;1;193;0
WireConnection;199;0;206;0
WireConnection;199;1;195;0
WireConnection;206;0;205;0
WireConnection;206;1;197;0
WireConnection;193;0;187;2
WireConnection;193;1;191;0
WireConnection;195;0;187;1
WireConnection;195;1;196;0
WireConnection;197;0;187;0
WireConnection;197;1;198;0
WireConnection;260;0;256;0
WireConnection;260;1;259;0
WireConnection;260;2;379;0
WireConnection;174;0;175;0
WireConnection;174;1;172;0
WireConnection;175;0;173;0
WireConnection;257;0;378;0
WireConnection;259;0;255;0
WireConnection;259;1;257;0
WireConnection;256;82;255;0
WireConnection;256;5;257;0
WireConnection;267;0;277;0
WireConnection;267;1;276;0
WireConnection;267;2;380;0
WireConnection;274;0;381;0
WireConnection;277;82;273;0
WireConnection;277;5;274;0
WireConnection;270;0;272;0
WireConnection;270;1;269;0
WireConnection;272;0;271;0
WireConnection;262;0;260;0
WireConnection;268;0;267;0
WireConnection;281;0;290;0
WireConnection;281;1;289;0
WireConnection;281;2;382;0
WireConnection;283;0;285;0
WireConnection;283;1;282;0
WireConnection;287;0;383;0
WireConnection;289;0;286;0
WireConnection;289;1;287;0
WireConnection;290;82;286;0
WireConnection;290;5;287;0
WireConnection;294;0;299;0
WireConnection;294;1;298;0
WireConnection;294;2;385;0
WireConnection;296;0;384;0
WireConnection;298;0;304;0
WireConnection;298;1;296;0
WireConnection;299;82;304;0
WireConnection;299;5;296;0
WireConnection;302;0;303;0
WireConnection;302;1;295;0
WireConnection;276;0;273;0
WireConnection;276;1;274;0
WireConnection;285;0;284;0
WireConnection;303;0;301;0
WireConnection;305;0;281;0
WireConnection;306;0;294;0
WireConnection;59;82;58;0
WireConnection;59;5;61;0
WireConnection;66;0;64;0
WireConnection;66;1;67;0
WireConnection;64;0;63;0
WireConnection;64;1;59;0
WireConnection;64;2;376;0
WireConnection;69;0;66;0
WireConnection;69;1;68;0
WireConnection;69;2;70;0
WireConnection;12;0;11;0
WireConnection;12;1;22;0
WireConnection;11;0;10;0
WireConnection;63;0;58;0
WireConnection;63;1;61;0
WireConnection;26;0;25;0
WireConnection;26;1;28;0
WireConnection;34;0;30;0
WireConnection;34;1;31;0
WireConnection;30;0;33;0
WireConnection;25;0;24;0
WireConnection;104;0;374;0
WireConnection;106;0;103;0
WireConnection;106;1;104;0
WireConnection;109;0;110;0
WireConnection;110;0;111;0
WireConnection;110;1;108;0
WireConnection;111;0;106;0
WireConnection;111;1;105;0
WireConnection;111;2;375;0
WireConnection;113;0;110;0
WireConnection;113;1;109;0
WireConnection;113;2;112;0
WireConnection;114;0;113;0
WireConnection;118;0;372;0
WireConnection;119;0;127;0
WireConnection;119;1;118;0
WireConnection;122;0;123;0
WireConnection;123;0;124;0
WireConnection;123;1;121;0
WireConnection;124;0;119;0
WireConnection;124;1;129;0
WireConnection;124;2;373;0
WireConnection;126;0;123;0
WireConnection;126;1;122;0
WireConnection;126;2;125;0
WireConnection;130;0;126;0
WireConnection;39;0;40;0
WireConnection;39;1;36;0
WireConnection;40;0;38;0
WireConnection;132;0;371;0
WireConnection;133;0;141;0
WireConnection;133;1;132;0
WireConnection;135;0;136;0
WireConnection;136;0;137;0
WireConnection;136;1;134;0
WireConnection;137;0;133;0
WireConnection;137;1;140;0
WireConnection;137;2;370;0
WireConnection;139;0;136;0
WireConnection;139;1;135;0
WireConnection;139;2;138;0
WireConnection;140;82;141;0
WireConnection;140;5;132;0
WireConnection;144;0;139;0
WireConnection;129;82;127;0
WireConnection;129;5;118;0
WireConnection;105;82;103;0
WireConnection;105;5;104;0
WireConnection;27;0;26;0
WireConnection;32;0;34;0
WireConnection;37;0;39;0
WireConnection;15;0;12;0
WireConnection;155;0;150;0
WireConnection;155;1;157;0
WireConnection;155;2;401;0
WireConnection;157;0;158;0
WireConnection;157;1;159;0
WireConnection;157;2;160;0
WireConnection;147;0;146;0
WireConnection;147;1;148;0
WireConnection;147;2;149;0
WireConnection;150;0;147;0
WireConnection;150;1;151;0
WireConnection;150;2;400;0
WireConnection;151;0;153;0
WireConnection;151;1;152;0
WireConnection;151;2;154;0
WireConnection;311;0;327;0
WireConnection;311;1;332;0
WireConnection;311;2;404;0
WireConnection;320;0;311;0
WireConnection;320;1;331;0
WireConnection;320;2;403;0
WireConnection;327;0;325;0
WireConnection;327;1;329;0
WireConnection;327;2;405;0
WireConnection;335;1;333;0
WireConnection;321;0;320;0
WireConnection;215;0;183;0
WireConnection;215;1;254;0
WireConnection;215;2;213;0
WireConnection;254;0;183;0
WireConnection;254;1;210;0
WireConnection;348;0;215;0
WireConnection;348;1;349;0
WireConnection;348;2;351;0
WireConnection;68;0;66;0
WireConnection;61;0;399;0
WireConnection;71;0;69;0
WireConnection;402;0;166;3
WireConnection;401;0;166;2
WireConnection;400;0;166;1
WireConnection;403;0;322;3
WireConnection;404;0;322;2
WireConnection;405;0;322;1
WireConnection;388;2;348;0
WireConnection;51;0;50;0
WireConnection;52;0;53;0
WireConnection;54;0;55;0
WireConnection;57;0;56;0
WireConnection;368;0;353;0
WireConnection;367;0;355;0
WireConnection;366;0;356;0
WireConnection;365;0;354;0
WireConnection;364;0;358;0
WireConnection;363;0;357;0
WireConnection;362;0;360;0
WireConnection;361;0;359;0
WireConnection;43;0;42;0
WireConnection;46;0;47;0
WireConnection;412;0;411;0
WireConnection;410;0;409;0
WireConnection;45;0;44;0
WireConnection;165;0;155;0
WireConnection;165;1;161;0
WireConnection;165;2;402;0
WireConnection;161;0;162;0
WireConnection;161;1;163;0
WireConnection;161;2;164;0
WireConnection;168;0;415;0
WireConnection;415;0;165;0
WireConnection;415;1;416;0
WireConnection;208;0;417;0
WireConnection;417;0;194;0
WireConnection;417;1;418;0
ASEEND*/
//CHKSM=148992B868353BAE73A9E1E17A92103061711768