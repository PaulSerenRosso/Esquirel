// Made with Amplify Shader Editor v1.9.1.2
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "S_Map_V1"
{
	Properties
	{
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		[ASEBegin][Header(UseVertexPainting)]_UseVertexPainting("UseVertexPainting", Range( 0 , 1)) = 1
		[Header(Debug Mode)]_GrayscaleDebug("GrayscaleDebug", Range( 0 , 1)) = 0
		_DesaturateDebug("DesaturateDebug", Range( 0 , 1)) = 0
		_ThresholdDebug("ThresholdDebug", Range( 0 , 1)) = 0
		_NormalDebug("NormalDebug", Range( 0 , 1)) = 0
		_VertexPaintDebug("VertexPaintDebug", Range( 0 , 1)) = 0
		[Header(Main Property Material)]_MainTint("MainTint", Color) = (1,1,1,1)
		_ColorIntensity("Color Intensity", Float) = 2
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
		_T4_ProceduralTiling1("T4_ProceduralTiling", Range( 0 , 1)) = 0
		[Header(Others Properties)]_Smoothness("Smoothness", Range( 0 , 1)) = 0
		_Metallic("Metallic", Range( 0 , 1)) = 0
		[ASEEnd][Header(Modify Texture Property)][IntRange]_FlipTexture("FlipTexture", Range( 0 , 1)) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}


		//_TransmissionShadow( "Transmission Shadow", Range( 0, 1 ) ) = 0.5
		//_TransStrength( "Trans Strength", Range( 0, 50 ) ) = 1
		//_TransNormal( "Trans Normal Distortion", Range( 0, 1 ) ) = 0.5
		//_TransScattering( "Trans Scattering", Range( 1, 50 ) ) = 2
		//_TransDirect( "Trans Direct", Range( 0, 1 ) ) = 0.9
		//_TransAmbient( "Trans Ambient", Range( 0, 1 ) ) = 0.1
		//_TransShadow( "Trans Shadow", Range( 0, 1 ) ) = 0.5
		//_TessPhongStrength( "Tess Phong Strength", Range( 0, 1 ) ) = 0.5
		//_TessValue( "Tess Max Tessellation", Range( 1, 32 ) ) = 16
		//_TessMin( "Tess Min Distance", Float ) = 10
		//_TessMax( "Tess Max Distance", Float ) = 25
		//_TessEdgeLength ( "Tess Edge length", Range( 2, 50 ) ) = 16
		//_TessMaxDisp( "Tess Max Displacement", Float ) = 25

		[HideInInspector][ToggleOff] _SpecularHighlights("Specular Highlights", Float) = 1.0
		[HideInInspector][ToggleOff] _EnvironmentReflections("Environment Reflections", Float) = 1.0
		[HideInInspector][ToggleOff] _ReceiveShadows("Receive Shadows", Float) = 1.0
	}

	SubShader
	{
		LOD 0

		

		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Opaque" "Queue"="Geometry" }

		Cull Back
		ZWrite On
		ZTest LEqual
		Offset 0 , 0
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

			#define _NORMAL_DROPOFF_TS 1
			#pragma multi_compile_instancing
			#pragma multi_compile _ LOD_FADE_CROSSFADE
			#pragma multi_compile_fog
			#define ASE_FOG 1
			#define _NORMALMAP 1
			#define ASE_SRP_VERSION 101001


			#pragma shader_feature_local _RECEIVE_SHADOWS_OFF
			#pragma shader_feature_local_fragment _SPECULARHIGHLIGHTS_OFF
			#pragma shader_feature_local_fragment _ENVIRONMENTREFLECTIONS_OFF

			
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
		

			

			#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
			#pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
			#pragma multi_compile_fragment _ _SHADOWS_SOFT
			#pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
			#pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
			#pragma multi_compile _ SHADOWS_SHADOWMASK

			#pragma multi_compile _ DIRLIGHTMAP_COMBINED
			#pragma multi_compile _ LIGHTMAP_ON

			#pragma vertex vert
			#pragma fragment frag

			#define SHADERPASS SHADERPASS_FORWARD

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#if defined(UNITY_INSTANCING_ENABLED) && defined(_TERRAIN_INSTANCED_PERPIXEL_NORMAL)
				#define ENABLE_TERRAIN_PERPIXEL_NORMAL
			#endif

			#include "../../Utils/ShaderUtils.hlsl"


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_tangent : TANGENT;
				float4 texcoord : TEXCOORD0;
				float4 texcoord1 : TEXCOORD1;
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				float4 lightmapUVOrVertexSH : TEXCOORD0;
				half4 fogFactorAndVertexLight : TEXCOORD1;
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
					float4 shadowCoord : TEXCOORD2;
				#endif
				float4 tSpace0 : TEXCOORD3;
				float4 tSpace1 : TEXCOORD4;
				float4 tSpace2 : TEXCOORD5;
				#if defined(ASE_NEEDS_FRAG_SCREEN_POSITION)
					float4 screenPos : TEXCOORD6;
				#endif
				float4 ase_texcoord7 : TEXCOORD7;
				float4 ase_color : COLOR;
				float3 ase_normal : NORMAL;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _MainTint;
			float4 _TerrainMask_VertexPaint_ST;
			float _T1_Tiling1;
			float _NormalDebug;
			float _DesaturateDebug;
			float _ThresholdDebug;
			float _ColorIntensity;
			float _UseVertexPainting;
			float _T4_ProceduralTiling1;
			float _T4_Tilling1;
			float _T3_ProceduralTiling1;
			float _T3_Tilling1;
			float _T2_ProceduralTiling1;
			float _T2_Tilling1;
			float _VertexPaintDebug;
			float _GrayscaleDebug;
			float _T1_ProceduralTiling1;
			float _FlipTexture;
			float _Metallic;
			float _Smoothness;
			#ifdef ASE_TRANSMISSION
				float _TransmissionShadow;
			#endif
			#ifdef ASE_TRANSLUCENCY
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			// Property used by ScenePickingPass
			#ifdef SCENEPICKINGPASS
				float4 _SelectionID;
			#endif

			// Properties used by SceneSelectionPass
			#ifdef SCENESELECTIONPASS
				int _ObjectId;
				int _PassValue;
			#endif

			sampler2D _T1_Terrain;
			sampler2D _TerrainMask_VertexPaint;
			sampler2D _T2_Terrain;
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
			

			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				o.ase_texcoord7.xy = v.texcoord.xy;
				o.ase_color = v.ase_color;
				o.ase_normal = v.ase_normal;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord7.zw = 0;

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
				float3 positionVS = TransformWorldToView( positionWS );
				float4 positionCS = TransformWorldToHClip( positionWS );

				VertexNormalInputs normalInput = GetVertexNormalInputs( v.ase_normal, v.ase_tangent );

				o.tSpace0 = float4( normalInput.normalWS, positionWS.x);
				o.tSpace1 = float4( normalInput.tangentWS, positionWS.y);
				o.tSpace2 = float4( normalInput.bitangentWS, positionWS.z);

				#if defined(LIGHTMAP_ON)
					OUTPUT_LIGHTMAP_UV( v.texcoord1, unity_LightmapST, o.lightmapUVOrVertexSH.xy );
				#endif

				#if !defined(LIGHTMAP_ON)
					OUTPUT_SH( normalInput.normalWS.xyz, o.lightmapUVOrVertexSH.xyz );
				#endif

				#if defined(ENABLE_TERRAIN_PERPIXEL_NORMAL)
					o.lightmapUVOrVertexSH.zw = v.texcoord;
					o.lightmapUVOrVertexSH.xy = v.texcoord * unity_LightmapST.xy + unity_LightmapST.zw;
				#endif

				half3 vertexLight = VertexLighting( positionWS, normalInput.normalWS );

				#ifdef ASE_FOG
					half fogFactor = ComputeFogFactor( positionCS.z );
				#else
					half fogFactor = 0;
				#endif

				o.fogFactorAndVertexLight = half4(fogFactor, vertexLight);

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = positionCS;
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif

				o.clipPos = positionCS;

				#if defined(ASE_NEEDS_FRAG_SCREEN_POSITION)
					o.screenPos = ComputeScreenPos(positionCS);
				#endif

				return o;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_tangent : TANGENT;
				float4 texcoord : TEXCOORD0;
				float4 texcoord1 : TEXCOORD1;
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
				o.ase_tangent = v.ase_tangent;
				o.texcoord = v.texcoord;
				o.texcoord1 = v.texcoord1;
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
				o.ase_tangent = patch[0].ase_tangent * bary.x + patch[1].ase_tangent * bary.y + patch[2].ase_tangent * bary.z;
				o.texcoord = patch[0].texcoord * bary.x + patch[1].texcoord * bary.y + patch[2].texcoord * bary.z;
				o.texcoord1 = patch[0].texcoord1 * bary.x + patch[1].texcoord1 * bary.y + patch[2].texcoord1 * bary.z;
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

			#if defined(ASE_EARLY_Z_DEPTH_OPTIMIZE)
				#define ASE_SV_DEPTH SV_DepthLessEqual
			#else
				#define ASE_SV_DEPTH SV_Depth
			#endif

			half4 frag ( VertexOutput IN
						#ifdef ASE_DEPTH_WRITE_ON
						,out float outputDepth : ASE_SV_DEPTH
						#endif
						 ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(IN);

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif

				#if defined(ENABLE_TERRAIN_PERPIXEL_NORMAL)
					float2 sampleCoords = (IN.lightmapUVOrVertexSH.zw / _TerrainHeightmapRecipSize.zw + 0.5f) * _TerrainHeightmapRecipSize.xy;
					float3 WorldNormal = TransformObjectToWorldNormal(normalize(SAMPLE_TEXTURE2D(_TerrainNormalmapTexture, sampler_TerrainNormalmapTexture, sampleCoords).rgb * 2 - 1));
					float3 WorldTangent = -cross(GetObjectToWorldMatrix()._13_23_33, WorldNormal);
					float3 WorldBiTangent = cross(WorldNormal, -WorldTangent);
				#else
					float3 WorldNormal = normalize( IN.tSpace0.xyz );
					float3 WorldTangent = IN.tSpace1.xyz;
					float3 WorldBiTangent = IN.tSpace2.xyz;
				#endif

				float3 WorldPosition = float3(IN.tSpace0.w,IN.tSpace1.w,IN.tSpace2.w);
				float3 WorldViewDirection = _WorldSpaceCameraPos.xyz  - WorldPosition;
				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				#if defined(ASE_NEEDS_FRAG_SCREEN_POSITION)
					float4 ScreenPos = IN.screenPos;
				#endif

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
					ShadowCoords = IN.shadowCoord;
				#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
					ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
				#endif

				WorldViewDirection = SafeNormalize( WorldViewDirection );

				float T1_Tiling361 = _T1_Tiling1;
				float2 temp_cast_0 = (T1_Tiling361).xx;
				float2 texCoord61 = IN.ase_texcoord7.xy * temp_cast_0 + float2( 0,0 );
				float DebugFlipTexture528 = _FlipTexture;
				float cos518 = cos( ( DebugFlipTexture528 * PI ) );
				float sin518 = sin( ( DebugFlipTexture528 * PI ) );
				float2 rotator518 = mul( texCoord61 - float2( 0.5,0.5 ) , float2x2( cos518 , -sin518 , sin518 , cos518 )) + float2( 0.5,0.5 );
				float localStochasticTiling2_g27 = ( 0.0 );
				float2 Input_UV145_g27 = rotator518;
				float2 UV2_g27 = Input_UV145_g27;
				float2 UV12_g27 = float2( 0,0 );
				float2 UV22_g27 = float2( 0,0 );
				float2 UV32_g27 = float2( 0,0 );
				float W12_g27 = 0.0;
				float W22_g27 = 0.0;
				float W32_g27 = 0.0;
				StochasticTiling( UV2_g27 , UV12_g27 , UV22_g27 , UV32_g27 , W12_g27 , W22_g27 , W32_g27 );
				float2 temp_output_10_0_g27 = ddx( Input_UV145_g27 );
				float2 temp_output_12_0_g27 = ddy( Input_UV145_g27 );
				float4 Output_2D293_g27 = ( ( tex2D( _T1_Terrain, UV12_g27, temp_output_10_0_g27, temp_output_12_0_g27 ) * W12_g27 ) + ( tex2D( _T1_Terrain, UV22_g27, temp_output_10_0_g27, temp_output_12_0_g27 ) * W22_g27 ) + ( tex2D( _T1_Terrain, UV32_g27, temp_output_10_0_g27, temp_output_12_0_g27 ) * W32_g27 ) );
				float T1_ProceduralTiling362 = _T1_ProceduralTiling1;
				float4 lerpResult64 = lerp( tex2D( _T1_Terrain, rotator518 ) , Output_2D293_g27 , T1_ProceduralTiling362);
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
				float2 uv_TerrainMask_VertexPaint = IN.ase_texcoord7.xy * _TerrainMask_VertexPaint_ST.xy + _TerrainMask_VertexPaint_ST.zw;
				float4 tex2DNode166 = tex2D( _TerrainMask_VertexPaint, uv_TerrainMask_VertexPaint );
				float T2_Tilling363 = _T2_Tilling1;
				float2 temp_cast_3 = (T2_Tilling363).xx;
				float2 texCoord520 = IN.ase_texcoord7.xy * temp_cast_3 + float2( 0,0 );
				float cos521 = cos( ( DebugFlipTexture528 * PI ) );
				float sin521 = sin( ( DebugFlipTexture528 * PI ) );
				float2 rotator521 = mul( texCoord520 - float2( 0.5,0.5 ) , float2x2( cos521 , -sin521 , sin521 , cos521 )) + float2( 0.5,0.5 );
				float localStochasticTiling2_g26 = ( 0.0 );
				float2 Input_UV145_g26 = rotator521;
				float2 UV2_g26 = Input_UV145_g26;
				float2 UV12_g26 = float2( 0,0 );
				float2 UV22_g26 = float2( 0,0 );
				float2 UV32_g26 = float2( 0,0 );
				float W12_g26 = 0.0;
				float W22_g26 = 0.0;
				float W32_g26 = 0.0;
				StochasticTiling( UV2_g26 , UV12_g26 , UV22_g26 , UV32_g26 , W12_g26 , W22_g26 , W32_g26 );
				float2 temp_output_10_0_g26 = ddx( Input_UV145_g26 );
				float2 temp_output_12_0_g26 = ddy( Input_UV145_g26 );
				float4 Output_2D293_g26 = ( ( tex2D( _T2_Terrain, UV12_g26, temp_output_10_0_g26, temp_output_12_0_g26 ) * W12_g26 ) + ( tex2D( _T2_Terrain, UV22_g26, temp_output_10_0_g26, temp_output_12_0_g26 ) * W22_g26 ) + ( tex2D( _T2_Terrain, UV32_g26, temp_output_10_0_g26, temp_output_12_0_g26 ) * W32_g26 ) );
				float T2_ProceduralTiling364 = _T2_ProceduralTiling1;
				float4 lerpResult111 = lerp( tex2D( _T2_Terrain, rotator521 ) , Output_2D293_g26 , T2_ProceduralTiling364);
				float4 temp_output_110_0 = ( lerpResult111 * 1.0 );
				float grayscale109 = Luminance(temp_output_110_0.rgb);
				float4 temp_cast_5 = (grayscale109).xxxx;
				float4 lerpResult113 = lerp( temp_output_110_0 , temp_cast_5 , DebugGrayscale45);
				float4 T2_RGB114 = lerpResult113;
				float4 color53 = IsGammaSpace() ? float4(1,0,0.03653574,0) : float4(1,0,0.002827844,0);
				float4 DebugColor252 = color53;
				float4 lerpResult151 = lerp( T2_RGB114 , DebugColor252 , DebugVertexPainting46);
				float4 lerpResult150 = lerp( ( lerpResult147 * ( 1.0 - ( tex2DNode166.r + tex2DNode166.g + tex2DNode166.b ) ) ) , lerpResult151 , ( tex2DNode166.r * 2.0 ));
				float T3_Tilling365 = _T3_Tilling1;
				float2 temp_cast_6 = (T3_Tilling365).xx;
				float2 texCoord118 = IN.ase_texcoord7.xy * temp_cast_6 + float2( 0,0 );
				float cos524 = cos( ( DebugFlipTexture528 * PI ) );
				float sin524 = sin( ( DebugFlipTexture528 * PI ) );
				float2 rotator524 = mul( texCoord118 - float2( 0.5,0.5 ) , float2x2( cos524 , -sin524 , sin524 , cos524 )) + float2( 0.5,0.5 );
				float localStochasticTiling2_g25 = ( 0.0 );
				float2 Input_UV145_g25 = rotator524;
				float2 UV2_g25 = Input_UV145_g25;
				float2 UV12_g25 = float2( 0,0 );
				float2 UV22_g25 = float2( 0,0 );
				float2 UV32_g25 = float2( 0,0 );
				float W12_g25 = 0.0;
				float W22_g25 = 0.0;
				float W32_g25 = 0.0;
				StochasticTiling( UV2_g25 , UV12_g25 , UV22_g25 , UV32_g25 , W12_g25 , W22_g25 , W32_g25 );
				float2 temp_output_10_0_g25 = ddx( Input_UV145_g25 );
				float2 temp_output_12_0_g25 = ddy( Input_UV145_g25 );
				float4 Output_2D293_g25 = ( ( tex2D( _T3_Terrain, UV12_g25, temp_output_10_0_g25, temp_output_12_0_g25 ) * W12_g25 ) + ( tex2D( _T3_Terrain, UV22_g25, temp_output_10_0_g25, temp_output_12_0_g25 ) * W22_g25 ) + ( tex2D( _T3_Terrain, UV32_g25, temp_output_10_0_g25, temp_output_12_0_g25 ) * W32_g25 ) );
				float T3_ProceduralTiling366 = _T3_ProceduralTiling1;
				float4 lerpResult124 = lerp( tex2D( _T3_Terrain, rotator524 ) , Output_2D293_g25 , T3_ProceduralTiling366);
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
				float2 texCoord132 = IN.ase_texcoord7.xy * temp_cast_9 + float2( 0,0 );
				float cos525 = cos( ( DebugFlipTexture528 * PI ) );
				float sin525 = sin( ( DebugFlipTexture528 * PI ) );
				float2 rotator525 = mul( texCoord132 - float2( 0.5,0.5 ) , float2x2( cos525 , -sin525 , sin525 , cos525 )) + float2( 0.5,0.5 );
				float localStochasticTiling2_g24 = ( 0.0 );
				float2 Input_UV145_g24 = rotator525;
				float2 UV2_g24 = Input_UV145_g24;
				float2 UV12_g24 = float2( 0,0 );
				float2 UV22_g24 = float2( 0,0 );
				float2 UV32_g24 = float2( 0,0 );
				float W12_g24 = 0.0;
				float W22_g24 = 0.0;
				float W32_g24 = 0.0;
				StochasticTiling( UV2_g24 , UV12_g24 , UV22_g24 , UV32_g24 , W12_g24 , W22_g24 , W32_g24 );
				float2 temp_output_10_0_g24 = ddx( Input_UV145_g24 );
				float2 temp_output_12_0_g24 = ddy( Input_UV145_g24 );
				float4 Output_2D293_g24 = ( ( tex2D( _T4_Terrain, UV12_g24, temp_output_10_0_g24, temp_output_12_0_g24 ) * W12_g24 ) + ( tex2D( _T4_Terrain, UV22_g24, temp_output_10_0_g24, temp_output_12_0_g24 ) * W22_g24 ) + ( tex2D( _T4_Terrain, UV32_g24, temp_output_10_0_g24, temp_output_12_0_g24 ) * W32_g24 ) );
				float T4_ProceduralTiling367 = _T4_ProceduralTiling1;
				float4 lerpResult137 = lerp( tex2D( _T4_Terrain, rotator525 ) , Output_2D293_g24 , T4_ProceduralTiling367);
				float4 temp_output_136_0 = ( lerpResult137 * 1.0 );
				float grayscale135 = Luminance(temp_output_136_0.rgb);
				float4 temp_cast_11 = (grayscale135).xxxx;
				float4 lerpResult139 = lerp( temp_output_136_0 , temp_cast_11 , DebugGrayscale45);
				float4 T4_RGB144 = lerpResult139;
				float4 color56 = IsGammaSpace() ? float4(0.00126791,0,1,0) : float4(9.813545E-05,0,1,0);
				float4 DebugColor457 = color56;
				float4 lerpResult161 = lerp( T4_RGB144 , DebugColor457 , DebugVertexPainting46);
				float4 lerpResult165 = lerp( lerpResult155 , lerpResult161 , ( tex2DNode166.b * 2.0 ));
				float4 AllAlbedoCombined168 = lerpResult165;
				float4 lerpResult425 = lerp( T1_RGB71 , DebugColor151 , DebugVertexPainting46);
				float4 break187 = saturate( ( IN.ase_color * 2.0 ) );
				float4 lerpResult431 = lerp( T2_RGB114 , DebugColor252 , DebugVertexPainting46);
				float4 lerpResult408 = lerp( ( lerpResult425 * ( 1.0 - saturate( ( break187.r + break187.g + break187.b ) ) ) ) , ( break187.r * lerpResult431 ) , break187.r);
				float4 lerpResult434 = lerp( T3_RGB130 , DebugColor354 , DebugVertexPainting46);
				float4 lerpResult409 = lerp( lerpResult408 , ( break187.g * lerpResult434 ) , break187.g);
				float4 lerpResult438 = lerp( T4_RGB144 , DebugColor457 , DebugVertexPainting46);
				float4 lerpResult410 = lerp( lerpResult409 , ( break187.b * lerpResult438 ) , break187.b);
				float4 AllAlbedoVertexPaint208 = lerpResult410;
				float UseVertexPainting445 = _UseVertexPainting;
				float4 lerpResult446 = lerp( AllAlbedoCombined168 , AllAlbedoVertexPaint208 , UseVertexPainting445);
				float BPColorIntensity484 = _ColorIntensity;
				float4 BPMainTint489 = _MainTint;
				float3 color500 = ( ( lerpResult446 * BPColorIntensity484 ) * BPMainTint489 ).rgb;
				float minInput500 = 0.0;
				float DebugThreshold502 = _ThresholdDebug;
				float gamma500 = DebugThreshold502;
				float maxInput500 = 1.0;
				float3 localfinalLevels500 = finalLevels( color500 , minInput500 , gamma500 , maxInput500 );
				float DebugDesaturate507 = _DesaturateDebug;
				float3 desaturateInitialColor505 = localfinalLevels500;
				float desaturateDot505 = dot( desaturateInitialColor505, float3( 0.299, 0.587, 0.114 ));
				float3 desaturateVar505 = lerp( desaturateInitialColor505, desaturateDot505.xxx, DebugDesaturate507 );
				float localStochasticTiling2_g20 = ( 0.0 );
				float2 temp_cast_14 = (T1_Tiling361).xx;
				float2 texCoord257 = IN.ase_texcoord7.xy * temp_cast_14 + float2( 0,0 );
				float cos509 = cos( ( DebugFlipTexture528 * PI ) );
				float sin509 = sin( ( DebugFlipTexture528 * PI ) );
				float2 rotator509 = mul( texCoord257 - float2( 0.5,0.5 ) , float2x2( cos509 , -sin509 , sin509 , cos509 )) + float2( 0.5,0.5 );
				float2 Input_UV145_g20 = rotator509;
				float2 UV2_g20 = Input_UV145_g20;
				float2 UV12_g20 = float2( 0,0 );
				float2 UV22_g20 = float2( 0,0 );
				float2 UV32_g20 = float2( 0,0 );
				float W12_g20 = 0.0;
				float W22_g20 = 0.0;
				float W32_g20 = 0.0;
				StochasticTiling( UV2_g20 , UV12_g20 , UV22_g20 , UV32_g20 , W12_g20 , W22_g20 , W32_g20 );
				float2 temp_output_10_0_g20 = ddx( Input_UV145_g20 );
				float2 temp_output_12_0_g20 = ddy( Input_UV145_g20 );
				float4 Output_2D293_g20 = ( ( tex2D( _T1_TerrainNAOH, UV12_g20, temp_output_10_0_g20, temp_output_12_0_g20 ) * W12_g20 ) + ( tex2D( _T1_TerrainNAOH, UV22_g20, temp_output_10_0_g20, temp_output_12_0_g20 ) * W22_g20 ) + ( tex2D( _T1_TerrainNAOH, UV32_g20, temp_output_10_0_g20, temp_output_12_0_g20 ) * W32_g20 ) );
				float4 lerpResult260 = lerp( Output_2D293_g20 , tex2D( _T1_TerrainNAOH, rotator509 ) , T1_ProceduralTiling362);
				float4 T1_NAOH262 = lerpResult260;
				float localStochasticTiling2_g21 = ( 0.0 );
				float2 temp_cast_15 = (T2_Tilling363).xx;
				float2 texCoord274 = IN.ase_texcoord7.xy * temp_cast_15 + float2( 0,0 );
				float cos511 = cos( ( DebugFlipTexture528 * PI ) );
				float sin511 = sin( ( DebugFlipTexture528 * PI ) );
				float2 rotator511 = mul( texCoord274 - float2( 0.5,0.5 ) , float2x2( cos511 , -sin511 , sin511 , cos511 )) + float2( 0.5,0.5 );
				float2 Input_UV145_g21 = rotator511;
				float2 UV2_g21 = Input_UV145_g21;
				float2 UV12_g21 = float2( 0,0 );
				float2 UV22_g21 = float2( 0,0 );
				float2 UV32_g21 = float2( 0,0 );
				float W12_g21 = 0.0;
				float W22_g21 = 0.0;
				float W32_g21 = 0.0;
				StochasticTiling( UV2_g21 , UV12_g21 , UV22_g21 , UV32_g21 , W12_g21 , W22_g21 , W32_g21 );
				float2 temp_output_10_0_g21 = ddx( Input_UV145_g21 );
				float2 temp_output_12_0_g21 = ddy( Input_UV145_g21 );
				float4 Output_2D293_g21 = ( ( tex2D( _T2_TerrainNAOH, UV12_g21, temp_output_10_0_g21, temp_output_12_0_g21 ) * W12_g21 ) + ( tex2D( _T2_TerrainNAOH, UV22_g21, temp_output_10_0_g21, temp_output_12_0_g21 ) * W22_g21 ) + ( tex2D( _T2_TerrainNAOH, UV32_g21, temp_output_10_0_g21, temp_output_12_0_g21 ) * W32_g21 ) );
				float4 lerpResult267 = lerp( Output_2D293_g21 , tex2D( _T2_TerrainNAOH, rotator511 ) , T2_ProceduralTiling364);
				float4 T2_NAOH268 = lerpResult267;
				float4 tex2DNode322 = tex2D( _TerrainMask_VertexPaint, uv_TerrainMask_VertexPaint );
				float4 lerpResult327 = lerp( T1_NAOH262 , T2_NAOH268 , ( tex2DNode322.r * 2.0 ));
				float localStochasticTiling2_g22 = ( 0.0 );
				float2 temp_cast_16 = (T3_Tilling365).xx;
				float2 texCoord287 = IN.ase_texcoord7.xy * temp_cast_16 + float2( 0,0 );
				float cos513 = cos( ( DebugFlipTexture528 * PI ) );
				float sin513 = sin( ( DebugFlipTexture528 * PI ) );
				float2 rotator513 = mul( texCoord287 - float2( 0.5,0.5 ) , float2x2( cos513 , -sin513 , sin513 , cos513 )) + float2( 0.5,0.5 );
				float2 Input_UV145_g22 = rotator513;
				float2 UV2_g22 = Input_UV145_g22;
				float2 UV12_g22 = float2( 0,0 );
				float2 UV22_g22 = float2( 0,0 );
				float2 UV32_g22 = float2( 0,0 );
				float W12_g22 = 0.0;
				float W22_g22 = 0.0;
				float W32_g22 = 0.0;
				StochasticTiling( UV2_g22 , UV12_g22 , UV22_g22 , UV32_g22 , W12_g22 , W22_g22 , W32_g22 );
				float2 temp_output_10_0_g22 = ddx( Input_UV145_g22 );
				float2 temp_output_12_0_g22 = ddy( Input_UV145_g22 );
				float4 Output_2D293_g22 = ( ( tex2D( _T3_TerrainNAOH, UV12_g22, temp_output_10_0_g22, temp_output_12_0_g22 ) * W12_g22 ) + ( tex2D( _T3_TerrainNAOH, UV22_g22, temp_output_10_0_g22, temp_output_12_0_g22 ) * W22_g22 ) + ( tex2D( _T3_TerrainNAOH, UV32_g22, temp_output_10_0_g22, temp_output_12_0_g22 ) * W32_g22 ) );
				float4 lerpResult281 = lerp( Output_2D293_g22 , tex2D( _T3_TerrainNAOH, rotator513 ) , T3_ProceduralTiling366);
				float4 T3_NAOH305 = lerpResult281;
				float4 lerpResult311 = lerp( lerpResult327 , T3_NAOH305 , ( tex2DNode322.g * 2.0 ));
				float localStochasticTiling2_g23 = ( 0.0 );
				float2 temp_cast_17 = (T4_Tilling368).xx;
				float2 texCoord515 = IN.ase_texcoord7.xy * temp_cast_17 + float2( 0,0 );
				float cos516 = cos( ( DebugFlipTexture528 * PI ) );
				float sin516 = sin( ( DebugFlipTexture528 * PI ) );
				float2 rotator516 = mul( texCoord515 - float2( 0.5,0.5 ) , float2x2( cos516 , -sin516 , sin516 , cos516 )) + float2( 0.5,0.5 );
				float2 Input_UV145_g23 = rotator516;
				float2 UV2_g23 = Input_UV145_g23;
				float2 UV12_g23 = float2( 0,0 );
				float2 UV22_g23 = float2( 0,0 );
				float2 UV32_g23 = float2( 0,0 );
				float W12_g23 = 0.0;
				float W22_g23 = 0.0;
				float W32_g23 = 0.0;
				StochasticTiling( UV2_g23 , UV12_g23 , UV22_g23 , UV32_g23 , W12_g23 , W22_g23 , W32_g23 );
				float2 temp_output_10_0_g23 = ddx( Input_UV145_g23 );
				float2 temp_output_12_0_g23 = ddy( Input_UV145_g23 );
				float4 Output_2D293_g23 = ( ( tex2D( _T4_TerrainNAOH, UV12_g23, temp_output_10_0_g23, temp_output_12_0_g23 ) * W12_g23 ) + ( tex2D( _T4_TerrainNAOH, UV22_g23, temp_output_10_0_g23, temp_output_12_0_g23 ) * W22_g23 ) + ( tex2D( _T4_TerrainNAOH, UV32_g23, temp_output_10_0_g23, temp_output_12_0_g23 ) * W32_g23 ) );
				float4 lerpResult294 = lerp( Output_2D293_g23 , tex2D( _T4_TerrainNAOH, rotator516 ) , T4_ProceduralTiling367);
				float4 T4_NAOH306 = lerpResult294;
				float4 lerpResult320 = lerp( lerpResult311 , T4_NAOH306 , ( tex2DNode322.b * 2.0 ));
				float4 AllNormal_Combined321 = lerpResult320;
				float DebugNormal43 = _NormalDebug;
				float4 lerpResult348 = lerp( float4( desaturateVar505 , 0.0 ) , AllNormal_Combined321 , DebugNormal43);
				
				float4 break462 = AllNormal_Combined321;
				float2 appendResult464 = (float2(break462.r , break462.g));
				float2 temp_output_1_0_g19 = appendResult464;
				float dotResult4_g19 = dot( temp_output_1_0_g19 , temp_output_1_0_g19 );
				float3 appendResult10_g19 = (float3((temp_output_1_0_g19).x , (temp_output_1_0_g19).y , sqrt( ( 1.0 - saturate( dotResult4_g19 ) ) )));
				float3 normalizeResult12_g19 = normalize( appendResult10_g19 );
				
				float BPMetallic493 = _Metallic;
				
				float BPSmoothness492 = _Smoothness;
				

				float3 BaseColor = lerpResult348.rgb;
				float3 Normal = ( IN.ase_normal + normalizeResult12_g19 );
				float3 Emission = 0;
				float3 Specular = 0.5;
				float Metallic = BPMetallic493;
				float Smoothness = BPSmoothness492;
				float Occlusion = 1;
				float Alpha = 1;
				float AlphaClipThreshold = 0.5;
				float AlphaClipThresholdShadow = 0.5;
				float3 BakedGI = 0;
				float3 RefractionColor = 1;
				float RefractionIndex = 1;
				float3 Transmission = 1;
				float3 Translucency = 1;

				#ifdef ASE_DEPTH_WRITE_ON
					float DepthValue = 0;
				#endif

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				InputData inputData;
				inputData.positionWS = WorldPosition;
				inputData.viewDirectionWS = WorldViewDirection;
				inputData.shadowCoord = ShadowCoords;

				#ifdef _NORMALMAP
						#if _NORMAL_DROPOFF_TS
							inputData.normalWS = TransformTangentToWorld(Normal, half3x3(WorldTangent, WorldBiTangent, WorldNormal));
						#elif _NORMAL_DROPOFF_OS
							inputData.normalWS = TransformObjectToWorldNormal(Normal);
						#elif _NORMAL_DROPOFF_WS
							inputData.normalWS = Normal;
						#endif
					inputData.normalWS = NormalizeNormalPerPixel(inputData.normalWS);
				#else
					inputData.normalWS = WorldNormal;
				#endif

				#ifdef ASE_FOG
					inputData.fogCoord = IN.fogFactorAndVertexLight.x;
				#endif
					inputData.vertexLighting = IN.fogFactorAndVertexLight.yzw;

				#if defined(ENABLE_TERRAIN_PERPIXEL_NORMAL)
					float3 SH = SampleSH(inputData.normalWS.xyz);
				#else
					float3 SH = IN.lightmapUVOrVertexSH.xyz;
				#endif

				inputData.bakedGI = SAMPLE_GI( IN.lightmapUVOrVertexSH.xy, SH, inputData.normalWS );

				#ifdef ASE_BAKEDGI
					inputData.bakedGI = BakedGI;
				#endif

				inputData.normalizedScreenSpaceUV = GetNormalizedScreenSpaceUV(IN.clipPos);
				inputData.shadowMask = SAMPLE_SHADOWMASK(IN.lightmapUVOrVertexSH.xy);

				half4 color = UniversalFragmentPBR(
					inputData,
					BaseColor,
					Metallic,
					Specular,
					Smoothness,
					Occlusion,
					Emission,
					Alpha);

				#ifdef ASE_TRANSMISSION
				{
					float shadow = _TransmissionShadow;

					Light mainLight = GetMainLight( inputData.shadowCoord );
					float3 mainAtten = mainLight.color * mainLight.distanceAttenuation;
					mainAtten = lerp( mainAtten, mainAtten * mainLight.shadowAttenuation, shadow );
					half3 mainTransmission = max(0 , -dot(inputData.normalWS, mainLight.direction)) * mainAtten * Transmission;
					color.rgb += BaseColor * mainTransmission;

					#ifdef _ADDITIONAL_LIGHTS
						int transPixelLightCount = GetAdditionalLightsCount();
						for (int i = 0; i < transPixelLightCount; ++i)
						{
							Light light = GetAdditionalLight(i, inputData.positionWS);
							float3 atten = light.color * light.distanceAttenuation;
							atten = lerp( atten, atten * light.shadowAttenuation, shadow );

							half3 transmission = max(0 , -dot(inputData.normalWS, light.direction)) * atten * Transmission;
							color.rgb += BaseColor * transmission;
						}
					#endif
				}
				#endif

				#ifdef ASE_TRANSLUCENCY
				{
					float shadow = _TransShadow;
					float normal = _TransNormal;
					float scattering = _TransScattering;
					float direct = _TransDirect;
					float ambient = _TransAmbient;
					float strength = _TransStrength;

					Light mainLight = GetMainLight( inputData.shadowCoord );
					float3 mainAtten = mainLight.color * mainLight.distanceAttenuation;
					mainAtten = lerp( mainAtten, mainAtten * mainLight.shadowAttenuation, shadow );

					half3 mainLightDir = mainLight.direction + inputData.normalWS * normal;
					half mainVdotL = pow( saturate( dot( inputData.viewDirectionWS, -mainLightDir ) ), scattering );
					half3 mainTranslucency = mainAtten * ( mainVdotL * direct + inputData.bakedGI * ambient ) * Translucency;
					color.rgb += BaseColor * mainTranslucency * strength;

					#ifdef _ADDITIONAL_LIGHTS
						int transPixelLightCount = GetAdditionalLightsCount();
						for (int i = 0; i < transPixelLightCount; ++i)
						{
							Light light = GetAdditionalLight(i, inputData.positionWS);
							float3 atten = light.color * light.distanceAttenuation;
							atten = lerp( atten, atten * light.shadowAttenuation, shadow );

							half3 lightDir = light.direction + inputData.normalWS * normal;
							half VdotL = pow( saturate( dot( inputData.viewDirectionWS, -lightDir ) ), scattering );
							half3 translucency = atten * ( VdotL * direct + inputData.bakedGI * ambient ) * Translucency;
							color.rgb += BaseColor * translucency * strength;
						}
					#endif
				}
				#endif

				#ifdef ASE_REFRACTION
					float4 projScreenPos = ScreenPos / ScreenPos.w;
					float3 refractionOffset = ( RefractionIndex - 1.0 ) * mul( UNITY_MATRIX_V, float4( WorldNormal,0 ) ).xyz * ( 1.0 - dot( WorldNormal, WorldViewDirection ) );
					projScreenPos.xy += refractionOffset.xy;
					float3 refraction = SHADERGRAPH_SAMPLE_SCENE_COLOR( projScreenPos.xy ) * RefractionColor;
					color.rgb = lerp( refraction, color.rgb, color.a );
					color.a = 1;
				#endif

				#ifdef ASE_FINAL_COLOR_ALPHA_MULTIPLY
					color.rgb *= color.a;
				#endif

				#ifdef ASE_FOG
					#ifdef TERRAIN_SPLAT_ADDPASS
						color.rgb = MixFogColor(color.rgb, half3( 0, 0, 0 ), IN.fogFactorAndVertexLight.x );
					#else
						color.rgb = MixFog(color.rgb, IN.fogFactorAndVertexLight.x);
					#endif
				#endif

				#ifdef ASE_DEPTH_WRITE_ON
					outputDepth = DepthValue;
				#endif

				return color;
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

			#define _NORMAL_DROPOFF_TS 1
			#pragma multi_compile_instancing
			#pragma multi_compile _ LOD_FADE_CROSSFADE
			#pragma multi_compile_fog
			#define ASE_FOG 1
			#define _NORMALMAP 1
			#define ASE_SRP_VERSION 101001


			#pragma vertex vert
			#pragma fragment frag

			#define SHADERPASS SHADERPASS_SHADOWCASTER

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

			

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
			float4 _MainTint;
			float4 _TerrainMask_VertexPaint_ST;
			float _T1_Tiling1;
			float _NormalDebug;
			float _DesaturateDebug;
			float _ThresholdDebug;
			float _ColorIntensity;
			float _UseVertexPainting;
			float _T4_ProceduralTiling1;
			float _T4_Tilling1;
			float _T3_ProceduralTiling1;
			float _T3_Tilling1;
			float _T2_ProceduralTiling1;
			float _T2_Tilling1;
			float _VertexPaintDebug;
			float _GrayscaleDebug;
			float _T1_ProceduralTiling1;
			float _FlipTexture;
			float _Metallic;
			float _Smoothness;
			#ifdef ASE_TRANSMISSION
				float _TransmissionShadow;
			#endif
			#ifdef ASE_TRANSLUCENCY
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			// Property used by ScenePickingPass
			#ifdef SCENEPICKINGPASS
				float4 _SelectionID;
			#endif

			// Properties used by SceneSelectionPass
			#ifdef SCENESELECTIONPASS
				int _ObjectId;
				int _PassValue;
			#endif

			

			
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

				float3 normalWS = TransformObjectToWorldDir(v.ase_normal);

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
					float4 clipPos = TransformWorldToHClip(ApplyShadowBias(positionWS, normalWS, _LightDirection));
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

			#if defined(ASE_EARLY_Z_DEPTH_OPTIMIZE)
				#define ASE_SV_DEPTH SV_DepthLessEqual
			#else
				#define ASE_SV_DEPTH SV_Depth
			#endif

			half4 frag(	VertexOutput IN
						#ifdef ASE_DEPTH_WRITE_ON
						,out float outputDepth : ASE_SV_DEPTH
						#endif
						 ) : SV_TARGET
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

				#ifdef ASE_DEPTH_WRITE_ON
					float DepthValue = 0;
				#endif

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

				#ifdef ASE_DEPTH_WRITE_ON
					outputDepth = DepthValue;
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

			#define _NORMAL_DROPOFF_TS 1
			#pragma multi_compile_instancing
			#pragma multi_compile _ LOD_FADE_CROSSFADE
			#pragma multi_compile_fog
			#define ASE_FOG 1
			#define _NORMALMAP 1
			#define ASE_SRP_VERSION 101001


			#pragma vertex vert
			#pragma fragment frag

			#define SHADERPASS SHADERPASS_DEPTHONLY

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

			

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
			float4 _MainTint;
			float4 _TerrainMask_VertexPaint_ST;
			float _T1_Tiling1;
			float _NormalDebug;
			float _DesaturateDebug;
			float _ThresholdDebug;
			float _ColorIntensity;
			float _UseVertexPainting;
			float _T4_ProceduralTiling1;
			float _T4_Tilling1;
			float _T3_ProceduralTiling1;
			float _T3_Tilling1;
			float _T2_ProceduralTiling1;
			float _T2_Tilling1;
			float _VertexPaintDebug;
			float _GrayscaleDebug;
			float _T1_ProceduralTiling1;
			float _FlipTexture;
			float _Metallic;
			float _Smoothness;
			#ifdef ASE_TRANSMISSION
				float _TransmissionShadow;
			#endif
			#ifdef ASE_TRANSLUCENCY
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			// Property used by ScenePickingPass
			#ifdef SCENEPICKINGPASS
				float4 _SelectionID;
			#endif

			// Properties used by SceneSelectionPass
			#ifdef SCENESELECTIONPASS
				int _ObjectId;
				int _PassValue;
			#endif

			

			
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

				o.clipPos = positionCS;

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

			#if defined(ASE_EARLY_Z_DEPTH_OPTIMIZE)
				#define ASE_SV_DEPTH SV_DepthLessEqual
			#else
				#define ASE_SV_DEPTH SV_Depth
			#endif

			half4 frag(	VertexOutput IN
						#ifdef ASE_DEPTH_WRITE_ON
						,out float outputDepth : ASE_SV_DEPTH
						#endif
						 ) : SV_TARGET
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
				#ifdef ASE_DEPTH_WRITE_ON
					float DepthValue = 0;
				#endif

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif

				#ifdef ASE_DEPTH_WRITE_ON
					outputDepth = DepthValue;
				#endif

				return 0;
			}
			ENDHLSL
		}

		
		Pass
		{
			
			Name "Meta"
			Tags { "LightMode"="Meta" }

			Cull Off

			HLSLPROGRAM

			#define _NORMAL_DROPOFF_TS 1
			#pragma multi_compile_instancing
			#pragma multi_compile _ LOD_FADE_CROSSFADE
			#pragma multi_compile_fog
			#define ASE_FOG 1
			#define _NORMALMAP 1
			#define ASE_SRP_VERSION 101001


			#pragma vertex vert
			#pragma fragment frag

			#define SHADERPASS SHADERPASS_META

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"

			#include "../../Utils/ShaderUtils.hlsl"


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 texcoord1 : TEXCOORD1;
				float4 texcoord2 : TEXCOORD2;
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
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _MainTint;
			float4 _TerrainMask_VertexPaint_ST;
			float _T1_Tiling1;
			float _NormalDebug;
			float _DesaturateDebug;
			float _ThresholdDebug;
			float _ColorIntensity;
			float _UseVertexPainting;
			float _T4_ProceduralTiling1;
			float _T4_Tilling1;
			float _T3_ProceduralTiling1;
			float _T3_Tilling1;
			float _T2_ProceduralTiling1;
			float _T2_Tilling1;
			float _VertexPaintDebug;
			float _GrayscaleDebug;
			float _T1_ProceduralTiling1;
			float _FlipTexture;
			float _Metallic;
			float _Smoothness;
			#ifdef ASE_TRANSMISSION
				float _TransmissionShadow;
			#endif
			#ifdef ASE_TRANSLUCENCY
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			// Property used by ScenePickingPass
			#ifdef SCENEPICKINGPASS
				float4 _SelectionID;
			#endif

			// Properties used by SceneSelectionPass
			#ifdef SCENESELECTIONPASS
				int _ObjectId;
				int _PassValue;
			#endif

			sampler2D _T1_Terrain;
			sampler2D _TerrainMask_VertexPaint;
			sampler2D _T2_Terrain;
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
			

			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				o.ase_texcoord2.xy = v.ase_texcoord.xy;
				o.ase_color = v.ase_color;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord2.zw = 0;

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

				o.clipPos = MetaVertexPosition( v.vertex, v.texcoord1.xy, v.texcoord1.xy, unity_LightmapST, unity_DynamicLightmapST );

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
				float4 texcoord1 : TEXCOORD1;
				float4 texcoord2 : TEXCOORD2;
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
				o.texcoord1 = v.texcoord1;
				o.texcoord2 = v.texcoord2;
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
				o.texcoord1 = patch[0].texcoord1 * bary.x + patch[1].texcoord1 * bary.y + patch[2].texcoord1 * bary.z;
				o.texcoord2 = patch[0].texcoord2 * bary.x + patch[1].texcoord2 * bary.y + patch[2].texcoord2 * bary.z;
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

				float T1_Tiling361 = _T1_Tiling1;
				float2 temp_cast_0 = (T1_Tiling361).xx;
				float2 texCoord61 = IN.ase_texcoord2.xy * temp_cast_0 + float2( 0,0 );
				float DebugFlipTexture528 = _FlipTexture;
				float cos518 = cos( ( DebugFlipTexture528 * PI ) );
				float sin518 = sin( ( DebugFlipTexture528 * PI ) );
				float2 rotator518 = mul( texCoord61 - float2( 0.5,0.5 ) , float2x2( cos518 , -sin518 , sin518 , cos518 )) + float2( 0.5,0.5 );
				float localStochasticTiling2_g27 = ( 0.0 );
				float2 Input_UV145_g27 = rotator518;
				float2 UV2_g27 = Input_UV145_g27;
				float2 UV12_g27 = float2( 0,0 );
				float2 UV22_g27 = float2( 0,0 );
				float2 UV32_g27 = float2( 0,0 );
				float W12_g27 = 0.0;
				float W22_g27 = 0.0;
				float W32_g27 = 0.0;
				StochasticTiling( UV2_g27 , UV12_g27 , UV22_g27 , UV32_g27 , W12_g27 , W22_g27 , W32_g27 );
				float2 temp_output_10_0_g27 = ddx( Input_UV145_g27 );
				float2 temp_output_12_0_g27 = ddy( Input_UV145_g27 );
				float4 Output_2D293_g27 = ( ( tex2D( _T1_Terrain, UV12_g27, temp_output_10_0_g27, temp_output_12_0_g27 ) * W12_g27 ) + ( tex2D( _T1_Terrain, UV22_g27, temp_output_10_0_g27, temp_output_12_0_g27 ) * W22_g27 ) + ( tex2D( _T1_Terrain, UV32_g27, temp_output_10_0_g27, temp_output_12_0_g27 ) * W32_g27 ) );
				float T1_ProceduralTiling362 = _T1_ProceduralTiling1;
				float4 lerpResult64 = lerp( tex2D( _T1_Terrain, rotator518 ) , Output_2D293_g27 , T1_ProceduralTiling362);
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
				float2 uv_TerrainMask_VertexPaint = IN.ase_texcoord2.xy * _TerrainMask_VertexPaint_ST.xy + _TerrainMask_VertexPaint_ST.zw;
				float4 tex2DNode166 = tex2D( _TerrainMask_VertexPaint, uv_TerrainMask_VertexPaint );
				float T2_Tilling363 = _T2_Tilling1;
				float2 temp_cast_3 = (T2_Tilling363).xx;
				float2 texCoord520 = IN.ase_texcoord2.xy * temp_cast_3 + float2( 0,0 );
				float cos521 = cos( ( DebugFlipTexture528 * PI ) );
				float sin521 = sin( ( DebugFlipTexture528 * PI ) );
				float2 rotator521 = mul( texCoord520 - float2( 0.5,0.5 ) , float2x2( cos521 , -sin521 , sin521 , cos521 )) + float2( 0.5,0.5 );
				float localStochasticTiling2_g26 = ( 0.0 );
				float2 Input_UV145_g26 = rotator521;
				float2 UV2_g26 = Input_UV145_g26;
				float2 UV12_g26 = float2( 0,0 );
				float2 UV22_g26 = float2( 0,0 );
				float2 UV32_g26 = float2( 0,0 );
				float W12_g26 = 0.0;
				float W22_g26 = 0.0;
				float W32_g26 = 0.0;
				StochasticTiling( UV2_g26 , UV12_g26 , UV22_g26 , UV32_g26 , W12_g26 , W22_g26 , W32_g26 );
				float2 temp_output_10_0_g26 = ddx( Input_UV145_g26 );
				float2 temp_output_12_0_g26 = ddy( Input_UV145_g26 );
				float4 Output_2D293_g26 = ( ( tex2D( _T2_Terrain, UV12_g26, temp_output_10_0_g26, temp_output_12_0_g26 ) * W12_g26 ) + ( tex2D( _T2_Terrain, UV22_g26, temp_output_10_0_g26, temp_output_12_0_g26 ) * W22_g26 ) + ( tex2D( _T2_Terrain, UV32_g26, temp_output_10_0_g26, temp_output_12_0_g26 ) * W32_g26 ) );
				float T2_ProceduralTiling364 = _T2_ProceduralTiling1;
				float4 lerpResult111 = lerp( tex2D( _T2_Terrain, rotator521 ) , Output_2D293_g26 , T2_ProceduralTiling364);
				float4 temp_output_110_0 = ( lerpResult111 * 1.0 );
				float grayscale109 = Luminance(temp_output_110_0.rgb);
				float4 temp_cast_5 = (grayscale109).xxxx;
				float4 lerpResult113 = lerp( temp_output_110_0 , temp_cast_5 , DebugGrayscale45);
				float4 T2_RGB114 = lerpResult113;
				float4 color53 = IsGammaSpace() ? float4(1,0,0.03653574,0) : float4(1,0,0.002827844,0);
				float4 DebugColor252 = color53;
				float4 lerpResult151 = lerp( T2_RGB114 , DebugColor252 , DebugVertexPainting46);
				float4 lerpResult150 = lerp( ( lerpResult147 * ( 1.0 - ( tex2DNode166.r + tex2DNode166.g + tex2DNode166.b ) ) ) , lerpResult151 , ( tex2DNode166.r * 2.0 ));
				float T3_Tilling365 = _T3_Tilling1;
				float2 temp_cast_6 = (T3_Tilling365).xx;
				float2 texCoord118 = IN.ase_texcoord2.xy * temp_cast_6 + float2( 0,0 );
				float cos524 = cos( ( DebugFlipTexture528 * PI ) );
				float sin524 = sin( ( DebugFlipTexture528 * PI ) );
				float2 rotator524 = mul( texCoord118 - float2( 0.5,0.5 ) , float2x2( cos524 , -sin524 , sin524 , cos524 )) + float2( 0.5,0.5 );
				float localStochasticTiling2_g25 = ( 0.0 );
				float2 Input_UV145_g25 = rotator524;
				float2 UV2_g25 = Input_UV145_g25;
				float2 UV12_g25 = float2( 0,0 );
				float2 UV22_g25 = float2( 0,0 );
				float2 UV32_g25 = float2( 0,0 );
				float W12_g25 = 0.0;
				float W22_g25 = 0.0;
				float W32_g25 = 0.0;
				StochasticTiling( UV2_g25 , UV12_g25 , UV22_g25 , UV32_g25 , W12_g25 , W22_g25 , W32_g25 );
				float2 temp_output_10_0_g25 = ddx( Input_UV145_g25 );
				float2 temp_output_12_0_g25 = ddy( Input_UV145_g25 );
				float4 Output_2D293_g25 = ( ( tex2D( _T3_Terrain, UV12_g25, temp_output_10_0_g25, temp_output_12_0_g25 ) * W12_g25 ) + ( tex2D( _T3_Terrain, UV22_g25, temp_output_10_0_g25, temp_output_12_0_g25 ) * W22_g25 ) + ( tex2D( _T3_Terrain, UV32_g25, temp_output_10_0_g25, temp_output_12_0_g25 ) * W32_g25 ) );
				float T3_ProceduralTiling366 = _T3_ProceduralTiling1;
				float4 lerpResult124 = lerp( tex2D( _T3_Terrain, rotator524 ) , Output_2D293_g25 , T3_ProceduralTiling366);
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
				float2 texCoord132 = IN.ase_texcoord2.xy * temp_cast_9 + float2( 0,0 );
				float cos525 = cos( ( DebugFlipTexture528 * PI ) );
				float sin525 = sin( ( DebugFlipTexture528 * PI ) );
				float2 rotator525 = mul( texCoord132 - float2( 0.5,0.5 ) , float2x2( cos525 , -sin525 , sin525 , cos525 )) + float2( 0.5,0.5 );
				float localStochasticTiling2_g24 = ( 0.0 );
				float2 Input_UV145_g24 = rotator525;
				float2 UV2_g24 = Input_UV145_g24;
				float2 UV12_g24 = float2( 0,0 );
				float2 UV22_g24 = float2( 0,0 );
				float2 UV32_g24 = float2( 0,0 );
				float W12_g24 = 0.0;
				float W22_g24 = 0.0;
				float W32_g24 = 0.0;
				StochasticTiling( UV2_g24 , UV12_g24 , UV22_g24 , UV32_g24 , W12_g24 , W22_g24 , W32_g24 );
				float2 temp_output_10_0_g24 = ddx( Input_UV145_g24 );
				float2 temp_output_12_0_g24 = ddy( Input_UV145_g24 );
				float4 Output_2D293_g24 = ( ( tex2D( _T4_Terrain, UV12_g24, temp_output_10_0_g24, temp_output_12_0_g24 ) * W12_g24 ) + ( tex2D( _T4_Terrain, UV22_g24, temp_output_10_0_g24, temp_output_12_0_g24 ) * W22_g24 ) + ( tex2D( _T4_Terrain, UV32_g24, temp_output_10_0_g24, temp_output_12_0_g24 ) * W32_g24 ) );
				float T4_ProceduralTiling367 = _T4_ProceduralTiling1;
				float4 lerpResult137 = lerp( tex2D( _T4_Terrain, rotator525 ) , Output_2D293_g24 , T4_ProceduralTiling367);
				float4 temp_output_136_0 = ( lerpResult137 * 1.0 );
				float grayscale135 = Luminance(temp_output_136_0.rgb);
				float4 temp_cast_11 = (grayscale135).xxxx;
				float4 lerpResult139 = lerp( temp_output_136_0 , temp_cast_11 , DebugGrayscale45);
				float4 T4_RGB144 = lerpResult139;
				float4 color56 = IsGammaSpace() ? float4(0.00126791,0,1,0) : float4(9.813545E-05,0,1,0);
				float4 DebugColor457 = color56;
				float4 lerpResult161 = lerp( T4_RGB144 , DebugColor457 , DebugVertexPainting46);
				float4 lerpResult165 = lerp( lerpResult155 , lerpResult161 , ( tex2DNode166.b * 2.0 ));
				float4 AllAlbedoCombined168 = lerpResult165;
				float4 lerpResult425 = lerp( T1_RGB71 , DebugColor151 , DebugVertexPainting46);
				float4 break187 = saturate( ( IN.ase_color * 2.0 ) );
				float4 lerpResult431 = lerp( T2_RGB114 , DebugColor252 , DebugVertexPainting46);
				float4 lerpResult408 = lerp( ( lerpResult425 * ( 1.0 - saturate( ( break187.r + break187.g + break187.b ) ) ) ) , ( break187.r * lerpResult431 ) , break187.r);
				float4 lerpResult434 = lerp( T3_RGB130 , DebugColor354 , DebugVertexPainting46);
				float4 lerpResult409 = lerp( lerpResult408 , ( break187.g * lerpResult434 ) , break187.g);
				float4 lerpResult438 = lerp( T4_RGB144 , DebugColor457 , DebugVertexPainting46);
				float4 lerpResult410 = lerp( lerpResult409 , ( break187.b * lerpResult438 ) , break187.b);
				float4 AllAlbedoVertexPaint208 = lerpResult410;
				float UseVertexPainting445 = _UseVertexPainting;
				float4 lerpResult446 = lerp( AllAlbedoCombined168 , AllAlbedoVertexPaint208 , UseVertexPainting445);
				float BPColorIntensity484 = _ColorIntensity;
				float4 BPMainTint489 = _MainTint;
				float3 color500 = ( ( lerpResult446 * BPColorIntensity484 ) * BPMainTint489 ).rgb;
				float minInput500 = 0.0;
				float DebugThreshold502 = _ThresholdDebug;
				float gamma500 = DebugThreshold502;
				float maxInput500 = 1.0;
				float3 localfinalLevels500 = finalLevels( color500 , minInput500 , gamma500 , maxInput500 );
				float DebugDesaturate507 = _DesaturateDebug;
				float3 desaturateInitialColor505 = localfinalLevels500;
				float desaturateDot505 = dot( desaturateInitialColor505, float3( 0.299, 0.587, 0.114 ));
				float3 desaturateVar505 = lerp( desaturateInitialColor505, desaturateDot505.xxx, DebugDesaturate507 );
				float localStochasticTiling2_g20 = ( 0.0 );
				float2 temp_cast_14 = (T1_Tiling361).xx;
				float2 texCoord257 = IN.ase_texcoord2.xy * temp_cast_14 + float2( 0,0 );
				float cos509 = cos( ( DebugFlipTexture528 * PI ) );
				float sin509 = sin( ( DebugFlipTexture528 * PI ) );
				float2 rotator509 = mul( texCoord257 - float2( 0.5,0.5 ) , float2x2( cos509 , -sin509 , sin509 , cos509 )) + float2( 0.5,0.5 );
				float2 Input_UV145_g20 = rotator509;
				float2 UV2_g20 = Input_UV145_g20;
				float2 UV12_g20 = float2( 0,0 );
				float2 UV22_g20 = float2( 0,0 );
				float2 UV32_g20 = float2( 0,0 );
				float W12_g20 = 0.0;
				float W22_g20 = 0.0;
				float W32_g20 = 0.0;
				StochasticTiling( UV2_g20 , UV12_g20 , UV22_g20 , UV32_g20 , W12_g20 , W22_g20 , W32_g20 );
				float2 temp_output_10_0_g20 = ddx( Input_UV145_g20 );
				float2 temp_output_12_0_g20 = ddy( Input_UV145_g20 );
				float4 Output_2D293_g20 = ( ( tex2D( _T1_TerrainNAOH, UV12_g20, temp_output_10_0_g20, temp_output_12_0_g20 ) * W12_g20 ) + ( tex2D( _T1_TerrainNAOH, UV22_g20, temp_output_10_0_g20, temp_output_12_0_g20 ) * W22_g20 ) + ( tex2D( _T1_TerrainNAOH, UV32_g20, temp_output_10_0_g20, temp_output_12_0_g20 ) * W32_g20 ) );
				float4 lerpResult260 = lerp( Output_2D293_g20 , tex2D( _T1_TerrainNAOH, rotator509 ) , T1_ProceduralTiling362);
				float4 T1_NAOH262 = lerpResult260;
				float localStochasticTiling2_g21 = ( 0.0 );
				float2 temp_cast_15 = (T2_Tilling363).xx;
				float2 texCoord274 = IN.ase_texcoord2.xy * temp_cast_15 + float2( 0,0 );
				float cos511 = cos( ( DebugFlipTexture528 * PI ) );
				float sin511 = sin( ( DebugFlipTexture528 * PI ) );
				float2 rotator511 = mul( texCoord274 - float2( 0.5,0.5 ) , float2x2( cos511 , -sin511 , sin511 , cos511 )) + float2( 0.5,0.5 );
				float2 Input_UV145_g21 = rotator511;
				float2 UV2_g21 = Input_UV145_g21;
				float2 UV12_g21 = float2( 0,0 );
				float2 UV22_g21 = float2( 0,0 );
				float2 UV32_g21 = float2( 0,0 );
				float W12_g21 = 0.0;
				float W22_g21 = 0.0;
				float W32_g21 = 0.0;
				StochasticTiling( UV2_g21 , UV12_g21 , UV22_g21 , UV32_g21 , W12_g21 , W22_g21 , W32_g21 );
				float2 temp_output_10_0_g21 = ddx( Input_UV145_g21 );
				float2 temp_output_12_0_g21 = ddy( Input_UV145_g21 );
				float4 Output_2D293_g21 = ( ( tex2D( _T2_TerrainNAOH, UV12_g21, temp_output_10_0_g21, temp_output_12_0_g21 ) * W12_g21 ) + ( tex2D( _T2_TerrainNAOH, UV22_g21, temp_output_10_0_g21, temp_output_12_0_g21 ) * W22_g21 ) + ( tex2D( _T2_TerrainNAOH, UV32_g21, temp_output_10_0_g21, temp_output_12_0_g21 ) * W32_g21 ) );
				float4 lerpResult267 = lerp( Output_2D293_g21 , tex2D( _T2_TerrainNAOH, rotator511 ) , T2_ProceduralTiling364);
				float4 T2_NAOH268 = lerpResult267;
				float4 tex2DNode322 = tex2D( _TerrainMask_VertexPaint, uv_TerrainMask_VertexPaint );
				float4 lerpResult327 = lerp( T1_NAOH262 , T2_NAOH268 , ( tex2DNode322.r * 2.0 ));
				float localStochasticTiling2_g22 = ( 0.0 );
				float2 temp_cast_16 = (T3_Tilling365).xx;
				float2 texCoord287 = IN.ase_texcoord2.xy * temp_cast_16 + float2( 0,0 );
				float cos513 = cos( ( DebugFlipTexture528 * PI ) );
				float sin513 = sin( ( DebugFlipTexture528 * PI ) );
				float2 rotator513 = mul( texCoord287 - float2( 0.5,0.5 ) , float2x2( cos513 , -sin513 , sin513 , cos513 )) + float2( 0.5,0.5 );
				float2 Input_UV145_g22 = rotator513;
				float2 UV2_g22 = Input_UV145_g22;
				float2 UV12_g22 = float2( 0,0 );
				float2 UV22_g22 = float2( 0,0 );
				float2 UV32_g22 = float2( 0,0 );
				float W12_g22 = 0.0;
				float W22_g22 = 0.0;
				float W32_g22 = 0.0;
				StochasticTiling( UV2_g22 , UV12_g22 , UV22_g22 , UV32_g22 , W12_g22 , W22_g22 , W32_g22 );
				float2 temp_output_10_0_g22 = ddx( Input_UV145_g22 );
				float2 temp_output_12_0_g22 = ddy( Input_UV145_g22 );
				float4 Output_2D293_g22 = ( ( tex2D( _T3_TerrainNAOH, UV12_g22, temp_output_10_0_g22, temp_output_12_0_g22 ) * W12_g22 ) + ( tex2D( _T3_TerrainNAOH, UV22_g22, temp_output_10_0_g22, temp_output_12_0_g22 ) * W22_g22 ) + ( tex2D( _T3_TerrainNAOH, UV32_g22, temp_output_10_0_g22, temp_output_12_0_g22 ) * W32_g22 ) );
				float4 lerpResult281 = lerp( Output_2D293_g22 , tex2D( _T3_TerrainNAOH, rotator513 ) , T3_ProceduralTiling366);
				float4 T3_NAOH305 = lerpResult281;
				float4 lerpResult311 = lerp( lerpResult327 , T3_NAOH305 , ( tex2DNode322.g * 2.0 ));
				float localStochasticTiling2_g23 = ( 0.0 );
				float2 temp_cast_17 = (T4_Tilling368).xx;
				float2 texCoord515 = IN.ase_texcoord2.xy * temp_cast_17 + float2( 0,0 );
				float cos516 = cos( ( DebugFlipTexture528 * PI ) );
				float sin516 = sin( ( DebugFlipTexture528 * PI ) );
				float2 rotator516 = mul( texCoord515 - float2( 0.5,0.5 ) , float2x2( cos516 , -sin516 , sin516 , cos516 )) + float2( 0.5,0.5 );
				float2 Input_UV145_g23 = rotator516;
				float2 UV2_g23 = Input_UV145_g23;
				float2 UV12_g23 = float2( 0,0 );
				float2 UV22_g23 = float2( 0,0 );
				float2 UV32_g23 = float2( 0,0 );
				float W12_g23 = 0.0;
				float W22_g23 = 0.0;
				float W32_g23 = 0.0;
				StochasticTiling( UV2_g23 , UV12_g23 , UV22_g23 , UV32_g23 , W12_g23 , W22_g23 , W32_g23 );
				float2 temp_output_10_0_g23 = ddx( Input_UV145_g23 );
				float2 temp_output_12_0_g23 = ddy( Input_UV145_g23 );
				float4 Output_2D293_g23 = ( ( tex2D( _T4_TerrainNAOH, UV12_g23, temp_output_10_0_g23, temp_output_12_0_g23 ) * W12_g23 ) + ( tex2D( _T4_TerrainNAOH, UV22_g23, temp_output_10_0_g23, temp_output_12_0_g23 ) * W22_g23 ) + ( tex2D( _T4_TerrainNAOH, UV32_g23, temp_output_10_0_g23, temp_output_12_0_g23 ) * W32_g23 ) );
				float4 lerpResult294 = lerp( Output_2D293_g23 , tex2D( _T4_TerrainNAOH, rotator516 ) , T4_ProceduralTiling367);
				float4 T4_NAOH306 = lerpResult294;
				float4 lerpResult320 = lerp( lerpResult311 , T4_NAOH306 , ( tex2DNode322.b * 2.0 ));
				float4 AllNormal_Combined321 = lerpResult320;
				float DebugNormal43 = _NormalDebug;
				float4 lerpResult348 = lerp( float4( desaturateVar505 , 0.0 ) , AllNormal_Combined321 , DebugNormal43);
				

				float3 BaseColor = lerpResult348.rgb;
				float3 Emission = 0;
				float Alpha = 1;
				float AlphaClipThreshold = 0.5;

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				MetaInput metaInput = (MetaInput)0;
				metaInput.Albedo = BaseColor;
				metaInput.Emission = Emission;

				return MetaFragment(metaInput);
			}
			ENDHLSL
		}

		
		Pass
		{
			
			Name "Universal2D"
			Tags { "LightMode"="Universal2D" }

			Blend One Zero, One Zero
			ZWrite On
			ZTest LEqual
			Offset 0 , 0
			ColorMask RGBA

			HLSLPROGRAM

			#define _NORMAL_DROPOFF_TS 1
			#pragma multi_compile_instancing
			#pragma multi_compile _ LOD_FADE_CROSSFADE
			#pragma multi_compile_fog
			#define ASE_FOG 1
			#define _NORMALMAP 1
			#define ASE_SRP_VERSION 101001


			#pragma vertex vert
			#pragma fragment frag

			#define SHADERPASS SHADERPASS_2D

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

			#include "../../Utils/ShaderUtils.hlsl"


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
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _MainTint;
			float4 _TerrainMask_VertexPaint_ST;
			float _T1_Tiling1;
			float _NormalDebug;
			float _DesaturateDebug;
			float _ThresholdDebug;
			float _ColorIntensity;
			float _UseVertexPainting;
			float _T4_ProceduralTiling1;
			float _T4_Tilling1;
			float _T3_ProceduralTiling1;
			float _T3_Tilling1;
			float _T2_ProceduralTiling1;
			float _T2_Tilling1;
			float _VertexPaintDebug;
			float _GrayscaleDebug;
			float _T1_ProceduralTiling1;
			float _FlipTexture;
			float _Metallic;
			float _Smoothness;
			#ifdef ASE_TRANSMISSION
				float _TransmissionShadow;
			#endif
			#ifdef ASE_TRANSLUCENCY
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			// Property used by ScenePickingPass
			#ifdef SCENEPICKINGPASS
				float4 _SelectionID;
			#endif

			// Properties used by SceneSelectionPass
			#ifdef SCENESELECTIONPASS
				int _ObjectId;
				int _PassValue;
			#endif

			sampler2D _T1_Terrain;
			sampler2D _TerrainMask_VertexPaint;
			sampler2D _T2_Terrain;
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
			

			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );

				o.ase_texcoord2.xy = v.ase_texcoord.xy;
				o.ase_color = v.ase_color;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord2.zw = 0;

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

				float T1_Tiling361 = _T1_Tiling1;
				float2 temp_cast_0 = (T1_Tiling361).xx;
				float2 texCoord61 = IN.ase_texcoord2.xy * temp_cast_0 + float2( 0,0 );
				float DebugFlipTexture528 = _FlipTexture;
				float cos518 = cos( ( DebugFlipTexture528 * PI ) );
				float sin518 = sin( ( DebugFlipTexture528 * PI ) );
				float2 rotator518 = mul( texCoord61 - float2( 0.5,0.5 ) , float2x2( cos518 , -sin518 , sin518 , cos518 )) + float2( 0.5,0.5 );
				float localStochasticTiling2_g27 = ( 0.0 );
				float2 Input_UV145_g27 = rotator518;
				float2 UV2_g27 = Input_UV145_g27;
				float2 UV12_g27 = float2( 0,0 );
				float2 UV22_g27 = float2( 0,0 );
				float2 UV32_g27 = float2( 0,0 );
				float W12_g27 = 0.0;
				float W22_g27 = 0.0;
				float W32_g27 = 0.0;
				StochasticTiling( UV2_g27 , UV12_g27 , UV22_g27 , UV32_g27 , W12_g27 , W22_g27 , W32_g27 );
				float2 temp_output_10_0_g27 = ddx( Input_UV145_g27 );
				float2 temp_output_12_0_g27 = ddy( Input_UV145_g27 );
				float4 Output_2D293_g27 = ( ( tex2D( _T1_Terrain, UV12_g27, temp_output_10_0_g27, temp_output_12_0_g27 ) * W12_g27 ) + ( tex2D( _T1_Terrain, UV22_g27, temp_output_10_0_g27, temp_output_12_0_g27 ) * W22_g27 ) + ( tex2D( _T1_Terrain, UV32_g27, temp_output_10_0_g27, temp_output_12_0_g27 ) * W32_g27 ) );
				float T1_ProceduralTiling362 = _T1_ProceduralTiling1;
				float4 lerpResult64 = lerp( tex2D( _T1_Terrain, rotator518 ) , Output_2D293_g27 , T1_ProceduralTiling362);
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
				float2 uv_TerrainMask_VertexPaint = IN.ase_texcoord2.xy * _TerrainMask_VertexPaint_ST.xy + _TerrainMask_VertexPaint_ST.zw;
				float4 tex2DNode166 = tex2D( _TerrainMask_VertexPaint, uv_TerrainMask_VertexPaint );
				float T2_Tilling363 = _T2_Tilling1;
				float2 temp_cast_3 = (T2_Tilling363).xx;
				float2 texCoord520 = IN.ase_texcoord2.xy * temp_cast_3 + float2( 0,0 );
				float cos521 = cos( ( DebugFlipTexture528 * PI ) );
				float sin521 = sin( ( DebugFlipTexture528 * PI ) );
				float2 rotator521 = mul( texCoord520 - float2( 0.5,0.5 ) , float2x2( cos521 , -sin521 , sin521 , cos521 )) + float2( 0.5,0.5 );
				float localStochasticTiling2_g26 = ( 0.0 );
				float2 Input_UV145_g26 = rotator521;
				float2 UV2_g26 = Input_UV145_g26;
				float2 UV12_g26 = float2( 0,0 );
				float2 UV22_g26 = float2( 0,0 );
				float2 UV32_g26 = float2( 0,0 );
				float W12_g26 = 0.0;
				float W22_g26 = 0.0;
				float W32_g26 = 0.0;
				StochasticTiling( UV2_g26 , UV12_g26 , UV22_g26 , UV32_g26 , W12_g26 , W22_g26 , W32_g26 );
				float2 temp_output_10_0_g26 = ddx( Input_UV145_g26 );
				float2 temp_output_12_0_g26 = ddy( Input_UV145_g26 );
				float4 Output_2D293_g26 = ( ( tex2D( _T2_Terrain, UV12_g26, temp_output_10_0_g26, temp_output_12_0_g26 ) * W12_g26 ) + ( tex2D( _T2_Terrain, UV22_g26, temp_output_10_0_g26, temp_output_12_0_g26 ) * W22_g26 ) + ( tex2D( _T2_Terrain, UV32_g26, temp_output_10_0_g26, temp_output_12_0_g26 ) * W32_g26 ) );
				float T2_ProceduralTiling364 = _T2_ProceduralTiling1;
				float4 lerpResult111 = lerp( tex2D( _T2_Terrain, rotator521 ) , Output_2D293_g26 , T2_ProceduralTiling364);
				float4 temp_output_110_0 = ( lerpResult111 * 1.0 );
				float grayscale109 = Luminance(temp_output_110_0.rgb);
				float4 temp_cast_5 = (grayscale109).xxxx;
				float4 lerpResult113 = lerp( temp_output_110_0 , temp_cast_5 , DebugGrayscale45);
				float4 T2_RGB114 = lerpResult113;
				float4 color53 = IsGammaSpace() ? float4(1,0,0.03653574,0) : float4(1,0,0.002827844,0);
				float4 DebugColor252 = color53;
				float4 lerpResult151 = lerp( T2_RGB114 , DebugColor252 , DebugVertexPainting46);
				float4 lerpResult150 = lerp( ( lerpResult147 * ( 1.0 - ( tex2DNode166.r + tex2DNode166.g + tex2DNode166.b ) ) ) , lerpResult151 , ( tex2DNode166.r * 2.0 ));
				float T3_Tilling365 = _T3_Tilling1;
				float2 temp_cast_6 = (T3_Tilling365).xx;
				float2 texCoord118 = IN.ase_texcoord2.xy * temp_cast_6 + float2( 0,0 );
				float cos524 = cos( ( DebugFlipTexture528 * PI ) );
				float sin524 = sin( ( DebugFlipTexture528 * PI ) );
				float2 rotator524 = mul( texCoord118 - float2( 0.5,0.5 ) , float2x2( cos524 , -sin524 , sin524 , cos524 )) + float2( 0.5,0.5 );
				float localStochasticTiling2_g25 = ( 0.0 );
				float2 Input_UV145_g25 = rotator524;
				float2 UV2_g25 = Input_UV145_g25;
				float2 UV12_g25 = float2( 0,0 );
				float2 UV22_g25 = float2( 0,0 );
				float2 UV32_g25 = float2( 0,0 );
				float W12_g25 = 0.0;
				float W22_g25 = 0.0;
				float W32_g25 = 0.0;
				StochasticTiling( UV2_g25 , UV12_g25 , UV22_g25 , UV32_g25 , W12_g25 , W22_g25 , W32_g25 );
				float2 temp_output_10_0_g25 = ddx( Input_UV145_g25 );
				float2 temp_output_12_0_g25 = ddy( Input_UV145_g25 );
				float4 Output_2D293_g25 = ( ( tex2D( _T3_Terrain, UV12_g25, temp_output_10_0_g25, temp_output_12_0_g25 ) * W12_g25 ) + ( tex2D( _T3_Terrain, UV22_g25, temp_output_10_0_g25, temp_output_12_0_g25 ) * W22_g25 ) + ( tex2D( _T3_Terrain, UV32_g25, temp_output_10_0_g25, temp_output_12_0_g25 ) * W32_g25 ) );
				float T3_ProceduralTiling366 = _T3_ProceduralTiling1;
				float4 lerpResult124 = lerp( tex2D( _T3_Terrain, rotator524 ) , Output_2D293_g25 , T3_ProceduralTiling366);
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
				float2 texCoord132 = IN.ase_texcoord2.xy * temp_cast_9 + float2( 0,0 );
				float cos525 = cos( ( DebugFlipTexture528 * PI ) );
				float sin525 = sin( ( DebugFlipTexture528 * PI ) );
				float2 rotator525 = mul( texCoord132 - float2( 0.5,0.5 ) , float2x2( cos525 , -sin525 , sin525 , cos525 )) + float2( 0.5,0.5 );
				float localStochasticTiling2_g24 = ( 0.0 );
				float2 Input_UV145_g24 = rotator525;
				float2 UV2_g24 = Input_UV145_g24;
				float2 UV12_g24 = float2( 0,0 );
				float2 UV22_g24 = float2( 0,0 );
				float2 UV32_g24 = float2( 0,0 );
				float W12_g24 = 0.0;
				float W22_g24 = 0.0;
				float W32_g24 = 0.0;
				StochasticTiling( UV2_g24 , UV12_g24 , UV22_g24 , UV32_g24 , W12_g24 , W22_g24 , W32_g24 );
				float2 temp_output_10_0_g24 = ddx( Input_UV145_g24 );
				float2 temp_output_12_0_g24 = ddy( Input_UV145_g24 );
				float4 Output_2D293_g24 = ( ( tex2D( _T4_Terrain, UV12_g24, temp_output_10_0_g24, temp_output_12_0_g24 ) * W12_g24 ) + ( tex2D( _T4_Terrain, UV22_g24, temp_output_10_0_g24, temp_output_12_0_g24 ) * W22_g24 ) + ( tex2D( _T4_Terrain, UV32_g24, temp_output_10_0_g24, temp_output_12_0_g24 ) * W32_g24 ) );
				float T4_ProceduralTiling367 = _T4_ProceduralTiling1;
				float4 lerpResult137 = lerp( tex2D( _T4_Terrain, rotator525 ) , Output_2D293_g24 , T4_ProceduralTiling367);
				float4 temp_output_136_0 = ( lerpResult137 * 1.0 );
				float grayscale135 = Luminance(temp_output_136_0.rgb);
				float4 temp_cast_11 = (grayscale135).xxxx;
				float4 lerpResult139 = lerp( temp_output_136_0 , temp_cast_11 , DebugGrayscale45);
				float4 T4_RGB144 = lerpResult139;
				float4 color56 = IsGammaSpace() ? float4(0.00126791,0,1,0) : float4(9.813545E-05,0,1,0);
				float4 DebugColor457 = color56;
				float4 lerpResult161 = lerp( T4_RGB144 , DebugColor457 , DebugVertexPainting46);
				float4 lerpResult165 = lerp( lerpResult155 , lerpResult161 , ( tex2DNode166.b * 2.0 ));
				float4 AllAlbedoCombined168 = lerpResult165;
				float4 lerpResult425 = lerp( T1_RGB71 , DebugColor151 , DebugVertexPainting46);
				float4 break187 = saturate( ( IN.ase_color * 2.0 ) );
				float4 lerpResult431 = lerp( T2_RGB114 , DebugColor252 , DebugVertexPainting46);
				float4 lerpResult408 = lerp( ( lerpResult425 * ( 1.0 - saturate( ( break187.r + break187.g + break187.b ) ) ) ) , ( break187.r * lerpResult431 ) , break187.r);
				float4 lerpResult434 = lerp( T3_RGB130 , DebugColor354 , DebugVertexPainting46);
				float4 lerpResult409 = lerp( lerpResult408 , ( break187.g * lerpResult434 ) , break187.g);
				float4 lerpResult438 = lerp( T4_RGB144 , DebugColor457 , DebugVertexPainting46);
				float4 lerpResult410 = lerp( lerpResult409 , ( break187.b * lerpResult438 ) , break187.b);
				float4 AllAlbedoVertexPaint208 = lerpResult410;
				float UseVertexPainting445 = _UseVertexPainting;
				float4 lerpResult446 = lerp( AllAlbedoCombined168 , AllAlbedoVertexPaint208 , UseVertexPainting445);
				float BPColorIntensity484 = _ColorIntensity;
				float4 BPMainTint489 = _MainTint;
				float3 color500 = ( ( lerpResult446 * BPColorIntensity484 ) * BPMainTint489 ).rgb;
				float minInput500 = 0.0;
				float DebugThreshold502 = _ThresholdDebug;
				float gamma500 = DebugThreshold502;
				float maxInput500 = 1.0;
				float3 localfinalLevels500 = finalLevels( color500 , minInput500 , gamma500 , maxInput500 );
				float DebugDesaturate507 = _DesaturateDebug;
				float3 desaturateInitialColor505 = localfinalLevels500;
				float desaturateDot505 = dot( desaturateInitialColor505, float3( 0.299, 0.587, 0.114 ));
				float3 desaturateVar505 = lerp( desaturateInitialColor505, desaturateDot505.xxx, DebugDesaturate507 );
				float localStochasticTiling2_g20 = ( 0.0 );
				float2 temp_cast_14 = (T1_Tiling361).xx;
				float2 texCoord257 = IN.ase_texcoord2.xy * temp_cast_14 + float2( 0,0 );
				float cos509 = cos( ( DebugFlipTexture528 * PI ) );
				float sin509 = sin( ( DebugFlipTexture528 * PI ) );
				float2 rotator509 = mul( texCoord257 - float2( 0.5,0.5 ) , float2x2( cos509 , -sin509 , sin509 , cos509 )) + float2( 0.5,0.5 );
				float2 Input_UV145_g20 = rotator509;
				float2 UV2_g20 = Input_UV145_g20;
				float2 UV12_g20 = float2( 0,0 );
				float2 UV22_g20 = float2( 0,0 );
				float2 UV32_g20 = float2( 0,0 );
				float W12_g20 = 0.0;
				float W22_g20 = 0.0;
				float W32_g20 = 0.0;
				StochasticTiling( UV2_g20 , UV12_g20 , UV22_g20 , UV32_g20 , W12_g20 , W22_g20 , W32_g20 );
				float2 temp_output_10_0_g20 = ddx( Input_UV145_g20 );
				float2 temp_output_12_0_g20 = ddy( Input_UV145_g20 );
				float4 Output_2D293_g20 = ( ( tex2D( _T1_TerrainNAOH, UV12_g20, temp_output_10_0_g20, temp_output_12_0_g20 ) * W12_g20 ) + ( tex2D( _T1_TerrainNAOH, UV22_g20, temp_output_10_0_g20, temp_output_12_0_g20 ) * W22_g20 ) + ( tex2D( _T1_TerrainNAOH, UV32_g20, temp_output_10_0_g20, temp_output_12_0_g20 ) * W32_g20 ) );
				float4 lerpResult260 = lerp( Output_2D293_g20 , tex2D( _T1_TerrainNAOH, rotator509 ) , T1_ProceduralTiling362);
				float4 T1_NAOH262 = lerpResult260;
				float localStochasticTiling2_g21 = ( 0.0 );
				float2 temp_cast_15 = (T2_Tilling363).xx;
				float2 texCoord274 = IN.ase_texcoord2.xy * temp_cast_15 + float2( 0,0 );
				float cos511 = cos( ( DebugFlipTexture528 * PI ) );
				float sin511 = sin( ( DebugFlipTexture528 * PI ) );
				float2 rotator511 = mul( texCoord274 - float2( 0.5,0.5 ) , float2x2( cos511 , -sin511 , sin511 , cos511 )) + float2( 0.5,0.5 );
				float2 Input_UV145_g21 = rotator511;
				float2 UV2_g21 = Input_UV145_g21;
				float2 UV12_g21 = float2( 0,0 );
				float2 UV22_g21 = float2( 0,0 );
				float2 UV32_g21 = float2( 0,0 );
				float W12_g21 = 0.0;
				float W22_g21 = 0.0;
				float W32_g21 = 0.0;
				StochasticTiling( UV2_g21 , UV12_g21 , UV22_g21 , UV32_g21 , W12_g21 , W22_g21 , W32_g21 );
				float2 temp_output_10_0_g21 = ddx( Input_UV145_g21 );
				float2 temp_output_12_0_g21 = ddy( Input_UV145_g21 );
				float4 Output_2D293_g21 = ( ( tex2D( _T2_TerrainNAOH, UV12_g21, temp_output_10_0_g21, temp_output_12_0_g21 ) * W12_g21 ) + ( tex2D( _T2_TerrainNAOH, UV22_g21, temp_output_10_0_g21, temp_output_12_0_g21 ) * W22_g21 ) + ( tex2D( _T2_TerrainNAOH, UV32_g21, temp_output_10_0_g21, temp_output_12_0_g21 ) * W32_g21 ) );
				float4 lerpResult267 = lerp( Output_2D293_g21 , tex2D( _T2_TerrainNAOH, rotator511 ) , T2_ProceduralTiling364);
				float4 T2_NAOH268 = lerpResult267;
				float4 tex2DNode322 = tex2D( _TerrainMask_VertexPaint, uv_TerrainMask_VertexPaint );
				float4 lerpResult327 = lerp( T1_NAOH262 , T2_NAOH268 , ( tex2DNode322.r * 2.0 ));
				float localStochasticTiling2_g22 = ( 0.0 );
				float2 temp_cast_16 = (T3_Tilling365).xx;
				float2 texCoord287 = IN.ase_texcoord2.xy * temp_cast_16 + float2( 0,0 );
				float cos513 = cos( ( DebugFlipTexture528 * PI ) );
				float sin513 = sin( ( DebugFlipTexture528 * PI ) );
				float2 rotator513 = mul( texCoord287 - float2( 0.5,0.5 ) , float2x2( cos513 , -sin513 , sin513 , cos513 )) + float2( 0.5,0.5 );
				float2 Input_UV145_g22 = rotator513;
				float2 UV2_g22 = Input_UV145_g22;
				float2 UV12_g22 = float2( 0,0 );
				float2 UV22_g22 = float2( 0,0 );
				float2 UV32_g22 = float2( 0,0 );
				float W12_g22 = 0.0;
				float W22_g22 = 0.0;
				float W32_g22 = 0.0;
				StochasticTiling( UV2_g22 , UV12_g22 , UV22_g22 , UV32_g22 , W12_g22 , W22_g22 , W32_g22 );
				float2 temp_output_10_0_g22 = ddx( Input_UV145_g22 );
				float2 temp_output_12_0_g22 = ddy( Input_UV145_g22 );
				float4 Output_2D293_g22 = ( ( tex2D( _T3_TerrainNAOH, UV12_g22, temp_output_10_0_g22, temp_output_12_0_g22 ) * W12_g22 ) + ( tex2D( _T3_TerrainNAOH, UV22_g22, temp_output_10_0_g22, temp_output_12_0_g22 ) * W22_g22 ) + ( tex2D( _T3_TerrainNAOH, UV32_g22, temp_output_10_0_g22, temp_output_12_0_g22 ) * W32_g22 ) );
				float4 lerpResult281 = lerp( Output_2D293_g22 , tex2D( _T3_TerrainNAOH, rotator513 ) , T3_ProceduralTiling366);
				float4 T3_NAOH305 = lerpResult281;
				float4 lerpResult311 = lerp( lerpResult327 , T3_NAOH305 , ( tex2DNode322.g * 2.0 ));
				float localStochasticTiling2_g23 = ( 0.0 );
				float2 temp_cast_17 = (T4_Tilling368).xx;
				float2 texCoord515 = IN.ase_texcoord2.xy * temp_cast_17 + float2( 0,0 );
				float cos516 = cos( ( DebugFlipTexture528 * PI ) );
				float sin516 = sin( ( DebugFlipTexture528 * PI ) );
				float2 rotator516 = mul( texCoord515 - float2( 0.5,0.5 ) , float2x2( cos516 , -sin516 , sin516 , cos516 )) + float2( 0.5,0.5 );
				float2 Input_UV145_g23 = rotator516;
				float2 UV2_g23 = Input_UV145_g23;
				float2 UV12_g23 = float2( 0,0 );
				float2 UV22_g23 = float2( 0,0 );
				float2 UV32_g23 = float2( 0,0 );
				float W12_g23 = 0.0;
				float W22_g23 = 0.0;
				float W32_g23 = 0.0;
				StochasticTiling( UV2_g23 , UV12_g23 , UV22_g23 , UV32_g23 , W12_g23 , W22_g23 , W32_g23 );
				float2 temp_output_10_0_g23 = ddx( Input_UV145_g23 );
				float2 temp_output_12_0_g23 = ddy( Input_UV145_g23 );
				float4 Output_2D293_g23 = ( ( tex2D( _T4_TerrainNAOH, UV12_g23, temp_output_10_0_g23, temp_output_12_0_g23 ) * W12_g23 ) + ( tex2D( _T4_TerrainNAOH, UV22_g23, temp_output_10_0_g23, temp_output_12_0_g23 ) * W22_g23 ) + ( tex2D( _T4_TerrainNAOH, UV32_g23, temp_output_10_0_g23, temp_output_12_0_g23 ) * W32_g23 ) );
				float4 lerpResult294 = lerp( Output_2D293_g23 , tex2D( _T4_TerrainNAOH, rotator516 ) , T4_ProceduralTiling367);
				float4 T4_NAOH306 = lerpResult294;
				float4 lerpResult320 = lerp( lerpResult311 , T4_NAOH306 , ( tex2DNode322.b * 2.0 ));
				float4 AllNormal_Combined321 = lerpResult320;
				float DebugNormal43 = _NormalDebug;
				float4 lerpResult348 = lerp( float4( desaturateVar505 , 0.0 ) , AllNormal_Combined321 , DebugNormal43);
				

				float3 BaseColor = lerpResult348.rgb;
				float Alpha = 1;
				float AlphaClipThreshold = 0.5;

				half4 color = half4(BaseColor, Alpha );

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				return color;
			}
			ENDHLSL
		}

		
		Pass
		{
			
			Name "DepthNormals"
			Tags { "LightMode"="DepthNormals" }

			ZWrite On
			Blend One Zero
			ZTest LEqual
			ZWrite On

			HLSLPROGRAM

			#define _NORMAL_DROPOFF_TS 1
			#pragma multi_compile_instancing
			#pragma multi_compile _ LOD_FADE_CROSSFADE
			#pragma multi_compile_fog
			#define ASE_FOG 1
			#define _NORMALMAP 1
			#define ASE_SRP_VERSION 101001


			#pragma vertex vert
			#pragma fragment frag

			#define SHADERPASS SHADERPASS_DEPTHNORMALSONLY

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

			

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
				float3 worldNormal : TEXCOORD2;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _MainTint;
			float4 _TerrainMask_VertexPaint_ST;
			float _T1_Tiling1;
			float _NormalDebug;
			float _DesaturateDebug;
			float _ThresholdDebug;
			float _ColorIntensity;
			float _UseVertexPainting;
			float _T4_ProceduralTiling1;
			float _T4_Tilling1;
			float _T3_ProceduralTiling1;
			float _T3_Tilling1;
			float _T2_ProceduralTiling1;
			float _T2_Tilling1;
			float _VertexPaintDebug;
			float _GrayscaleDebug;
			float _T1_ProceduralTiling1;
			float _FlipTexture;
			float _Metallic;
			float _Smoothness;
			#ifdef ASE_TRANSMISSION
				float _TransmissionShadow;
			#endif
			#ifdef ASE_TRANSLUCENCY
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			// Property used by ScenePickingPass
			#ifdef SCENEPICKINGPASS
				float4 _SelectionID;
			#endif

			// Properties used by SceneSelectionPass
			#ifdef SCENESELECTIONPASS
				int _ObjectId;
				int _PassValue;
			#endif

			

			
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
				float3 normalWS = TransformObjectToWorldNormal( v.ase_normal );
				float4 positionCS = TransformWorldToHClip( positionWS );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					o.worldPos = positionWS;
				#endif

				o.worldNormal = normalWS;

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = positionCS;
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif

				o.clipPos = positionCS;

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

			#if defined(ASE_EARLY_Z_DEPTH_OPTIMIZE)
				#define ASE_SV_DEPTH SV_DepthLessEqual
			#else
				#define ASE_SV_DEPTH SV_Depth
			#endif

			half4 frag(	VertexOutput IN
						#ifdef ASE_DEPTH_WRITE_ON
						,out float outputDepth : ASE_SV_DEPTH
						#endif
						 ) : SV_TARGET
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
				#ifdef ASE_DEPTH_WRITE_ON
					float DepthValue = 0;
				#endif

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif

				#ifdef ASE_DEPTH_WRITE_ON
					outputDepth = DepthValue;
				#endif

				#if ASE_SRP_VERSION >= 110000
					return float4(PackNormalOctRectEncode(TransformWorldToViewDir(IN.worldNormal, true)), 0.0, 0.0);
				#elif ASE_SRP_VERSION >= 100900
					return float4(PackNormalOctRectEncode(normalize(IN.worldNormal)), 0.0, 0.0);
				#else
					return float4(PackNormalOctRectEncode(TransformWorldToViewDir(IN.worldNormal, true)), 0.0, 0.0);
				#endif
			}
			ENDHLSL
		}

		
		Pass
		{
			
			Name "GBuffer"
			Tags { "LightMode"="UniversalGBuffer" }

			Blend One Zero, One Zero
			ZWrite On
			ZTest LEqual
			Offset 0 , 0
			ColorMask RGBA
			

			HLSLPROGRAM

			#define _NORMAL_DROPOFF_TS 1
			#pragma multi_compile_instancing
			#pragma multi_compile _ LOD_FADE_CROSSFADE
			#pragma multi_compile_fog
			#define ASE_FOG 1
			#define _NORMALMAP 1
			#define ASE_SRP_VERSION 101001


			#pragma shader_feature_local _RECEIVE_SHADOWS_OFF
			#pragma shader_feature_local_fragment _SPECULARHIGHLIGHTS_OFF
			#pragma shader_feature_local_fragment _ENVIRONMENTREFLECTIONS_OFF

			
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
			#pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
		

			

			#pragma multi_compile_fragment _ _SHADOWS_SOFT

			#pragma multi_compile _ DIRLIGHTMAP_COMBINED
			#pragma multi_compile _ LIGHTMAP_ON
			#pragma multi_compile_fragment _ _GBUFFER_NORMALS_OCT

			#pragma vertex vert
			#pragma fragment frag

			#define SHADERPASS SHADERPASS_GBUFFER

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

			#if defined(UNITY_INSTANCING_ENABLED) && defined(_TERRAIN_INSTANCED_PERPIXEL_NORMAL)
				#define ENABLE_TERRAIN_PERPIXEL_NORMAL
			#endif

			#include "../../Utils/ShaderUtils.hlsl"


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_tangent : TANGENT;
				float4 texcoord : TEXCOORD0;
				float4 texcoord1 : TEXCOORD1;
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				float4 lightmapUVOrVertexSH : TEXCOORD0;
				half4 fogFactorAndVertexLight : TEXCOORD1;
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
				float4 shadowCoord : TEXCOORD2;
				#endif
				float4 tSpace0 : TEXCOORD3;
				float4 tSpace1 : TEXCOORD4;
				float4 tSpace2 : TEXCOORD5;
				#if defined(ASE_NEEDS_FRAG_SCREEN_POSITION)
				float4 screenPos : TEXCOORD6;
				#endif
				float4 ase_texcoord7 : TEXCOORD7;
				float4 ase_color : COLOR;
				float3 ase_normal : NORMAL;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _MainTint;
			float4 _TerrainMask_VertexPaint_ST;
			float _T1_Tiling1;
			float _NormalDebug;
			float _DesaturateDebug;
			float _ThresholdDebug;
			float _ColorIntensity;
			float _UseVertexPainting;
			float _T4_ProceduralTiling1;
			float _T4_Tilling1;
			float _T3_ProceduralTiling1;
			float _T3_Tilling1;
			float _T2_ProceduralTiling1;
			float _T2_Tilling1;
			float _VertexPaintDebug;
			float _GrayscaleDebug;
			float _T1_ProceduralTiling1;
			float _FlipTexture;
			float _Metallic;
			float _Smoothness;
			#ifdef ASE_TRANSMISSION
				float _TransmissionShadow;
			#endif
			#ifdef ASE_TRANSLUCENCY
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			// Property used by ScenePickingPass
			#ifdef SCENEPICKINGPASS
				float4 _SelectionID;
			#endif

			// Properties used by SceneSelectionPass
			#ifdef SCENESELECTIONPASS
				int _ObjectId;
				int _PassValue;
			#endif

			sampler2D _T1_Terrain;
			sampler2D _TerrainMask_VertexPaint;
			sampler2D _T2_Terrain;
			sampler2D _T3_Terrain;
			sampler2D _T4_Terrain;
			sampler2D _T1_TerrainNAOH;
			sampler2D _T2_TerrainNAOH;
			sampler2D _T3_TerrainNAOH;
			sampler2D _T4_TerrainNAOH;


			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/UnityGBuffer.hlsl"

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
			

			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				o.ase_texcoord7.xy = v.texcoord.xy;
				o.ase_color = v.ase_color;
				o.ase_normal = v.ase_normal;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord7.zw = 0;
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
				float3 positionVS = TransformWorldToView( positionWS );
				float4 positionCS = TransformWorldToHClip( positionWS );

				VertexNormalInputs normalInput = GetVertexNormalInputs( v.ase_normal, v.ase_tangent );

				o.tSpace0 = float4( normalInput.normalWS, positionWS.x);
				o.tSpace1 = float4( normalInput.tangentWS, positionWS.y);
				o.tSpace2 = float4( normalInput.bitangentWS, positionWS.z);

				OUTPUT_LIGHTMAP_UV( v.texcoord1, unity_LightmapST, o.lightmapUVOrVertexSH.xy );

				#if !defined(LIGHTMAP_ON)
					OUTPUT_SH(normalInput.normalWS.xyz, o.lightmapUVOrVertexSH.xyz);
				#endif

				#if defined(ENABLE_TERRAIN_PERPIXEL_NORMAL)
					o.lightmapUVOrVertexSH.zw = v.texcoord;
					o.lightmapUVOrVertexSH.xy = v.texcoord * unity_LightmapST.xy + unity_LightmapST.zw;
				#endif

				half3 vertexLight = VertexLighting( positionWS, normalInput.normalWS );

				#ifdef ASE_FOG
					half fogFactor = ComputeFogFactor( positionCS.z );
				#else
					half fogFactor = 0;
				#endif

				o.fogFactorAndVertexLight = half4(fogFactor, vertexLight);

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = positionCS;
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif

					o.clipPos = positionCS;

				#if defined(ASE_NEEDS_FRAG_SCREEN_POSITION)
					o.screenPos = ComputeScreenPos(positionCS);
				#endif

				return o;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_tangent : TANGENT;
				float4 texcoord : TEXCOORD0;
				float4 texcoord1 : TEXCOORD1;
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
				o.ase_tangent = v.ase_tangent;
				o.texcoord = v.texcoord;
				o.texcoord1 = v.texcoord1;
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
				o.ase_tangent = patch[0].ase_tangent * bary.x + patch[1].ase_tangent * bary.y + patch[2].ase_tangent * bary.z;
				o.texcoord = patch[0].texcoord * bary.x + patch[1].texcoord * bary.y + patch[2].texcoord * bary.z;
				o.texcoord1 = patch[0].texcoord1 * bary.x + patch[1].texcoord1 * bary.y + patch[2].texcoord1 * bary.z;
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

			#if defined(ASE_EARLY_Z_DEPTH_OPTIMIZE)
				#define ASE_SV_DEPTH SV_DepthLessEqual
			#else
				#define ASE_SV_DEPTH SV_Depth
			#endif

			FragmentOutput frag ( VertexOutput IN
								#ifdef ASE_DEPTH_WRITE_ON
								,out float outputDepth : ASE_SV_DEPTH
								#endif
								 )
			{
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(IN);

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif

				#if defined(ENABLE_TERRAIN_PERPIXEL_NORMAL)
					float2 sampleCoords = (IN.lightmapUVOrVertexSH.zw / _TerrainHeightmapRecipSize.zw + 0.5f) * _TerrainHeightmapRecipSize.xy;
					float3 WorldNormal = TransformObjectToWorldNormal(normalize(SAMPLE_TEXTURE2D(_TerrainNormalmapTexture, sampler_TerrainNormalmapTexture, sampleCoords).rgb * 2 - 1));
					float3 WorldTangent = -cross(GetObjectToWorldMatrix()._13_23_33, WorldNormal);
					float3 WorldBiTangent = cross(WorldNormal, -WorldTangent);
				#else
					float3 WorldNormal = normalize( IN.tSpace0.xyz );
					float3 WorldTangent = IN.tSpace1.xyz;
					float3 WorldBiTangent = IN.tSpace2.xyz;
				#endif

				float3 WorldPosition = float3(IN.tSpace0.w,IN.tSpace1.w,IN.tSpace2.w);
				float3 WorldViewDirection = _WorldSpaceCameraPos.xyz  - WorldPosition;
				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				#if defined(ASE_NEEDS_FRAG_SCREEN_POSITION)
					float4 ScreenPos = IN.screenPos;
				#endif

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
					ShadowCoords = IN.shadowCoord;
				#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
					ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
				#else
					ShadowCoords = float4(0, 0, 0, 0);
				#endif

				WorldViewDirection = SafeNormalize( WorldViewDirection );

				float T1_Tiling361 = _T1_Tiling1;
				float2 temp_cast_0 = (T1_Tiling361).xx;
				float2 texCoord61 = IN.ase_texcoord7.xy * temp_cast_0 + float2( 0,0 );
				float DebugFlipTexture528 = _FlipTexture;
				float cos518 = cos( ( DebugFlipTexture528 * PI ) );
				float sin518 = sin( ( DebugFlipTexture528 * PI ) );
				float2 rotator518 = mul( texCoord61 - float2( 0.5,0.5 ) , float2x2( cos518 , -sin518 , sin518 , cos518 )) + float2( 0.5,0.5 );
				float localStochasticTiling2_g27 = ( 0.0 );
				float2 Input_UV145_g27 = rotator518;
				float2 UV2_g27 = Input_UV145_g27;
				float2 UV12_g27 = float2( 0,0 );
				float2 UV22_g27 = float2( 0,0 );
				float2 UV32_g27 = float2( 0,0 );
				float W12_g27 = 0.0;
				float W22_g27 = 0.0;
				float W32_g27 = 0.0;
				StochasticTiling( UV2_g27 , UV12_g27 , UV22_g27 , UV32_g27 , W12_g27 , W22_g27 , W32_g27 );
				float2 temp_output_10_0_g27 = ddx( Input_UV145_g27 );
				float2 temp_output_12_0_g27 = ddy( Input_UV145_g27 );
				float4 Output_2D293_g27 = ( ( tex2D( _T1_Terrain, UV12_g27, temp_output_10_0_g27, temp_output_12_0_g27 ) * W12_g27 ) + ( tex2D( _T1_Terrain, UV22_g27, temp_output_10_0_g27, temp_output_12_0_g27 ) * W22_g27 ) + ( tex2D( _T1_Terrain, UV32_g27, temp_output_10_0_g27, temp_output_12_0_g27 ) * W32_g27 ) );
				float T1_ProceduralTiling362 = _T1_ProceduralTiling1;
				float4 lerpResult64 = lerp( tex2D( _T1_Terrain, rotator518 ) , Output_2D293_g27 , T1_ProceduralTiling362);
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
				float2 uv_TerrainMask_VertexPaint = IN.ase_texcoord7.xy * _TerrainMask_VertexPaint_ST.xy + _TerrainMask_VertexPaint_ST.zw;
				float4 tex2DNode166 = tex2D( _TerrainMask_VertexPaint, uv_TerrainMask_VertexPaint );
				float T2_Tilling363 = _T2_Tilling1;
				float2 temp_cast_3 = (T2_Tilling363).xx;
				float2 texCoord520 = IN.ase_texcoord7.xy * temp_cast_3 + float2( 0,0 );
				float cos521 = cos( ( DebugFlipTexture528 * PI ) );
				float sin521 = sin( ( DebugFlipTexture528 * PI ) );
				float2 rotator521 = mul( texCoord520 - float2( 0.5,0.5 ) , float2x2( cos521 , -sin521 , sin521 , cos521 )) + float2( 0.5,0.5 );
				float localStochasticTiling2_g26 = ( 0.0 );
				float2 Input_UV145_g26 = rotator521;
				float2 UV2_g26 = Input_UV145_g26;
				float2 UV12_g26 = float2( 0,0 );
				float2 UV22_g26 = float2( 0,0 );
				float2 UV32_g26 = float2( 0,0 );
				float W12_g26 = 0.0;
				float W22_g26 = 0.0;
				float W32_g26 = 0.0;
				StochasticTiling( UV2_g26 , UV12_g26 , UV22_g26 , UV32_g26 , W12_g26 , W22_g26 , W32_g26 );
				float2 temp_output_10_0_g26 = ddx( Input_UV145_g26 );
				float2 temp_output_12_0_g26 = ddy( Input_UV145_g26 );
				float4 Output_2D293_g26 = ( ( tex2D( _T2_Terrain, UV12_g26, temp_output_10_0_g26, temp_output_12_0_g26 ) * W12_g26 ) + ( tex2D( _T2_Terrain, UV22_g26, temp_output_10_0_g26, temp_output_12_0_g26 ) * W22_g26 ) + ( tex2D( _T2_Terrain, UV32_g26, temp_output_10_0_g26, temp_output_12_0_g26 ) * W32_g26 ) );
				float T2_ProceduralTiling364 = _T2_ProceduralTiling1;
				float4 lerpResult111 = lerp( tex2D( _T2_Terrain, rotator521 ) , Output_2D293_g26 , T2_ProceduralTiling364);
				float4 temp_output_110_0 = ( lerpResult111 * 1.0 );
				float grayscale109 = Luminance(temp_output_110_0.rgb);
				float4 temp_cast_5 = (grayscale109).xxxx;
				float4 lerpResult113 = lerp( temp_output_110_0 , temp_cast_5 , DebugGrayscale45);
				float4 T2_RGB114 = lerpResult113;
				float4 color53 = IsGammaSpace() ? float4(1,0,0.03653574,0) : float4(1,0,0.002827844,0);
				float4 DebugColor252 = color53;
				float4 lerpResult151 = lerp( T2_RGB114 , DebugColor252 , DebugVertexPainting46);
				float4 lerpResult150 = lerp( ( lerpResult147 * ( 1.0 - ( tex2DNode166.r + tex2DNode166.g + tex2DNode166.b ) ) ) , lerpResult151 , ( tex2DNode166.r * 2.0 ));
				float T3_Tilling365 = _T3_Tilling1;
				float2 temp_cast_6 = (T3_Tilling365).xx;
				float2 texCoord118 = IN.ase_texcoord7.xy * temp_cast_6 + float2( 0,0 );
				float cos524 = cos( ( DebugFlipTexture528 * PI ) );
				float sin524 = sin( ( DebugFlipTexture528 * PI ) );
				float2 rotator524 = mul( texCoord118 - float2( 0.5,0.5 ) , float2x2( cos524 , -sin524 , sin524 , cos524 )) + float2( 0.5,0.5 );
				float localStochasticTiling2_g25 = ( 0.0 );
				float2 Input_UV145_g25 = rotator524;
				float2 UV2_g25 = Input_UV145_g25;
				float2 UV12_g25 = float2( 0,0 );
				float2 UV22_g25 = float2( 0,0 );
				float2 UV32_g25 = float2( 0,0 );
				float W12_g25 = 0.0;
				float W22_g25 = 0.0;
				float W32_g25 = 0.0;
				StochasticTiling( UV2_g25 , UV12_g25 , UV22_g25 , UV32_g25 , W12_g25 , W22_g25 , W32_g25 );
				float2 temp_output_10_0_g25 = ddx( Input_UV145_g25 );
				float2 temp_output_12_0_g25 = ddy( Input_UV145_g25 );
				float4 Output_2D293_g25 = ( ( tex2D( _T3_Terrain, UV12_g25, temp_output_10_0_g25, temp_output_12_0_g25 ) * W12_g25 ) + ( tex2D( _T3_Terrain, UV22_g25, temp_output_10_0_g25, temp_output_12_0_g25 ) * W22_g25 ) + ( tex2D( _T3_Terrain, UV32_g25, temp_output_10_0_g25, temp_output_12_0_g25 ) * W32_g25 ) );
				float T3_ProceduralTiling366 = _T3_ProceduralTiling1;
				float4 lerpResult124 = lerp( tex2D( _T3_Terrain, rotator524 ) , Output_2D293_g25 , T3_ProceduralTiling366);
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
				float2 texCoord132 = IN.ase_texcoord7.xy * temp_cast_9 + float2( 0,0 );
				float cos525 = cos( ( DebugFlipTexture528 * PI ) );
				float sin525 = sin( ( DebugFlipTexture528 * PI ) );
				float2 rotator525 = mul( texCoord132 - float2( 0.5,0.5 ) , float2x2( cos525 , -sin525 , sin525 , cos525 )) + float2( 0.5,0.5 );
				float localStochasticTiling2_g24 = ( 0.0 );
				float2 Input_UV145_g24 = rotator525;
				float2 UV2_g24 = Input_UV145_g24;
				float2 UV12_g24 = float2( 0,0 );
				float2 UV22_g24 = float2( 0,0 );
				float2 UV32_g24 = float2( 0,0 );
				float W12_g24 = 0.0;
				float W22_g24 = 0.0;
				float W32_g24 = 0.0;
				StochasticTiling( UV2_g24 , UV12_g24 , UV22_g24 , UV32_g24 , W12_g24 , W22_g24 , W32_g24 );
				float2 temp_output_10_0_g24 = ddx( Input_UV145_g24 );
				float2 temp_output_12_0_g24 = ddy( Input_UV145_g24 );
				float4 Output_2D293_g24 = ( ( tex2D( _T4_Terrain, UV12_g24, temp_output_10_0_g24, temp_output_12_0_g24 ) * W12_g24 ) + ( tex2D( _T4_Terrain, UV22_g24, temp_output_10_0_g24, temp_output_12_0_g24 ) * W22_g24 ) + ( tex2D( _T4_Terrain, UV32_g24, temp_output_10_0_g24, temp_output_12_0_g24 ) * W32_g24 ) );
				float T4_ProceduralTiling367 = _T4_ProceduralTiling1;
				float4 lerpResult137 = lerp( tex2D( _T4_Terrain, rotator525 ) , Output_2D293_g24 , T4_ProceduralTiling367);
				float4 temp_output_136_0 = ( lerpResult137 * 1.0 );
				float grayscale135 = Luminance(temp_output_136_0.rgb);
				float4 temp_cast_11 = (grayscale135).xxxx;
				float4 lerpResult139 = lerp( temp_output_136_0 , temp_cast_11 , DebugGrayscale45);
				float4 T4_RGB144 = lerpResult139;
				float4 color56 = IsGammaSpace() ? float4(0.00126791,0,1,0) : float4(9.813545E-05,0,1,0);
				float4 DebugColor457 = color56;
				float4 lerpResult161 = lerp( T4_RGB144 , DebugColor457 , DebugVertexPainting46);
				float4 lerpResult165 = lerp( lerpResult155 , lerpResult161 , ( tex2DNode166.b * 2.0 ));
				float4 AllAlbedoCombined168 = lerpResult165;
				float4 lerpResult425 = lerp( T1_RGB71 , DebugColor151 , DebugVertexPainting46);
				float4 break187 = saturate( ( IN.ase_color * 2.0 ) );
				float4 lerpResult431 = lerp( T2_RGB114 , DebugColor252 , DebugVertexPainting46);
				float4 lerpResult408 = lerp( ( lerpResult425 * ( 1.0 - saturate( ( break187.r + break187.g + break187.b ) ) ) ) , ( break187.r * lerpResult431 ) , break187.r);
				float4 lerpResult434 = lerp( T3_RGB130 , DebugColor354 , DebugVertexPainting46);
				float4 lerpResult409 = lerp( lerpResult408 , ( break187.g * lerpResult434 ) , break187.g);
				float4 lerpResult438 = lerp( T4_RGB144 , DebugColor457 , DebugVertexPainting46);
				float4 lerpResult410 = lerp( lerpResult409 , ( break187.b * lerpResult438 ) , break187.b);
				float4 AllAlbedoVertexPaint208 = lerpResult410;
				float UseVertexPainting445 = _UseVertexPainting;
				float4 lerpResult446 = lerp( AllAlbedoCombined168 , AllAlbedoVertexPaint208 , UseVertexPainting445);
				float BPColorIntensity484 = _ColorIntensity;
				float4 BPMainTint489 = _MainTint;
				float3 color500 = ( ( lerpResult446 * BPColorIntensity484 ) * BPMainTint489 ).rgb;
				float minInput500 = 0.0;
				float DebugThreshold502 = _ThresholdDebug;
				float gamma500 = DebugThreshold502;
				float maxInput500 = 1.0;
				float3 localfinalLevels500 = finalLevels( color500 , minInput500 , gamma500 , maxInput500 );
				float DebugDesaturate507 = _DesaturateDebug;
				float3 desaturateInitialColor505 = localfinalLevels500;
				float desaturateDot505 = dot( desaturateInitialColor505, float3( 0.299, 0.587, 0.114 ));
				float3 desaturateVar505 = lerp( desaturateInitialColor505, desaturateDot505.xxx, DebugDesaturate507 );
				float localStochasticTiling2_g20 = ( 0.0 );
				float2 temp_cast_14 = (T1_Tiling361).xx;
				float2 texCoord257 = IN.ase_texcoord7.xy * temp_cast_14 + float2( 0,0 );
				float cos509 = cos( ( DebugFlipTexture528 * PI ) );
				float sin509 = sin( ( DebugFlipTexture528 * PI ) );
				float2 rotator509 = mul( texCoord257 - float2( 0.5,0.5 ) , float2x2( cos509 , -sin509 , sin509 , cos509 )) + float2( 0.5,0.5 );
				float2 Input_UV145_g20 = rotator509;
				float2 UV2_g20 = Input_UV145_g20;
				float2 UV12_g20 = float2( 0,0 );
				float2 UV22_g20 = float2( 0,0 );
				float2 UV32_g20 = float2( 0,0 );
				float W12_g20 = 0.0;
				float W22_g20 = 0.0;
				float W32_g20 = 0.0;
				StochasticTiling( UV2_g20 , UV12_g20 , UV22_g20 , UV32_g20 , W12_g20 , W22_g20 , W32_g20 );
				float2 temp_output_10_0_g20 = ddx( Input_UV145_g20 );
				float2 temp_output_12_0_g20 = ddy( Input_UV145_g20 );
				float4 Output_2D293_g20 = ( ( tex2D( _T1_TerrainNAOH, UV12_g20, temp_output_10_0_g20, temp_output_12_0_g20 ) * W12_g20 ) + ( tex2D( _T1_TerrainNAOH, UV22_g20, temp_output_10_0_g20, temp_output_12_0_g20 ) * W22_g20 ) + ( tex2D( _T1_TerrainNAOH, UV32_g20, temp_output_10_0_g20, temp_output_12_0_g20 ) * W32_g20 ) );
				float4 lerpResult260 = lerp( Output_2D293_g20 , tex2D( _T1_TerrainNAOH, rotator509 ) , T1_ProceduralTiling362);
				float4 T1_NAOH262 = lerpResult260;
				float localStochasticTiling2_g21 = ( 0.0 );
				float2 temp_cast_15 = (T2_Tilling363).xx;
				float2 texCoord274 = IN.ase_texcoord7.xy * temp_cast_15 + float2( 0,0 );
				float cos511 = cos( ( DebugFlipTexture528 * PI ) );
				float sin511 = sin( ( DebugFlipTexture528 * PI ) );
				float2 rotator511 = mul( texCoord274 - float2( 0.5,0.5 ) , float2x2( cos511 , -sin511 , sin511 , cos511 )) + float2( 0.5,0.5 );
				float2 Input_UV145_g21 = rotator511;
				float2 UV2_g21 = Input_UV145_g21;
				float2 UV12_g21 = float2( 0,0 );
				float2 UV22_g21 = float2( 0,0 );
				float2 UV32_g21 = float2( 0,0 );
				float W12_g21 = 0.0;
				float W22_g21 = 0.0;
				float W32_g21 = 0.0;
				StochasticTiling( UV2_g21 , UV12_g21 , UV22_g21 , UV32_g21 , W12_g21 , W22_g21 , W32_g21 );
				float2 temp_output_10_0_g21 = ddx( Input_UV145_g21 );
				float2 temp_output_12_0_g21 = ddy( Input_UV145_g21 );
				float4 Output_2D293_g21 = ( ( tex2D( _T2_TerrainNAOH, UV12_g21, temp_output_10_0_g21, temp_output_12_0_g21 ) * W12_g21 ) + ( tex2D( _T2_TerrainNAOH, UV22_g21, temp_output_10_0_g21, temp_output_12_0_g21 ) * W22_g21 ) + ( tex2D( _T2_TerrainNAOH, UV32_g21, temp_output_10_0_g21, temp_output_12_0_g21 ) * W32_g21 ) );
				float4 lerpResult267 = lerp( Output_2D293_g21 , tex2D( _T2_TerrainNAOH, rotator511 ) , T2_ProceduralTiling364);
				float4 T2_NAOH268 = lerpResult267;
				float4 tex2DNode322 = tex2D( _TerrainMask_VertexPaint, uv_TerrainMask_VertexPaint );
				float4 lerpResult327 = lerp( T1_NAOH262 , T2_NAOH268 , ( tex2DNode322.r * 2.0 ));
				float localStochasticTiling2_g22 = ( 0.0 );
				float2 temp_cast_16 = (T3_Tilling365).xx;
				float2 texCoord287 = IN.ase_texcoord7.xy * temp_cast_16 + float2( 0,0 );
				float cos513 = cos( ( DebugFlipTexture528 * PI ) );
				float sin513 = sin( ( DebugFlipTexture528 * PI ) );
				float2 rotator513 = mul( texCoord287 - float2( 0.5,0.5 ) , float2x2( cos513 , -sin513 , sin513 , cos513 )) + float2( 0.5,0.5 );
				float2 Input_UV145_g22 = rotator513;
				float2 UV2_g22 = Input_UV145_g22;
				float2 UV12_g22 = float2( 0,0 );
				float2 UV22_g22 = float2( 0,0 );
				float2 UV32_g22 = float2( 0,0 );
				float W12_g22 = 0.0;
				float W22_g22 = 0.0;
				float W32_g22 = 0.0;
				StochasticTiling( UV2_g22 , UV12_g22 , UV22_g22 , UV32_g22 , W12_g22 , W22_g22 , W32_g22 );
				float2 temp_output_10_0_g22 = ddx( Input_UV145_g22 );
				float2 temp_output_12_0_g22 = ddy( Input_UV145_g22 );
				float4 Output_2D293_g22 = ( ( tex2D( _T3_TerrainNAOH, UV12_g22, temp_output_10_0_g22, temp_output_12_0_g22 ) * W12_g22 ) + ( tex2D( _T3_TerrainNAOH, UV22_g22, temp_output_10_0_g22, temp_output_12_0_g22 ) * W22_g22 ) + ( tex2D( _T3_TerrainNAOH, UV32_g22, temp_output_10_0_g22, temp_output_12_0_g22 ) * W32_g22 ) );
				float4 lerpResult281 = lerp( Output_2D293_g22 , tex2D( _T3_TerrainNAOH, rotator513 ) , T3_ProceduralTiling366);
				float4 T3_NAOH305 = lerpResult281;
				float4 lerpResult311 = lerp( lerpResult327 , T3_NAOH305 , ( tex2DNode322.g * 2.0 ));
				float localStochasticTiling2_g23 = ( 0.0 );
				float2 temp_cast_17 = (T4_Tilling368).xx;
				float2 texCoord515 = IN.ase_texcoord7.xy * temp_cast_17 + float2( 0,0 );
				float cos516 = cos( ( DebugFlipTexture528 * PI ) );
				float sin516 = sin( ( DebugFlipTexture528 * PI ) );
				float2 rotator516 = mul( texCoord515 - float2( 0.5,0.5 ) , float2x2( cos516 , -sin516 , sin516 , cos516 )) + float2( 0.5,0.5 );
				float2 Input_UV145_g23 = rotator516;
				float2 UV2_g23 = Input_UV145_g23;
				float2 UV12_g23 = float2( 0,0 );
				float2 UV22_g23 = float2( 0,0 );
				float2 UV32_g23 = float2( 0,0 );
				float W12_g23 = 0.0;
				float W22_g23 = 0.0;
				float W32_g23 = 0.0;
				StochasticTiling( UV2_g23 , UV12_g23 , UV22_g23 , UV32_g23 , W12_g23 , W22_g23 , W32_g23 );
				float2 temp_output_10_0_g23 = ddx( Input_UV145_g23 );
				float2 temp_output_12_0_g23 = ddy( Input_UV145_g23 );
				float4 Output_2D293_g23 = ( ( tex2D( _T4_TerrainNAOH, UV12_g23, temp_output_10_0_g23, temp_output_12_0_g23 ) * W12_g23 ) + ( tex2D( _T4_TerrainNAOH, UV22_g23, temp_output_10_0_g23, temp_output_12_0_g23 ) * W22_g23 ) + ( tex2D( _T4_TerrainNAOH, UV32_g23, temp_output_10_0_g23, temp_output_12_0_g23 ) * W32_g23 ) );
				float4 lerpResult294 = lerp( Output_2D293_g23 , tex2D( _T4_TerrainNAOH, rotator516 ) , T4_ProceduralTiling367);
				float4 T4_NAOH306 = lerpResult294;
				float4 lerpResult320 = lerp( lerpResult311 , T4_NAOH306 , ( tex2DNode322.b * 2.0 ));
				float4 AllNormal_Combined321 = lerpResult320;
				float DebugNormal43 = _NormalDebug;
				float4 lerpResult348 = lerp( float4( desaturateVar505 , 0.0 ) , AllNormal_Combined321 , DebugNormal43);
				
				float4 break462 = AllNormal_Combined321;
				float2 appendResult464 = (float2(break462.r , break462.g));
				float2 temp_output_1_0_g19 = appendResult464;
				float dotResult4_g19 = dot( temp_output_1_0_g19 , temp_output_1_0_g19 );
				float3 appendResult10_g19 = (float3((temp_output_1_0_g19).x , (temp_output_1_0_g19).y , sqrt( ( 1.0 - saturate( dotResult4_g19 ) ) )));
				float3 normalizeResult12_g19 = normalize( appendResult10_g19 );
				
				float BPMetallic493 = _Metallic;
				
				float BPSmoothness492 = _Smoothness;
				

				float3 BaseColor = lerpResult348.rgb;
				float3 Normal = ( IN.ase_normal + normalizeResult12_g19 );
				float3 Emission = 0;
				float3 Specular = 0.5;
				float Metallic = BPMetallic493;
				float Smoothness = BPSmoothness492;
				float Occlusion = 1;
				float Alpha = 1;
				float AlphaClipThreshold = 0.5;
				float AlphaClipThresholdShadow = 0.5;
				float3 BakedGI = 0;
				float3 RefractionColor = 1;
				float RefractionIndex = 1;
				float3 Transmission = 1;
				float3 Translucency = 1;

				#ifdef ASE_DEPTH_WRITE_ON
					float DepthValue = 0;
				#endif

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				InputData inputData;
				inputData.positionWS = WorldPosition;
				inputData.viewDirectionWS = WorldViewDirection;
				inputData.shadowCoord = ShadowCoords;

				#ifdef _NORMALMAP
					#if _NORMAL_DROPOFF_TS
					inputData.normalWS = TransformTangentToWorld(Normal, half3x3( WorldTangent, WorldBiTangent, WorldNormal ));
					#elif _NORMAL_DROPOFF_OS
					inputData.normalWS = TransformObjectToWorldNormal(Normal);
					#elif _NORMAL_DROPOFF_WS
					inputData.normalWS = Normal;
					#endif
					inputData.normalWS = NormalizeNormalPerPixel(inputData.normalWS);
				#else
					inputData.normalWS = WorldNormal;
				#endif

				#ifdef ASE_FOG
					inputData.fogCoord = 0; // we don't apply fog in the gbuffer pass
				#endif

				inputData.vertexLighting = IN.fogFactorAndVertexLight.yzw;
				#if defined(ENABLE_TERRAIN_PERPIXEL_NORMAL)
					float3 SH = SampleSH(inputData.normalWS.xyz);
				#else
					float3 SH = IN.lightmapUVOrVertexSH.xyz;
				#endif

				inputData.bakedGI = SAMPLE_GI( IN.lightmapUVOrVertexSH.xy, SH, inputData.normalWS );

				#ifdef ASE_BAKEDGI
					inputData.bakedGI = BakedGI;
				#endif

				BRDFData brdfData;
				InitializeBRDFData( BaseColor, Metallic, Specular, Smoothness, Alpha, brdfData);
				half4 color;
				color.rgb = GlobalIllumination( brdfData, inputData.bakedGI, Occlusion, inputData.normalWS, inputData.viewDirectionWS);
				color.a = Alpha;

				#ifdef ASE_FINAL_COLOR_ALPHA_MULTIPLY
					color.rgb *= color.a;
				#endif

				#ifdef ASE_FOG
					#ifdef TERRAIN_SPLAT_ADDPASS
						color.rgb = MixFogColor(color.rgb, half3( 0, 0, 0 ), IN.fogFactorAndVertexLight.x );
					#else
						color.rgb = MixFog(color.rgb, IN.fogFactorAndVertexLight.x);
					#endif
				#endif

				#ifdef ASE_DEPTH_WRITE_ON
					outputDepth = DepthValue;
				#endif

				return BRDFDataToGbuffer(brdfData, inputData, Smoothness, Emission + color.rgb);
			}

			ENDHLSL
		}
		
	}
	
	CustomEditor "UnityEditor.ShaderGraph.PBRMasterGUI"
	Fallback "Hidden/InternalErrorShader"
	
}
/*ASEBEGIN
Version=19102
Node;AmplifyShaderEditor.CommentaryNode;497;-8242,1950;Inherit;False;668;502;Basic Properties;8;483;489;484;488;492;494;493;491;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;369;-6718.006,1593.694;Inherit;False;627.9141;949.764;Tiling Controller Texture;16;359;360;357;358;361;362;363;364;353;368;355;367;356;366;354;365;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;308;-4274,-2482;Inherit;False;3709.769;2808;Texture RGBA;8;72;16;23;29;35;102;117;131;;1,0.4661931,0,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;307;-7498.852,-2491.554;Inherit;False;3081.05;2439.487;NAOH NormalMap Ambiant Occlusion Height;8;264;171;265;266;279;280;292;293;;0.1278601,0.1179245,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;264;-6154.443,-2441.554;Inherit;False;1683.34;546.8347;NAOH Texture 1;11;255;257;259;256;260;262;378;379;509;510;529;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;245;-2896,1632;Inherit;False;2588.93;1273.907;Vertex Painting;37;436;437;435;434;408;195;409;208;438;441;440;439;193;410;197;433;432;430;422;424;431;423;421;190;188;189;187;186;426;429;425;200;469;470;472;471;477;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;169;-2928,352;Inherit;False;1975.007;1179.899;Texture Set By Vertex Color;26;147;148;146;149;150;151;153;152;154;155;157;160;161;164;158;159;162;163;165;166;168;400;401;402;415;420;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;145;-7363.855,1570.608;Inherit;False;596.9399;1365.478;Other Parameters;2;41;48;;0,0,0,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;72;-2944,-2432;Inherit;False;2313.769;659.8782;Albedo Texture 1;16;58;61;59;63;67;68;66;64;70;69;71;376;399;518;519;536;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;48;-7344,2336;Inherit;False;497;798.0001;Debug Vertex Color;8;57;56;55;54;52;53;50;51;;0.571486,0,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;41;-7354.855,1616.608;Inherit;False;575;691;Debug Variables;16;528;527;507;45;506;501;502;443;442;445;444;43;42;47;46;44;;0.5367103,0,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;16;-4224,-2432;Inherit;False;1202;443;Textures Terrain 1;5;10;11;12;15;22;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;23;-4208,-1744;Inherit;False;1202;443;Textures Terrain 2;5;28;26;25;24;27;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;29;-4208,-1024;Inherit;False;1202;443;Textures Terrain 3;5;34;33;32;31;30;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;35;-4224,-336;Inherit;False;1202;443;Textures Terrain 4;5;40;39;38;37;36;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;102;-2944,-1744;Inherit;False;2327.893;662.2322;Albedo Texture 2;16;535;522;521;112;375;105;520;106;113;111;110;109;108;103;374;114;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;117;-2939.117,-1040;Inherit;False;2324.886;661.731;Albedo Texture 3;16;534;524;523;372;118;129;119;373;124;121;125;122;123;130;126;127;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;131;-2944,-336;Inherit;False;2313.769;659.8782;Albedo Texture 4;16;144;141;140;139;138;137;136;135;134;133;132;370;371;525;526;533;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;171;-7440.185,-2439.427;Inherit;False;1202;443;Textures Terrain NAOH 1;4;175;174;173;172;;1,1,1,1;0;0
Node;AmplifyShaderEditor.StickyNoteNode;181;-2917.163,-2896.279;Inherit;False;567.8623;332.1456;A demande au GA;;1,1,1,1;Demander les maps dont ils ont besoin pour pouvoir préparer le packing$;0;0
Node;AmplifyShaderEditor.CommentaryNode;265;-6151.142,-1833.533;Inherit;False;1683.34;546.8347;NAOH Texture 2;11;277;274;273;276;380;381;267;268;511;512;530;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;266;-7436.889,-1831.406;Inherit;False;1202;443;Textures Terrain NAOH 2;4;272;271;270;269;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;279;-6163.107,-1206.923;Inherit;False;1683.34;546.8347;NAOH Texture 1;11;305;290;289;287;286;281;382;383;513;514;531;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;280;-7448.852,-1204.796;Inherit;False;1202;443;Textures Terrain NAOH 3;4;285;284;283;282;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;292;-6159.807,-598.9022;Inherit;False;1683.34;546.8347;NAOH Texture 2;9;306;304;299;298;294;384;385;516;532;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;293;-7445.556,-596.7753;Inherit;False;1202;443;Textures Terrain NAOH 2;4;303;302;301;295;;1,1,1,1;0;0
Node;AmplifyShaderEditor.LerpOp;260;-4908.784,-2384.201;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;174;-6880.184,-2375.427;Inherit;True;Property;_T_1_TextureSample1;T_1_Texture Sample;1;0;Create;True;0;0;0;False;0;False;10;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexturePropertyNode;173;-7392.185,-2375.427;Inherit;True;Property;_T1_TerrainNAOH;T1_Terrain NAOH;11;0;Create;True;0;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RegisterLocalVarNode;175;-7104.185,-2375.427;Inherit;False;T1_NAOH_Textures;-1;True;1;0;SAMPLER2D;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.GetLocalVarNode;255;-6064.195,-2391.554;Inherit;False;175;T1_NAOH_Textures;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.TexturePropertyNode;271;-7388.889,-1767.406;Inherit;True;Property;_T2_TerrainNAOH;T2_Terrain NAOH;15;0;Create;True;0;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SamplerNode;270;-6876.883,-1767.406;Inherit;True;Property;_T_2__NAOH_TextureSample;T_2__NAOH_Texture Sample;1;0;Create;True;0;0;0;False;0;False;10;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;272;-7100.887,-1767.406;Inherit;False;T2_NAOH_Textures;-1;True;1;0;SAMPLER2D;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.GetLocalVarNode;273;-6060.894,-1783.533;Inherit;False;272;T2_NAOH_Textures;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;262;-4695.102,-2390.745;Inherit;False;T1_NAOH;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;281;-4917.449,-1149.569;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;282;-7384.852,-932.7963;Inherit;False;0;10;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;283;-6888.849,-1140.796;Inherit;True;Property;_T__TextureSample2;T_1_Texture Sample;1;0;Create;True;0;0;0;False;0;False;10;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;294;-4914.147,-541.5482;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;295;-7381.556,-324.7751;Inherit;False;0;10;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;302;-6885.547,-532.7753;Inherit;True;Property;_T_4__NAOH_TextureSample;T_4__NAOH_Texture Sample;1;0;Create;True;0;0;0;False;0;False;10;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;269;-7380.492,-1563.958;Inherit;False;0;10;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;285;-7112.852,-1140.796;Inherit;False;T3_NAOH_Textures;-1;True;1;0;SAMPLER2D;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.TexturePropertyNode;284;-7400.852,-1140.796;Inherit;True;Property;_T3_TerrainNAOH;T3_Terrain NAOH;19;0;Create;True;0;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.TexturePropertyNode;301;-7397.556,-532.7753;Inherit;True;Property;_T4_TerrainNAOH;T4_Terrain NAOH;23;0;Create;True;0;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RegisterLocalVarNode;303;-7109.554,-532.7753;Inherit;False;T4_NAOH_Textures;-1;True;1;0;SAMPLER2D;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.GetLocalVarNode;304;-6069.559,-548.9022;Inherit;False;303;T4_NAOH_Textures;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.GetLocalVarNode;286;-6072.859,-1156.923;Inherit;False;285;T3_NAOH_Textures;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;305;-4703.767,-1156.114;Inherit;False;T3_NAOH;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;306;-4700.465,-548.0933;Inherit;False;T4_NAOH;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;12;-3664,-2368;Inherit;True;Property;_T_1_TextureSample;T_1_Texture Sample;1;0;Create;True;0;0;0;False;0;False;10;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;11;-3888,-2368;Inherit;False;T1_Textures;-1;True;1;0;SAMPLER2D;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.TexturePropertyNode;10;-4176,-2368;Inherit;True;Property;_T1_Terrain;T1_Terrain;10;1;[Header];Create;True;1;Texture 1 Vertex Paint Black;0;0;False;0;False;None;4f359a34160143c49b2a6bf43e1a5e42;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SamplerNode;26;-3648,-1696;Inherit;True;Property;_T_2_TextureSample;T_2_Texture Sample;1;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;34;-3648,-976;Inherit;True;Property;_T_3_TextureSample;T_3_Texture Sample;1;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;28;-4144,-1488;Inherit;False;0;24;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;31;-4144,-768;Inherit;False;0;33;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;30;-3872,-976;Inherit;False;T3_Textures;-1;True;1;0;SAMPLER2D;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;25;-3872,-1696;Inherit;False;T2_Textures;-1;True;1;0;SAMPLER2D;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.SamplerNode;39;-3664,-288;Inherit;True;Property;_T_4_TextureSample;T_4_Texture Sample;1;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;36;-4160,-80;Inherit;False;0;38;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;40;-3888,-288;Inherit;False;T4_Textures;-1;True;1;0;SAMPLER2D;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.TexturePropertyNode;24;-4160,-1696;Inherit;True;Property;_T2_Terrain;T2_Terrain;14;1;[Header];Create;True;1;Texture 2 Vertex Paint Red;0;0;False;0;False;None;ceb1bacd3e5dc9b4cb4b85eb1a74cfb6;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.TexturePropertyNode;33;-4160,-976;Inherit;True;Property;_T3_Terrain;T3_Terrain;18;1;[Header];Create;True;1;Texture 3 Vertex Paint Green;0;0;False;0;False;None;67574e7a5a39fb54eaef3c4efe768356;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.TexturePropertyNode;38;-4176,-288;Inherit;True;Property;_T4_Terrain;T4_Terrain;22;1;[Header];Create;True;1;Texture 4 Vertex Paint Blue;0;0;False;0;False;None;401bbb72c9170f343bd105e06e7880b0;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RegisterLocalVarNode;27;-3248,-1696;Inherit;False;T2_Albedo_Texture;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;32;-3248,-976;Inherit;False;T3_Albedo_Texture;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;37;-3264,-288;Inherit;False;T4_Albedo_Texture;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;15;-3262,-2368;Inherit;False;T1_Albedo_Texture;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;154;-2880,880;Inherit;False;46;DebugVertexPainting;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;157;-2160,848;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;158;-2432,848;Inherit;False;130;T3_RGB;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;159;-2448,944;Inherit;False;54;DebugColor3;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;165;-1520,1168;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;147;-2544,400;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;148;-2832,496;Inherit;False;51;DebugColor1;1;0;OBJECT;;False;1;COLOR;0
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
Node;AmplifyShaderEditor.RegisterLocalVarNode;54;-7056,2752;Inherit;False;DebugColor3;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;55;-7328,2752;Inherit;False;Constant;_DebugColor3;DebugColor3;7;0;Create;True;0;0;0;False;0;False;0,1,0.002223969,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;51;-7056,2384;Inherit;False;DebugColor1;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;52;-7056,2576;Inherit;False;DebugColor2;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;53;-7328,2576;Inherit;False;Constant;_DebugColor2;DebugColor2;7;0;Create;True;0;0;0;False;0;False;1,0,0.03653574,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;358;-6665.716,1945.657;Inherit;False;Property;_T2_ProceduralTiling1;T2_ProceduralTiling;17;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;361;-6352.836,1643.694;Inherit;False;T1_Tiling;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;362;-6344.511,1748.987;Inherit;False;T1_ProceduralTiling;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;363;-6344.674,1850.34;Inherit;False;T2_Tilling;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;364;-6342.349,1945.634;Inherit;False;T2_ProceduralTiling;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;353;-6667.991,2426.709;Inherit;False;Property;_T4_Tilling1;T4_Tilling;24;0;Create;True;0;0;0;False;0;False;10;17.6;0;100;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;368;-6342.768,2427.458;Inherit;False;T4_Tilling;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;355;-6665.968,2332.409;Inherit;False;Property;_T4_ProceduralTiling1;T4_ProceduralTiling;25;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;367;-6341.092,2330.164;Inherit;False;T4_ProceduralTiling;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;356;-6668.006,2167.737;Inherit;False;Property;_T3_ProceduralTiling1;T3_ProceduralTiling;21;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;366;-6343.93,2168.811;Inherit;False;T3_ProceduralTiling;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;354;-6665.441,2078.236;Inherit;False;Property;_T3_Tilling1;T3_Tilling;20;0;Create;True;0;0;0;False;0;False;10;42;1;100;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;365;-6344.255,2077.517;Inherit;False;T3_Tilling;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;360;-6666.716,1748.657;Inherit;False;Property;_T1_ProceduralTiling1;T1_ProceduralTiling;13;0;Create;True;0;0;0;False;0;False;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;359;-6666.716,1644.657;Inherit;False;Property;_T1_Tiling1;T1_Tiling;12;0;Create;True;0;0;0;False;0;False;10;14.5;1;100;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;172;-7376.185,-2167.427;Inherit;False;0;10;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;22;-4160,-2160;Inherit;False;0;10;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;325;-7204.588,224.8281;Inherit;False;262;T1_NAOH;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;160;-2496,1040;Inherit;False;46;DebugVertexPainting;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;166;-2909,1282;Inherit;True;Property;_TerrainMask_VertexPaint;TerrainMask_VertexPaint;9;1;[Header];Create;True;1;Terrain Mask;0;0;False;0;False;-1;None;61bcabd8649009f41850e63708dd1066;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;322;-7536,848;Inherit;True;Property;_TerrainMask_VertexPaint1;TerrainMask_VertexPaint;9;1;[Header];Create;True;1;Terrain Mask;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;166;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;403;-7104,928;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;404;-7100.706,818.3354;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;405;-7104,704;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;155;-1904,832;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;357;-6667.716,1850.657;Inherit;False;Property;_T2_Tilling1;T2_Tilling;16;0;Create;True;0;0;0;False;0;False;10;6.6;1;100;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;168;-1158,1170;Inherit;False;AllAlbedoCombined;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;146;-2816,400;Inherit;False;71;T1_RGB;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;419;-2448.437,564.0206;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;420;-2615.78,592.8457;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;402;-2391.693,1401.077;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;401;-2391.693,1305.077;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;400;-2394.583,1184.075;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;415;-2670.039,1025.11;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;56;-7328,2960;Inherit;False;Constant;_DebugColor4;DebugColor4;7;0;Create;True;0;0;0;False;0;False;0.00126791,0,1,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;57;-7056,2960;Inherit;False;DebugColor4;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;161;-1808,1184;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;164;-2144,1376;Inherit;False;46;DebugVertexPainting;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;162;-2080,1184;Inherit;False;144;T4_RGB;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;163;-2112,1280;Inherit;False;57;DebugColor4;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;321;-5786.588,793.8281;Inherit;False;AllNormal_Combined;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;200;-2240,1664;Inherit;False;71;T1_RGB;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;425;-1952,1664;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;429;-2256,1744;Inherit;False;51;DebugColor1;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;426;-2304,1824;Inherit;False;46;DebugVertexPainting;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;186;-2512,2144;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.BreakToComponentsNode;187;-2352,2144;Inherit;False;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;189;-2672,2144;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.VertexColorNode;188;-2848,2144;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;190;-2832,2336;Inherit;False;Constant;_Float4;Float 0;0;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;421;-2192,1920;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;423;-2000,1920;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;431;-1792,2096;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;424;-1648,1904;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;422;-1840,1920;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;430;-2064,2096;Inherit;False;114;T2_RGB;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;432;-2080,2176;Inherit;False;52;DebugColor2;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;433;-2128,2256;Inherit;False;46;DebugVertexPainting;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;197;-1520,2080;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;410;-768,2560;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;193;-944,2592;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;439;-1408,2672;Inherit;False;144;T4_RGB;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;440;-1424,2752;Inherit;False;57;DebugColor4;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;441;-1472,2832;Inherit;False;46;DebugVertexPainting;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;438;-1136,2672;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;409;-1024,2304;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;195;-1264,2320;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;408;-1280,2048;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;434;-1536,2336;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;435;-1808,2336;Inherit;False;130;T3_RGB;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;437;-1872,2496;Inherit;False;46;DebugVertexPainting;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;436;-1824,2416;Inherit;False;54;DebugColor3;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;208;-528,2560;Inherit;False;AllAlbedoVertexPaint;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;469;-2199.862,2562.452;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;470;-2122.261,2595.852;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;472;-1921.517,2633.931;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;471;-2205.517,2585.931;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;473;-2171.517,2354.931;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;475;-2169.517,2321.931;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;476;-2123.517,2368.931;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;477;-2121.517,2339.931;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;479;-2176.517,2126.931;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;478;-2148.517,2107.931;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;481;-2166.517,2163.931;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;480;-1334.517,2162.931;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BlendOpsNode;254;368,-1792;Inherit;False;Overlay;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;446;384,-1920;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;210;-80,-1760;Inherit;False;208;AllAlbedoVertexPaint;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;448;-112,-2000;Inherit;False;445;UseVertexPainting;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;183;-80,-1904;Inherit;False;168;AllAlbedoCombined;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;483;-8096,2176;Inherit;False;Property;_ColorIntensity;Color Intensity;8;0;Create;True;0;0;0;False;0;False;2;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;489;-7808,2000;Inherit;False;BPMainTint;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;484;-7808,2176;Inherit;False;BPColorIntensity;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;488;-8128,2000;Inherit;False;Property;_MainTint;MainTint;7;1;[Header];Create;True;1;Main Property Material;0;0;False;0;False;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;492;-7808,2256;Inherit;False;BPSmoothness;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;494;-8192,2336;Inherit;False;Property;_Metallic;Metallic;27;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;493;-7808,2336;Inherit;False;BPMetallic;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;491;-8192,2256;Inherit;False;Property;_Smoothness;Smoothness;26;1;[Header];Create;True;1;Others Properties;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;348;1936,-1920;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;452;2208,-1920;Float;False;True;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;12;S_Map_V1;94348b07e5e8bab40bd6c8a1e3df54cd;True;Forward;0;1;Forward;18;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;5;True;12;all;0;False;True;1;1;False;;0;False;;1;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;1;LightMode=UniversalForward;False;False;0;Hidden/InternalErrorShader;0;0;Standard;38;Workflow;1;0;Surface;0;0;  Refraction Model;0;0;  Blend;0;0;Two Sided;1;0;Fragment Normal Space,InvertActionOnDeselection;0;0;Transmission;0;0;  Transmission Shadow;0.5,False,;0;Translucency;0;0;  Translucency Strength;1,False,;0;  Normal Distortion;0.5,False,;0;  Scattering;2,False,;0;  Direct;0.9,False,;0;  Ambient;0.1,False,;0;  Shadow;0.5,False,;0;Cast Shadows;1;0;  Use Shadow Threshold;0;0;Receive Shadows;1;0;GPU Instancing;1;0;LOD CrossFade;1;0;Built-in Fog;1;0;_FinalColorxAlpha;0;0;Meta Pass;1;0;Override Baked GI;0;0;Extra Pre Pass;0;0;DOTS Instancing;0;0;Tessellation;0;0;  Phong;0;0;  Strength;0.5,False,;0;  Type;0;0;  Tess;16,False,;0;  Min;10,False,;0;  Max;25,False,;0;  Edge Length;16,False,;0;  Max Displacement;25,False,;0;Write Depth;0;0;  Early Z;0;0;Vertex Position,InvertActionOnDeselection;1;0;0;8;False;True;True;True;True;True;True;True;False;;False;0
Node;AmplifyShaderEditor.DynamicAppendNode;464;1712,-1296;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.NormalVertexDataNode;465;1904,-1440;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;461;1296,-1296;Inherit;False;321;AllNormal_Combined;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;467;2112,-1392;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.BreakToComponentsNode;462;1568,-1296;Inherit;False;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.GetLocalVarNode;349;1616,-1808;Inherit;False;321;AllNormal_Combined;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;351;1648,-1712;Inherit;False;43;DebugNormal;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;468;1872,-1296;Inherit;False;Normal Reconstruct Z;-1;;19;63ba85b764ae0c84ab3d698b86364ae9;0;1;1;FLOAT2;0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;498;1920,-1808;Inherit;False;493;BPMetallic;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;499;1904,-1728;Inherit;False;492;BPSmoothness;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;50;-7328,2384;Inherit;False;Constant;_DebugColor1;DebugColor1;7;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;449;784,-2304;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;486;1040,-2304;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CustomExpressionNode;500;1232,-2304;Inherit;False; ;3;File;4;False;color;FLOAT3;0,0,0;In;;Inherit;False;True;minInput;FLOAT;0;In;;Inherit;False;False;gamma;FLOAT;0;In;;Inherit;False;True;maxInput;FLOAT;1;In;;Inherit;False;finalLevels;False;False;0;05d8b0a5b46d3cc49b597cf56a96d39d;False;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;453;1538.501,-1918.614;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;1;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;ShadowCaster;0;2;ShadowCaster;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;False;False;True;False;False;False;False;0;False;;False;False;False;False;False;False;False;False;False;True;1;False;;True;3;False;;False;True;1;LightMode=ShadowCaster;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;454;1538.501,-1918.614;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;1;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;DepthOnly;0;3;DepthOnly;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;False;False;True;False;False;False;False;0;False;;False;False;False;False;False;False;False;False;False;True;1;False;;False;False;True;1;LightMode=DepthOnly;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;455;1538.501,-1918.614;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;1;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;Meta;0;4;Meta;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Meta;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;456;1538.501,-1918.614;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;1;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;Universal2D;0;5;Universal2D;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;5;True;12;all;0;False;True;1;1;False;;0;False;;1;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;False;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;1;LightMode=Universal2D;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;457;1538.501,-1918.614;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;1;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;DepthNormals;0;6;DepthNormals;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;5;True;12;all;0;False;True;1;1;False;;0;False;;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;;True;3;False;;False;True;1;LightMode=DepthNormals;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;458;1538.501,-1918.614;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;1;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;GBuffer;0;7;GBuffer;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;5;True;12;all;0;False;True;1;1;False;;0;False;;1;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;1;LightMode=UniversalGBuffer;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;451;1680,-2160;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;1;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;ExtraPrePass;0;0;ExtraPrePass;5;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;5;True;12;all;0;False;True;1;1;False;;0;False;;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;0;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.DesaturateOpNode;505;1520,-2304;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;44;-7338.72,1662.194;Inherit;False;Property;_GrayscaleDebug;GrayscaleDebug;2;1;[Header];Create;True;1;Debug Mode;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;46;-7040,1824;Inherit;False;DebugVertexPainting;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;47;-7344,1824;Inherit;False;Property;_VertexPaintDebug;VertexPaintDebug;6;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;42;-7344,1904;Inherit;False;Property;_NormalDebug;NormalDebug;5;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;43;-7040,1904;Inherit;False;DebugNormal;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;444;-7344,1984;Inherit;False;Property;_UseVertexPainting;UseVertexPainting;1;1;[Header];Create;True;1;UseVertexPainting;0;0;False;0;False;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;502;-7040,2144;Inherit;False;DebugThreshold;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;45;-7040,1664;Inherit;False;DebugGrayscale;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;507;-7040,1744;Inherit;False;DebugDesaturate;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;508;1216,-2144;Inherit;False;507;DebugDesaturate;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;504;960,-2144;Inherit;False;502;DebugThreshold;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;490;752,-2144;Inherit;False;489;BPMainTint;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;485;544,-2144;Inherit;False;484;BPColorIntensity;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;379;-5152,-2240;Inherit;False;362;T1_ProceduralTiling;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;259;-5440,-2128;Inherit;True;Property;_TextureSample28;Texture Sample 24;7;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;257;-5920,-2256;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;378;-6144,-2240;Inherit;False;361;T1_Tiling;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;256;-5440,-2384;Inherit;False;Procedural Sample;-1;;20;f5379ff72769e2b4495e5ce2f004d8d4;2,157,0,315,0;7;82;SAMPLER2D;0;False;158;SAMPLER2DARRAY;0;False;183;FLOAT;0;False;5;FLOAT2;0,0;False;80;FLOAT3;0,0,0;False;104;FLOAT2;1,1;False;74;SAMPLERSTATE;0;False;5;COLOR;0;FLOAT;32;FLOAT;33;FLOAT;34;FLOAT;35
Node;AmplifyShaderEditor.FunctionNode;277;-5440,-1776;Inherit;False;Procedural Sample;-1;;21;f5379ff72769e2b4495e5ce2f004d8d4;2,157,0,315,0;7;82;SAMPLER2D;0;False;158;SAMPLER2DARRAY;0;False;183;FLOAT;0;False;5;FLOAT2;0,0;False;80;FLOAT3;0,0,0;False;104;FLOAT2;1,1;False;74;SAMPLERSTATE;0;False;5;COLOR;0;FLOAT;32;FLOAT;33;FLOAT;34;FLOAT;35
Node;AmplifyShaderEditor.LerpOp;267;-4912,-1776;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;268;-4688,-1776;Inherit;False;T2_NAOH;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;274;-5904,-1648;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;381;-6096,-1632;Inherit;False;363;T2_Tilling;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;276;-5440,-1568;Inherit;True;Property;_TextureSample29;Texture Sample 24;7;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;380;-5152,-1664;Inherit;False;364;T2_ProceduralTiling;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.PiNode;510;-5888,-2112;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;382;-5152,-1024;Inherit;False;366;T3_ProceduralTiling;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;289;-5440,-896;Inherit;True;Property;_TextureSample30;Texture Sample 24;7;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;290;-5440,-1152;Inherit;False;Procedural Sample;-1;;22;f5379ff72769e2b4495e5ce2f004d8d4;2,157,0,315,0;7;82;SAMPLER2D;0;False;158;SAMPLER2DARRAY;0;False;183;FLOAT;0;False;5;FLOAT2;0,0;False;80;FLOAT3;0,0,0;False;104;FLOAT2;1,1;False;74;SAMPLERSTATE;0;False;5;COLOR;0;FLOAT;32;FLOAT;33;FLOAT;34;FLOAT;35
Node;AmplifyShaderEditor.GetLocalVarNode;383;-6096,-1008;Inherit;False;365;T3_Tilling;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;287;-5888,-1024;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PiNode;514;-5856,-880;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;515;-5888,-432;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PiNode;517;-5856,-288;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;385;-5168,-416;Inherit;False;367;T4_ProceduralTiling;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;299;-5440,-544;Inherit;False;Procedural Sample;-1;;23;f5379ff72769e2b4495e5ce2f004d8d4;2,157,0,315,0;7;82;SAMPLER2D;0;False;158;SAMPLER2DARRAY;0;False;183;FLOAT;0;False;5;FLOAT2;0,0;False;80;FLOAT3;0,0,0;False;104;FLOAT2;1,1;False;74;SAMPLERSTATE;0;False;5;COLOR;0;FLOAT;32;FLOAT;33;FLOAT;34;FLOAT;35
Node;AmplifyShaderEditor.SamplerNode;298;-5440,-288;Inherit;True;Property;_TextureSample31;Texture Sample 24;7;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;384;-6096,-416;Inherit;False;368;T4_Tilling;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.PiNode;512;-5872,-1504;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RotatorNode;516;-5664,-432;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RotatorNode;513;-5664,-1024;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RotatorNode;511;-5680,-1648;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RotatorNode;509;-5680,-2256;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;527;-7344,2224;Inherit;False;Property;_FlipTexture;FlipTexture;28;2;[Header];[IntRange];Create;True;1;Modify Texture Property;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;528;-7040,2224;Inherit;False;DebugFlipTexture;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;529;-6144,-2112;Inherit;False;528;DebugFlipTexture;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;530;-6144,-1504;Inherit;False;528;DebugFlipTexture;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;531;-6144,-880;Inherit;False;528;DebugFlipTexture;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;532;-6144,-288;Inherit;False;528;DebugFlipTexture;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;141;-2832,-256;Inherit;False;40;T4_Textures;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.RangedFloatNode;134;-1584,-128;Inherit;False;Constant;_Float3;Float 0;7;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;136;-1392,-288;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;137;-1600,-288;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;139;-1008,-288;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;370;-1856,-128;Inherit;False;367;T4_ProceduralTiling;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCGrayscale;135;-1232,-192;Inherit;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;138;-1248,-112;Inherit;False;45;DebugGrayscale;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;133;-2160,80;Inherit;True;Property;_TextureSample27;Texture Sample 24;7;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;140;-2112,-272;Inherit;True;Procedural Sample;-1;;24;f5379ff72769e2b4495e5ce2f004d8d4;2,157,0,315,0;7;82;SAMPLER2D;0;False;158;SAMPLER2DARRAY;0;False;183;FLOAT;0;False;5;FLOAT2;0,0;False;80;FLOAT3;0,0,0;False;104;FLOAT2;1,1;False;74;SAMPLERSTATE;0;False;5;COLOR;0;FLOAT;32;FLOAT;33;FLOAT;34;FLOAT;35
Node;AmplifyShaderEditor.TextureCoordinatesNode;132;-2672,-64;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PiNode;526;-2608,80;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;371;-2880,-48;Inherit;False;368;T4_Tilling;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RotatorNode;525;-2416,-64;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;144;-816,-288;Inherit;False;T4_RGB;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;533;-2928,80;Inherit;False;528;DebugFlipTexture;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;127;-2816,-960;Inherit;False;30;T3_Textures;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.LerpOp;126;-1008,-992;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;130;-800,-992;Inherit;False;T3_RGB;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;123;-1392,-992;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.TFHCGrayscale;122;-1232,-896;Inherit;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;125;-1248,-816;Inherit;False;45;DebugGrayscale;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;121;-1584,-832;Inherit;False;Constant;_Float2;Float 0;7;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;124;-1600,-992;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;373;-1856,-832;Inherit;False;366;T3_ProceduralTiling;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;119;-2160,-608;Inherit;True;Property;_TextureSample26;Texture Sample 24;7;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;129;-2112,-960;Inherit;True;Procedural Sample;-1;;25;f5379ff72769e2b4495e5ce2f004d8d4;2,157,0,315,0;7;82;SAMPLER2D;0;False;158;SAMPLER2DARRAY;0;False;183;FLOAT;0;False;5;FLOAT2;0,0;False;80;FLOAT3;0,0,0;False;104;FLOAT2;1,1;False;74;SAMPLERSTATE;0;False;5;COLOR;0;FLOAT;32;FLOAT;33;FLOAT;34;FLOAT;35
Node;AmplifyShaderEditor.TextureCoordinatesNode;118;-2672,-736;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;372;-2880,-720;Inherit;False;365;T3_Tilling;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.PiNode;523;-2608,-592;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RotatorNode;524;-2416,-736;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;534;-2928,-592;Inherit;False;528;DebugFlipTexture;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;114;-816,-1696;Inherit;False;T2_RGB;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;374;-2896,-1488;Inherit;False;363;T2_Tilling;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;103;-2816,-1664;Inherit;False;25;T2_Textures;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.RangedFloatNode;108;-1568,-1536;Inherit;False;Constant;_Float1;Float 0;7;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCGrayscale;109;-1232,-1600;Inherit;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;110;-1392,-1696;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;111;-1600,-1696;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;113;-1008,-1696;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;106;-2160,-1328;Inherit;True;Property;_TextureSample25;Texture Sample 24;7;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;520;-2672,-1504;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;105;-2112,-1664;Inherit;True;Procedural Sample;-1;;26;f5379ff72769e2b4495e5ce2f004d8d4;2,157,0,315,0;7;82;SAMPLER2D;0;False;158;SAMPLER2DARRAY;0;False;183;FLOAT;0;False;5;FLOAT2;0,0;False;80;FLOAT3;0,0,0;False;104;FLOAT2;1,1;False;74;SAMPLERSTATE;0;False;5;COLOR;0;FLOAT;32;FLOAT;33;FLOAT;34;FLOAT;35
Node;AmplifyShaderEditor.GetLocalVarNode;375;-1872,-1536;Inherit;False;364;T2_ProceduralTiling;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;112;-1248,-1520;Inherit;False;45;DebugGrayscale;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RotatorNode;521;-2416,-1504;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PiNode;522;-2640,-1360;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;535;-2928,-1360;Inherit;False;528;DebugFlipTexture;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;71;-816,-2368;Inherit;False;T1_RGB;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;58;-2848,-2352;Inherit;False;11;T1_Textures;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.RangedFloatNode;67;-1584,-2224;Inherit;False;Constant;_Float0;Float 0;7;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;66;-1408,-2368;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;64;-1600,-2368;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;70;-1264,-2208;Inherit;False;45;DebugGrayscale;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;69;-1008,-2368;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.TFHCGrayscale;68;-1248,-2288;Inherit;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;59;-2128,-2352;Inherit;True;Procedural Sample;-1;;27;f5379ff72769e2b4495e5ce2f004d8d4;2,157,0,315,0;7;82;SAMPLER2D;0;False;158;SAMPLER2DARRAY;0;False;183;FLOAT;0;False;5;FLOAT2;0,0;False;80;FLOAT3;0,0,0;False;104;FLOAT2;1,1;False;74;SAMPLERSTATE;0;False;5;COLOR;0;FLOAT;32;FLOAT;33;FLOAT;34;FLOAT;35
Node;AmplifyShaderEditor.SamplerNode;63;-2176,-2000;Inherit;True;Property;_TextureSample24;Texture Sample 24;7;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;399;-2896,-2160;Inherit;False;361;T1_Tiling;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;61;-2672,-2176;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PiNode;519;-2608,-2032;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;376;-1888,-2224;Inherit;False;362;T1_ProceduralTiling;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RotatorNode;518;-2416,-2176;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;536;-2928,-2032;Inherit;False;528;DebugFlipTexture;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;506;-7344,1744;Inherit;False;Property;_DesaturateDebug;DesaturateDebug;3;0;Create;True;1;Debug Mode;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;501;-7344,2144;Inherit;False;Property;_ThresholdDebug;ThresholdDebug;4;1;[Header];Create;True;0;0;0;False;0;False;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;445;-7040,1984;Inherit;False;UseVertexPainting;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;442;-7344,2064;Inherit;False;Property;_AddVertexPaintingToMask;AddVertexPaintingToMask;0;1;[Header];Create;True;0;0;0;False;0;False;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;443;-7040,2064;Inherit;False;AddVertexPaintingToMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
WireConnection;260;0;256;0
WireConnection;260;1;259;0
WireConnection;260;2;379;0
WireConnection;174;0;175;0
WireConnection;174;1;172;0
WireConnection;175;0;173;0
WireConnection;270;0;272;0
WireConnection;270;1;269;0
WireConnection;272;0;271;0
WireConnection;262;0;260;0
WireConnection;281;0;290;0
WireConnection;281;1;289;0
WireConnection;281;2;382;0
WireConnection;283;0;285;0
WireConnection;283;1;282;0
WireConnection;294;0;299;0
WireConnection;294;1;298;0
WireConnection;294;2;385;0
WireConnection;302;0;303;0
WireConnection;302;1;295;0
WireConnection;285;0;284;0
WireConnection;303;0;301;0
WireConnection;305;0;281;0
WireConnection;306;0;294;0
WireConnection;12;0;11;0
WireConnection;12;1;22;0
WireConnection;11;0;10;0
WireConnection;26;0;25;0
WireConnection;26;1;28;0
WireConnection;34;0;30;0
WireConnection;34;1;31;0
WireConnection;30;0;33;0
WireConnection;25;0;24;0
WireConnection;39;0;40;0
WireConnection;39;1;36;0
WireConnection;40;0;38;0
WireConnection;27;0;26;0
WireConnection;32;0;34;0
WireConnection;37;0;39;0
WireConnection;15;0;12;0
WireConnection;157;0;158;0
WireConnection;157;1;159;0
WireConnection;157;2;160;0
WireConnection;165;0;155;0
WireConnection;165;1;161;0
WireConnection;165;2;402;0
WireConnection;147;0;146;0
WireConnection;147;1;148;0
WireConnection;147;2;149;0
WireConnection;150;0;419;0
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
WireConnection;54;0;55;0
WireConnection;51;0;50;0
WireConnection;52;0;53;0
WireConnection;361;0;359;0
WireConnection;362;0;360;0
WireConnection;363;0;357;0
WireConnection;364;0;358;0
WireConnection;368;0;353;0
WireConnection;367;0;355;0
WireConnection;366;0;356;0
WireConnection;365;0;354;0
WireConnection;403;0;322;3
WireConnection;404;0;322;2
WireConnection;405;0;322;1
WireConnection;155;0;150;0
WireConnection;155;1;157;0
WireConnection;155;2;401;0
WireConnection;168;0;165;0
WireConnection;419;0;147;0
WireConnection;419;1;420;0
WireConnection;420;0;415;0
WireConnection;402;0;166;3
WireConnection;401;0;166;2
WireConnection;400;0;166;1
WireConnection;415;0;166;1
WireConnection;415;1;166;2
WireConnection;415;2;166;3
WireConnection;57;0;56;0
WireConnection;161;0;162;0
WireConnection;161;1;163;0
WireConnection;161;2;164;0
WireConnection;321;0;320;0
WireConnection;425;0;200;0
WireConnection;425;1;429;0
WireConnection;425;2;426;0
WireConnection;186;0;189;0
WireConnection;187;0;186;0
WireConnection;189;0;188;0
WireConnection;189;1;190;0
WireConnection;421;0;187;0
WireConnection;421;1;187;1
WireConnection;421;2;187;2
WireConnection;423;0;421;0
WireConnection;431;0;430;0
WireConnection;431;1;432;0
WireConnection;431;2;433;0
WireConnection;424;0;425;0
WireConnection;424;1;422;0
WireConnection;422;0;423;0
WireConnection;197;0;478;0
WireConnection;197;1;431;0
WireConnection;410;0;409;0
WireConnection;410;1;193;0
WireConnection;410;2;472;0
WireConnection;193;0;470;0
WireConnection;193;1;438;0
WireConnection;438;0;439;0
WireConnection;438;1;440;0
WireConnection;438;2;441;0
WireConnection;409;0;408;0
WireConnection;409;1;195;0
WireConnection;409;2;476;0
WireConnection;195;0;477;0
WireConnection;195;1;434;0
WireConnection;408;0;424;0
WireConnection;408;1;197;0
WireConnection;408;2;480;0
WireConnection;434;0;435;0
WireConnection;434;1;436;0
WireConnection;434;2;437;0
WireConnection;208;0;410;0
WireConnection;469;0;187;2
WireConnection;470;0;469;0
WireConnection;472;0;471;0
WireConnection;471;0;187;2
WireConnection;473;0;187;1
WireConnection;475;0;187;1
WireConnection;476;0;473;0
WireConnection;477;0;475;0
WireConnection;479;0;187;0
WireConnection;478;0;479;0
WireConnection;481;0;187;0
WireConnection;480;0;481;0
WireConnection;254;0;183;0
WireConnection;254;1;210;0
WireConnection;446;0;183;0
WireConnection;446;1;210;0
WireConnection;446;2;448;0
WireConnection;489;0;488;0
WireConnection;484;0;483;0
WireConnection;492;0;491;0
WireConnection;493;0;494;0
WireConnection;348;0;505;0
WireConnection;348;1;349;0
WireConnection;348;2;351;0
WireConnection;452;0;348;0
WireConnection;452;1;467;0
WireConnection;452;3;498;0
WireConnection;452;4;499;0
WireConnection;464;0;462;0
WireConnection;464;1;462;1
WireConnection;467;0;465;0
WireConnection;467;1;468;0
WireConnection;462;0;461;0
WireConnection;468;1;464;0
WireConnection;449;0;446;0
WireConnection;449;1;485;0
WireConnection;486;0;449;0
WireConnection;486;1;490;0
WireConnection;500;0;486;0
WireConnection;500;2;504;0
WireConnection;505;0;500;0
WireConnection;505;1;508;0
WireConnection;46;0;47;0
WireConnection;43;0;42;0
WireConnection;502;0;501;0
WireConnection;45;0;44;0
WireConnection;507;0;506;0
WireConnection;259;0;255;0
WireConnection;259;1;509;0
WireConnection;257;0;378;0
WireConnection;256;82;255;0
WireConnection;256;5;509;0
WireConnection;277;82;273;0
WireConnection;277;5;511;0
WireConnection;267;0;277;0
WireConnection;267;1;276;0
WireConnection;267;2;380;0
WireConnection;268;0;267;0
WireConnection;274;0;381;0
WireConnection;276;0;273;0
WireConnection;276;1;511;0
WireConnection;510;0;529;0
WireConnection;289;0;286;0
WireConnection;289;1;513;0
WireConnection;290;82;286;0
WireConnection;290;5;513;0
WireConnection;287;0;383;0
WireConnection;514;0;531;0
WireConnection;515;0;384;0
WireConnection;517;0;532;0
WireConnection;299;82;304;0
WireConnection;299;5;516;0
WireConnection;298;0;304;0
WireConnection;298;1;516;0
WireConnection;512;0;530;0
WireConnection;516;0;515;0
WireConnection;516;2;517;0
WireConnection;513;0;287;0
WireConnection;513;2;514;0
WireConnection;511;0;274;0
WireConnection;511;2;512;0
WireConnection;509;0;257;0
WireConnection;509;2;510;0
WireConnection;528;0;527;0
WireConnection;136;0;137;0
WireConnection;136;1;134;0
WireConnection;137;0;133;0
WireConnection;137;1;140;0
WireConnection;137;2;370;0
WireConnection;139;0;136;0
WireConnection;139;1;135;0
WireConnection;139;2;138;0
WireConnection;135;0;136;0
WireConnection;133;0;141;0
WireConnection;133;1;525;0
WireConnection;140;82;141;0
WireConnection;140;5;525;0
WireConnection;132;0;371;0
WireConnection;526;0;533;0
WireConnection;525;0;132;0
WireConnection;525;2;526;0
WireConnection;144;0;139;0
WireConnection;126;0;123;0
WireConnection;126;1;122;0
WireConnection;126;2;125;0
WireConnection;130;0;126;0
WireConnection;123;0;124;0
WireConnection;123;1;121;0
WireConnection;122;0;123;0
WireConnection;124;0;119;0
WireConnection;124;1;129;0
WireConnection;124;2;373;0
WireConnection;119;0;127;0
WireConnection;119;1;524;0
WireConnection;129;82;127;0
WireConnection;129;5;524;0
WireConnection;118;0;372;0
WireConnection;523;0;534;0
WireConnection;524;0;118;0
WireConnection;524;2;523;0
WireConnection;114;0;113;0
WireConnection;109;0;110;0
WireConnection;110;0;111;0
WireConnection;110;1;108;0
WireConnection;111;0;106;0
WireConnection;111;1;105;0
WireConnection;111;2;375;0
WireConnection;113;0;110;0
WireConnection;113;1;109;0
WireConnection;113;2;112;0
WireConnection;106;0;103;0
WireConnection;106;1;521;0
WireConnection;520;0;374;0
WireConnection;105;82;103;0
WireConnection;105;5;521;0
WireConnection;521;0;520;0
WireConnection;521;2;522;0
WireConnection;522;0;535;0
WireConnection;71;0;69;0
WireConnection;66;0;64;0
WireConnection;66;1;67;0
WireConnection;64;0;63;0
WireConnection;64;1;59;0
WireConnection;64;2;376;0
WireConnection;69;0;66;0
WireConnection;69;1;68;0
WireConnection;69;2;70;0
WireConnection;68;0;66;0
WireConnection;59;82;58;0
WireConnection;59;5;518;0
WireConnection;63;0;58;0
WireConnection;63;1;518;0
WireConnection;61;0;399;0
WireConnection;519;0;536;0
WireConnection;518;0;61;0
WireConnection;518;2;519;0
WireConnection;445;0;444;0
WireConnection;443;0;442;0
ASEEND*/
//CHKSM=ED9830C63575CBA5D3845744C2D36662B1078516