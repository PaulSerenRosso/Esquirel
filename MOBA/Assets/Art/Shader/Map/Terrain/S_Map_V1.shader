// Made with Amplify Shader Editor v1.9.1.2
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "S_Map_V1"
{
	Properties
	{
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		[ASEBegin]_AddVertexPaintingToMask("AddVertexPaintingToMask", Range( 0 , 1)) = 0
		_IntensityColorMap("IntensityColorMap", Range( 0 , 2)) = 2
		[Header(Debug Mode)]_GrayscaleDebug("GrayscaleDebug", Range( 0 , 1)) = 0
		_NormalDebug("NormalDebug", Range( 0 , 1)) = 0
		_VertexPaintDebug("VertexPaintDebug", Range( 0 , 1)) = 0
		[Header(Mask Vertex Painting)][IntRange]_SymetryVertexPaint("Symetry Vertex Paint", Range( 0 , 1)) = 1
		_RotateVertexPaintMask("Rotate Vertex Paint Mask", Range( 0 , 1)) = 0
		_TerrainMask_VertexPaint("TerrainMask_VertexPaint", 2D) = "white" {}
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
		_Smoothness("Smoothness", Range( 0 , 1)) = 0
		[ASEEnd]_MapContourColor("Map Contour Color", Color) = (0,0,0,0)


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
			float4 _MapContourColor;
			float4 _TerrainMask_VertexPaint_ST;
			float _T1_Tiling1;
			float _IntensityColorMap;
			float _AddVertexPaintingToMask;
			float _T4_ProceduralTiling1;
			float _T4_Tilling1;
			float _T3_ProceduralTiling1;
			float _T3_Tilling1;
			float _T2_ProceduralTiling1;
			float _T2_Tilling1;
			float _SymetryVertexPaint;
			float _RotateVertexPaintMask;
			float _VertexPaintDebug;
			float _GrayscaleDebug;
			float _T1_ProceduralTiling1;
			float _NormalDebug;
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
				float2 uv_TerrainMask_VertexPaint = IN.ase_texcoord7.xy * _TerrainMask_VertexPaint_ST.xy + _TerrainMask_VertexPaint_ST.zw;
				float RotateVertexPaintMask523 = _RotateVertexPaintMask;
				float cos540 = cos( ( RotateVertexPaintMask523 * TWO_PI ) );
				float sin540 = sin( ( RotateVertexPaintMask523 * TWO_PI ) );
				float2 rotator540 = mul( uv_TerrainMask_VertexPaint - float2( 0.5,0.5 ) , float2x2( cos540 , -sin540 , sin540 , cos540 )) + float2( 0.5,0.5 );
				float4 TerrainMask_VertexPaintAlbedo517 = tex2D( _TerrainMask_VertexPaint, rotator540 );
				float SymetryVertexPaint498 = _SymetryVertexPaint;
				float4 lerpResult492 = lerp( TerrainMask_VertexPaintAlbedo517 , ( ( tex2D( _TerrainMask_VertexPaint, ( float2( 2,1 ) * float2( 0,0 ) ) ) * float4( 0,0,0,0 ) ) + float4( 0,0,0,0 ) ) , SymetryVertexPaint498);
				float4 MaskVertexPaint500 = lerpResult492;
				float4 break494 = MaskVertexPaint500;
				float T2_Tilling363 = _T2_Tilling1;
				float2 temp_cast_3 = (T2_Tilling363).xx;
				float2 texCoord104 = IN.ase_texcoord7.xy * temp_cast_3 + float2( 0,0 );
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
				float4 lerpResult150 = lerp( ( lerpResult147 * ( 1.0 - ( break494.r + break494.g + break494.b ) ) ) , lerpResult151 , ( break494.r * 1.0 ));
				float T3_Tilling365 = _T3_Tilling1;
				float2 temp_cast_6 = (T3_Tilling365).xx;
				float2 texCoord118 = IN.ase_texcoord7.xy * temp_cast_6 + float2( 0,0 );
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
				float4 lerpResult155 = lerp( lerpResult150 , lerpResult157 , ( break494.g * 1.0 ));
				float T4_Tilling368 = _T4_Tilling1;
				float2 temp_cast_9 = (T4_Tilling368).xx;
				float2 texCoord132 = IN.ase_texcoord7.xy * temp_cast_9 + float2( 0,0 );
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
				float4 lerpResult165 = lerp( lerpResult155 , lerpResult161 , ( break494.b * 1.0 ));
				float4 lerpResult547 = lerp( lerpResult165 , _MapContourColor , ( break494.a * 1.0 ));
				float4 AllAlbedoCombined168 = lerpResult547;
				float4 lerpResult425 = lerp( T1_RGB71 , DebugColor151 , DebugVertexPainting46);
				float4 break187 = saturate( ( IN.ase_color * 2.0 ) );
				float4 lerpResult431 = lerp( T2_RGB114 , DebugColor252 , DebugVertexPainting46);
				float4 lerpResult408 = lerp( ( lerpResult425 * ( 1.0 - saturate( ( break187.r + break187.g + break187.b ) ) ) ) , ( break187.r * lerpResult431 ) , break187.r);
				float4 lerpResult434 = lerp( T3_RGB130 , DebugColor354 , DebugVertexPainting46);
				float4 lerpResult409 = lerp( lerpResult408 , ( break187.g * lerpResult434 ) , break187.g);
				float4 lerpResult438 = lerp( T4_RGB144 , DebugColor457 , DebugVertexPainting46);
				float4 lerpResult410 = lerp( lerpResult409 , ( break187.b * lerpResult438 ) , break187.b);
				float4 AllAlbedoVertexPaint208 = lerpResult410;
				float AddVertexPaintingToMask443 = _AddVertexPaintingToMask;
				float4 lerpResult446 = lerp( AllAlbedoCombined168 , AllAlbedoVertexPaint208 , AddVertexPaintingToMask443);
				float localStochasticTiling2_g10 = ( 0.0 );
				float2 temp_cast_12 = (T1_Tiling361).xx;
				float2 texCoord257 = IN.ase_texcoord7.xy * temp_cast_12 + float2( 0,0 );
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
				float2 temp_cast_13 = (T2_Tilling363).xx;
				float2 texCoord274 = IN.ase_texcoord7.xy * temp_cast_13 + float2( 0,0 );
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
				float4 break502 = MaskVertexPaint500;
				float4 lerpResult327 = lerp( T1_NAOH262 , T2_NAOH268 , ( break502.r * 2.0 ));
				float localStochasticTiling2_g12 = ( 0.0 );
				float2 temp_cast_14 = (T3_Tilling365).xx;
				float2 texCoord287 = IN.ase_texcoord7.xy * temp_cast_14 + float2( 0,0 );
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
				float4 lerpResult311 = lerp( lerpResult327 , T3_NAOH305 , ( break502.g * 2.0 ));
				float localStochasticTiling2_g13 = ( 0.0 );
				float2 temp_cast_15 = (T4_Tilling368).xx;
				float2 texCoord296 = IN.ase_texcoord7.xy * temp_cast_15 + float2( 0,0 );
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
				float4 lerpResult320 = lerp( lerpResult311 , T4_NAOH306 , ( break502.b * 2.0 ));
				float4 AllNormal_Combined321 = lerpResult320;
				float DebugNormal43 = _NormalDebug;
				float4 lerpResult348 = lerp( ( lerpResult446 * _IntensityColorMap ) , AllNormal_Combined321 , DebugNormal43);
				
				float2 appendResult464 = (float2(AllNormal_Combined321.r , 0.0));
				float2 temp_output_1_0_g18 = appendResult464;
				float dotResult4_g18 = dot( temp_output_1_0_g18 , temp_output_1_0_g18 );
				float3 appendResult10_g18 = (float3((temp_output_1_0_g18).x , (temp_output_1_0_g18).y , sqrt( ( 1.0 - saturate( dotResult4_g18 ) ) )));
				float3 normalizeResult12_g18 = normalize( appendResult10_g18 );
				

				float3 BaseColor = lerpResult348.rgb;
				float3 Normal = ( IN.ase_normal + normalizeResult12_g18 );
				float3 Emission = 0;
				float3 Specular = 0.5;
				float Metallic = 0;
				float Smoothness = _Smoothness;
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
			float4 _MapContourColor;
			float4 _TerrainMask_VertexPaint_ST;
			float _T1_Tiling1;
			float _IntensityColorMap;
			float _AddVertexPaintingToMask;
			float _T4_ProceduralTiling1;
			float _T4_Tilling1;
			float _T3_ProceduralTiling1;
			float _T3_Tilling1;
			float _T2_ProceduralTiling1;
			float _T2_Tilling1;
			float _SymetryVertexPaint;
			float _RotateVertexPaintMask;
			float _VertexPaintDebug;
			float _GrayscaleDebug;
			float _T1_ProceduralTiling1;
			float _NormalDebug;
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
			float4 _MapContourColor;
			float4 _TerrainMask_VertexPaint_ST;
			float _T1_Tiling1;
			float _IntensityColorMap;
			float _AddVertexPaintingToMask;
			float _T4_ProceduralTiling1;
			float _T4_Tilling1;
			float _T3_ProceduralTiling1;
			float _T3_Tilling1;
			float _T2_ProceduralTiling1;
			float _T2_Tilling1;
			float _SymetryVertexPaint;
			float _RotateVertexPaintMask;
			float _VertexPaintDebug;
			float _GrayscaleDebug;
			float _T1_ProceduralTiling1;
			float _NormalDebug;
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
			float4 _MapContourColor;
			float4 _TerrainMask_VertexPaint_ST;
			float _T1_Tiling1;
			float _IntensityColorMap;
			float _AddVertexPaintingToMask;
			float _T4_ProceduralTiling1;
			float _T4_Tilling1;
			float _T3_ProceduralTiling1;
			float _T3_Tilling1;
			float _T2_ProceduralTiling1;
			float _T2_Tilling1;
			float _SymetryVertexPaint;
			float _RotateVertexPaintMask;
			float _VertexPaintDebug;
			float _GrayscaleDebug;
			float _T1_ProceduralTiling1;
			float _NormalDebug;
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
				float2 uv_TerrainMask_VertexPaint = IN.ase_texcoord2.xy * _TerrainMask_VertexPaint_ST.xy + _TerrainMask_VertexPaint_ST.zw;
				float RotateVertexPaintMask523 = _RotateVertexPaintMask;
				float cos540 = cos( ( RotateVertexPaintMask523 * TWO_PI ) );
				float sin540 = sin( ( RotateVertexPaintMask523 * TWO_PI ) );
				float2 rotator540 = mul( uv_TerrainMask_VertexPaint - float2( 0.5,0.5 ) , float2x2( cos540 , -sin540 , sin540 , cos540 )) + float2( 0.5,0.5 );
				float4 TerrainMask_VertexPaintAlbedo517 = tex2D( _TerrainMask_VertexPaint, rotator540 );
				float SymetryVertexPaint498 = _SymetryVertexPaint;
				float4 lerpResult492 = lerp( TerrainMask_VertexPaintAlbedo517 , ( ( tex2D( _TerrainMask_VertexPaint, ( float2( 2,1 ) * float2( 0,0 ) ) ) * float4( 0,0,0,0 ) ) + float4( 0,0,0,0 ) ) , SymetryVertexPaint498);
				float4 MaskVertexPaint500 = lerpResult492;
				float4 break494 = MaskVertexPaint500;
				float T2_Tilling363 = _T2_Tilling1;
				float2 temp_cast_3 = (T2_Tilling363).xx;
				float2 texCoord104 = IN.ase_texcoord2.xy * temp_cast_3 + float2( 0,0 );
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
				float4 lerpResult150 = lerp( ( lerpResult147 * ( 1.0 - ( break494.r + break494.g + break494.b ) ) ) , lerpResult151 , ( break494.r * 1.0 ));
				float T3_Tilling365 = _T3_Tilling1;
				float2 temp_cast_6 = (T3_Tilling365).xx;
				float2 texCoord118 = IN.ase_texcoord2.xy * temp_cast_6 + float2( 0,0 );
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
				float4 lerpResult155 = lerp( lerpResult150 , lerpResult157 , ( break494.g * 1.0 ));
				float T4_Tilling368 = _T4_Tilling1;
				float2 temp_cast_9 = (T4_Tilling368).xx;
				float2 texCoord132 = IN.ase_texcoord2.xy * temp_cast_9 + float2( 0,0 );
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
				float4 lerpResult165 = lerp( lerpResult155 , lerpResult161 , ( break494.b * 1.0 ));
				float4 lerpResult547 = lerp( lerpResult165 , _MapContourColor , ( break494.a * 1.0 ));
				float4 AllAlbedoCombined168 = lerpResult547;
				float4 lerpResult425 = lerp( T1_RGB71 , DebugColor151 , DebugVertexPainting46);
				float4 break187 = saturate( ( IN.ase_color * 2.0 ) );
				float4 lerpResult431 = lerp( T2_RGB114 , DebugColor252 , DebugVertexPainting46);
				float4 lerpResult408 = lerp( ( lerpResult425 * ( 1.0 - saturate( ( break187.r + break187.g + break187.b ) ) ) ) , ( break187.r * lerpResult431 ) , break187.r);
				float4 lerpResult434 = lerp( T3_RGB130 , DebugColor354 , DebugVertexPainting46);
				float4 lerpResult409 = lerp( lerpResult408 , ( break187.g * lerpResult434 ) , break187.g);
				float4 lerpResult438 = lerp( T4_RGB144 , DebugColor457 , DebugVertexPainting46);
				float4 lerpResult410 = lerp( lerpResult409 , ( break187.b * lerpResult438 ) , break187.b);
				float4 AllAlbedoVertexPaint208 = lerpResult410;
				float AddVertexPaintingToMask443 = _AddVertexPaintingToMask;
				float4 lerpResult446 = lerp( AllAlbedoCombined168 , AllAlbedoVertexPaint208 , AddVertexPaintingToMask443);
				float localStochasticTiling2_g10 = ( 0.0 );
				float2 temp_cast_12 = (T1_Tiling361).xx;
				float2 texCoord257 = IN.ase_texcoord2.xy * temp_cast_12 + float2( 0,0 );
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
				float2 temp_cast_13 = (T2_Tilling363).xx;
				float2 texCoord274 = IN.ase_texcoord2.xy * temp_cast_13 + float2( 0,0 );
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
				float4 break502 = MaskVertexPaint500;
				float4 lerpResult327 = lerp( T1_NAOH262 , T2_NAOH268 , ( break502.r * 2.0 ));
				float localStochasticTiling2_g12 = ( 0.0 );
				float2 temp_cast_14 = (T3_Tilling365).xx;
				float2 texCoord287 = IN.ase_texcoord2.xy * temp_cast_14 + float2( 0,0 );
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
				float4 lerpResult311 = lerp( lerpResult327 , T3_NAOH305 , ( break502.g * 2.0 ));
				float localStochasticTiling2_g13 = ( 0.0 );
				float2 temp_cast_15 = (T4_Tilling368).xx;
				float2 texCoord296 = IN.ase_texcoord2.xy * temp_cast_15 + float2( 0,0 );
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
				float4 lerpResult320 = lerp( lerpResult311 , T4_NAOH306 , ( break502.b * 2.0 ));
				float4 AllNormal_Combined321 = lerpResult320;
				float DebugNormal43 = _NormalDebug;
				float4 lerpResult348 = lerp( ( lerpResult446 * _IntensityColorMap ) , AllNormal_Combined321 , DebugNormal43);
				

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
			float4 _MapContourColor;
			float4 _TerrainMask_VertexPaint_ST;
			float _T1_Tiling1;
			float _IntensityColorMap;
			float _AddVertexPaintingToMask;
			float _T4_ProceduralTiling1;
			float _T4_Tilling1;
			float _T3_ProceduralTiling1;
			float _T3_Tilling1;
			float _T2_ProceduralTiling1;
			float _T2_Tilling1;
			float _SymetryVertexPaint;
			float _RotateVertexPaintMask;
			float _VertexPaintDebug;
			float _GrayscaleDebug;
			float _T1_ProceduralTiling1;
			float _NormalDebug;
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
				float2 uv_TerrainMask_VertexPaint = IN.ase_texcoord2.xy * _TerrainMask_VertexPaint_ST.xy + _TerrainMask_VertexPaint_ST.zw;
				float RotateVertexPaintMask523 = _RotateVertexPaintMask;
				float cos540 = cos( ( RotateVertexPaintMask523 * TWO_PI ) );
				float sin540 = sin( ( RotateVertexPaintMask523 * TWO_PI ) );
				float2 rotator540 = mul( uv_TerrainMask_VertexPaint - float2( 0.5,0.5 ) , float2x2( cos540 , -sin540 , sin540 , cos540 )) + float2( 0.5,0.5 );
				float4 TerrainMask_VertexPaintAlbedo517 = tex2D( _TerrainMask_VertexPaint, rotator540 );
				float SymetryVertexPaint498 = _SymetryVertexPaint;
				float4 lerpResult492 = lerp( TerrainMask_VertexPaintAlbedo517 , ( ( tex2D( _TerrainMask_VertexPaint, ( float2( 2,1 ) * float2( 0,0 ) ) ) * float4( 0,0,0,0 ) ) + float4( 0,0,0,0 ) ) , SymetryVertexPaint498);
				float4 MaskVertexPaint500 = lerpResult492;
				float4 break494 = MaskVertexPaint500;
				float T2_Tilling363 = _T2_Tilling1;
				float2 temp_cast_3 = (T2_Tilling363).xx;
				float2 texCoord104 = IN.ase_texcoord2.xy * temp_cast_3 + float2( 0,0 );
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
				float4 lerpResult150 = lerp( ( lerpResult147 * ( 1.0 - ( break494.r + break494.g + break494.b ) ) ) , lerpResult151 , ( break494.r * 1.0 ));
				float T3_Tilling365 = _T3_Tilling1;
				float2 temp_cast_6 = (T3_Tilling365).xx;
				float2 texCoord118 = IN.ase_texcoord2.xy * temp_cast_6 + float2( 0,0 );
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
				float4 lerpResult155 = lerp( lerpResult150 , lerpResult157 , ( break494.g * 1.0 ));
				float T4_Tilling368 = _T4_Tilling1;
				float2 temp_cast_9 = (T4_Tilling368).xx;
				float2 texCoord132 = IN.ase_texcoord2.xy * temp_cast_9 + float2( 0,0 );
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
				float4 lerpResult165 = lerp( lerpResult155 , lerpResult161 , ( break494.b * 1.0 ));
				float4 lerpResult547 = lerp( lerpResult165 , _MapContourColor , ( break494.a * 1.0 ));
				float4 AllAlbedoCombined168 = lerpResult547;
				float4 lerpResult425 = lerp( T1_RGB71 , DebugColor151 , DebugVertexPainting46);
				float4 break187 = saturate( ( IN.ase_color * 2.0 ) );
				float4 lerpResult431 = lerp( T2_RGB114 , DebugColor252 , DebugVertexPainting46);
				float4 lerpResult408 = lerp( ( lerpResult425 * ( 1.0 - saturate( ( break187.r + break187.g + break187.b ) ) ) ) , ( break187.r * lerpResult431 ) , break187.r);
				float4 lerpResult434 = lerp( T3_RGB130 , DebugColor354 , DebugVertexPainting46);
				float4 lerpResult409 = lerp( lerpResult408 , ( break187.g * lerpResult434 ) , break187.g);
				float4 lerpResult438 = lerp( T4_RGB144 , DebugColor457 , DebugVertexPainting46);
				float4 lerpResult410 = lerp( lerpResult409 , ( break187.b * lerpResult438 ) , break187.b);
				float4 AllAlbedoVertexPaint208 = lerpResult410;
				float AddVertexPaintingToMask443 = _AddVertexPaintingToMask;
				float4 lerpResult446 = lerp( AllAlbedoCombined168 , AllAlbedoVertexPaint208 , AddVertexPaintingToMask443);
				float localStochasticTiling2_g10 = ( 0.0 );
				float2 temp_cast_12 = (T1_Tiling361).xx;
				float2 texCoord257 = IN.ase_texcoord2.xy * temp_cast_12 + float2( 0,0 );
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
				float2 temp_cast_13 = (T2_Tilling363).xx;
				float2 texCoord274 = IN.ase_texcoord2.xy * temp_cast_13 + float2( 0,0 );
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
				float4 break502 = MaskVertexPaint500;
				float4 lerpResult327 = lerp( T1_NAOH262 , T2_NAOH268 , ( break502.r * 2.0 ));
				float localStochasticTiling2_g12 = ( 0.0 );
				float2 temp_cast_14 = (T3_Tilling365).xx;
				float2 texCoord287 = IN.ase_texcoord2.xy * temp_cast_14 + float2( 0,0 );
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
				float4 lerpResult311 = lerp( lerpResult327 , T3_NAOH305 , ( break502.g * 2.0 ));
				float localStochasticTiling2_g13 = ( 0.0 );
				float2 temp_cast_15 = (T4_Tilling368).xx;
				float2 texCoord296 = IN.ase_texcoord2.xy * temp_cast_15 + float2( 0,0 );
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
				float4 lerpResult320 = lerp( lerpResult311 , T4_NAOH306 , ( break502.b * 2.0 ));
				float4 AllNormal_Combined321 = lerpResult320;
				float DebugNormal43 = _NormalDebug;
				float4 lerpResult348 = lerp( ( lerpResult446 * _IntensityColorMap ) , AllNormal_Combined321 , DebugNormal43);
				

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
			float4 _MapContourColor;
			float4 _TerrainMask_VertexPaint_ST;
			float _T1_Tiling1;
			float _IntensityColorMap;
			float _AddVertexPaintingToMask;
			float _T4_ProceduralTiling1;
			float _T4_Tilling1;
			float _T3_ProceduralTiling1;
			float _T3_Tilling1;
			float _T2_ProceduralTiling1;
			float _T2_Tilling1;
			float _SymetryVertexPaint;
			float _RotateVertexPaintMask;
			float _VertexPaintDebug;
			float _GrayscaleDebug;
			float _T1_ProceduralTiling1;
			float _NormalDebug;
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
			float4 _MapContourColor;
			float4 _TerrainMask_VertexPaint_ST;
			float _T1_Tiling1;
			float _IntensityColorMap;
			float _AddVertexPaintingToMask;
			float _T4_ProceduralTiling1;
			float _T4_Tilling1;
			float _T3_ProceduralTiling1;
			float _T3_Tilling1;
			float _T2_ProceduralTiling1;
			float _T2_Tilling1;
			float _SymetryVertexPaint;
			float _RotateVertexPaintMask;
			float _VertexPaintDebug;
			float _GrayscaleDebug;
			float _T1_ProceduralTiling1;
			float _NormalDebug;
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
				float2 uv_TerrainMask_VertexPaint = IN.ase_texcoord7.xy * _TerrainMask_VertexPaint_ST.xy + _TerrainMask_VertexPaint_ST.zw;
				float RotateVertexPaintMask523 = _RotateVertexPaintMask;
				float cos540 = cos( ( RotateVertexPaintMask523 * TWO_PI ) );
				float sin540 = sin( ( RotateVertexPaintMask523 * TWO_PI ) );
				float2 rotator540 = mul( uv_TerrainMask_VertexPaint - float2( 0.5,0.5 ) , float2x2( cos540 , -sin540 , sin540 , cos540 )) + float2( 0.5,0.5 );
				float4 TerrainMask_VertexPaintAlbedo517 = tex2D( _TerrainMask_VertexPaint, rotator540 );
				float SymetryVertexPaint498 = _SymetryVertexPaint;
				float4 lerpResult492 = lerp( TerrainMask_VertexPaintAlbedo517 , ( ( tex2D( _TerrainMask_VertexPaint, ( float2( 2,1 ) * float2( 0,0 ) ) ) * float4( 0,0,0,0 ) ) + float4( 0,0,0,0 ) ) , SymetryVertexPaint498);
				float4 MaskVertexPaint500 = lerpResult492;
				float4 break494 = MaskVertexPaint500;
				float T2_Tilling363 = _T2_Tilling1;
				float2 temp_cast_3 = (T2_Tilling363).xx;
				float2 texCoord104 = IN.ase_texcoord7.xy * temp_cast_3 + float2( 0,0 );
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
				float4 lerpResult150 = lerp( ( lerpResult147 * ( 1.0 - ( break494.r + break494.g + break494.b ) ) ) , lerpResult151 , ( break494.r * 1.0 ));
				float T3_Tilling365 = _T3_Tilling1;
				float2 temp_cast_6 = (T3_Tilling365).xx;
				float2 texCoord118 = IN.ase_texcoord7.xy * temp_cast_6 + float2( 0,0 );
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
				float4 lerpResult155 = lerp( lerpResult150 , lerpResult157 , ( break494.g * 1.0 ));
				float T4_Tilling368 = _T4_Tilling1;
				float2 temp_cast_9 = (T4_Tilling368).xx;
				float2 texCoord132 = IN.ase_texcoord7.xy * temp_cast_9 + float2( 0,0 );
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
				float4 lerpResult165 = lerp( lerpResult155 , lerpResult161 , ( break494.b * 1.0 ));
				float4 lerpResult547 = lerp( lerpResult165 , _MapContourColor , ( break494.a * 1.0 ));
				float4 AllAlbedoCombined168 = lerpResult547;
				float4 lerpResult425 = lerp( T1_RGB71 , DebugColor151 , DebugVertexPainting46);
				float4 break187 = saturate( ( IN.ase_color * 2.0 ) );
				float4 lerpResult431 = lerp( T2_RGB114 , DebugColor252 , DebugVertexPainting46);
				float4 lerpResult408 = lerp( ( lerpResult425 * ( 1.0 - saturate( ( break187.r + break187.g + break187.b ) ) ) ) , ( break187.r * lerpResult431 ) , break187.r);
				float4 lerpResult434 = lerp( T3_RGB130 , DebugColor354 , DebugVertexPainting46);
				float4 lerpResult409 = lerp( lerpResult408 , ( break187.g * lerpResult434 ) , break187.g);
				float4 lerpResult438 = lerp( T4_RGB144 , DebugColor457 , DebugVertexPainting46);
				float4 lerpResult410 = lerp( lerpResult409 , ( break187.b * lerpResult438 ) , break187.b);
				float4 AllAlbedoVertexPaint208 = lerpResult410;
				float AddVertexPaintingToMask443 = _AddVertexPaintingToMask;
				float4 lerpResult446 = lerp( AllAlbedoCombined168 , AllAlbedoVertexPaint208 , AddVertexPaintingToMask443);
				float localStochasticTiling2_g10 = ( 0.0 );
				float2 temp_cast_12 = (T1_Tiling361).xx;
				float2 texCoord257 = IN.ase_texcoord7.xy * temp_cast_12 + float2( 0,0 );
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
				float2 temp_cast_13 = (T2_Tilling363).xx;
				float2 texCoord274 = IN.ase_texcoord7.xy * temp_cast_13 + float2( 0,0 );
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
				float4 break502 = MaskVertexPaint500;
				float4 lerpResult327 = lerp( T1_NAOH262 , T2_NAOH268 , ( break502.r * 2.0 ));
				float localStochasticTiling2_g12 = ( 0.0 );
				float2 temp_cast_14 = (T3_Tilling365).xx;
				float2 texCoord287 = IN.ase_texcoord7.xy * temp_cast_14 + float2( 0,0 );
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
				float4 lerpResult311 = lerp( lerpResult327 , T3_NAOH305 , ( break502.g * 2.0 ));
				float localStochasticTiling2_g13 = ( 0.0 );
				float2 temp_cast_15 = (T4_Tilling368).xx;
				float2 texCoord296 = IN.ase_texcoord7.xy * temp_cast_15 + float2( 0,0 );
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
				float4 lerpResult320 = lerp( lerpResult311 , T4_NAOH306 , ( break502.b * 2.0 ));
				float4 AllNormal_Combined321 = lerpResult320;
				float DebugNormal43 = _NormalDebug;
				float4 lerpResult348 = lerp( ( lerpResult446 * _IntensityColorMap ) , AllNormal_Combined321 , DebugNormal43);
				
				float2 appendResult464 = (float2(AllNormal_Combined321.r , 0.0));
				float2 temp_output_1_0_g18 = appendResult464;
				float dotResult4_g18 = dot( temp_output_1_0_g18 , temp_output_1_0_g18 );
				float3 appendResult10_g18 = (float3((temp_output_1_0_g18).x , (temp_output_1_0_g18).y , sqrt( ( 1.0 - saturate( dotResult4_g18 ) ) )));
				float3 normalizeResult12_g18 = normalize( appendResult10_g18 );
				

				float3 BaseColor = lerpResult348.rgb;
				float3 Normal = ( IN.ase_normal + normalizeResult12_g18 );
				float3 Emission = 0;
				float3 Specular = 0.5;
				float Metallic = 0;
				float Smoothness = _Smoothness;
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
Node;AmplifyShaderEditor.CommentaryNode;511;-8982.416,-2496;Inherit;False;1342.294;577.9338;Mask Vertex Painting;9;539;538;537;540;517;508;518;516;507;;1,0,0,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;495;-5506.5,384;Inherit;False;2435.5;1152.6;Symetry MaskParameter;19;528;527;536;534;490;535;488;499;485;492;519;513;479;487;500;491;483;480;486;;0.09534144,1,0,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;369;-6960,1200;Inherit;False;659.8311;1204.044;Tiling Controller Texture;22;522;523;520;521;497;498;354;356;365;366;368;353;355;367;364;363;357;358;359;360;361;362;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;308;-4274,-2482;Inherit;False;3709.769;2808;Texture RGBA;8;72;16;23;29;35;102;117;131;;1,0.4661931,0,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;307;-7498.852,-2491.554;Inherit;False;3081.05;2439.487;NAOH NormalMap Ambiant Occlusion Height;8;264;171;265;266;279;280;292;293;;0.1278601,0.1179245,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;264;-6154.443,-2441.554;Inherit;False;1683.34;546.8347;NAOH Texture 1;8;255;257;259;256;260;262;378;379;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;245;-2928,1904;Inherit;False;2436.83;1127.007;Vertex Painting;32;195;436;434;437;435;433;432;430;431;197;441;440;439;438;426;429;425;200;208;424;422;423;421;410;408;409;190;188;193;189;187;186;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;169;-2928,352;Inherit;False;2112.198;1378.064;Texture Set By Vertex Color;32;168;546;548;547;541;501;494;163;162;164;161;415;400;401;402;420;419;146;155;160;152;153;151;150;149;148;147;165;159;158;157;154;;0,0,0,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;145;-7584,1200;Inherit;False;580.6001;1437.798;Other Parameters;2;41;48;;0,0,0,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;72;-2944,-2432;Inherit;False;2313.769;659.8782;Albedo Texture 1;13;58;61;59;63;67;68;66;64;70;69;71;376;399;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;48;-7568,1824;Inherit;False;497;798.0001;Debug Vertex Color;8;57;56;55;54;52;53;50;51;;0.571486,0,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;41;-7568,1248;Inherit;False;557;471;Debug Variables;10;444;445;442;443;46;45;43;44;47;42;;0.5367103,0,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;16;-4224,-2432;Inherit;False;1202;443;Textures Terrain 1;5;10;11;12;15;22;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;23;-4208,-1744;Inherit;False;1202;443;Textures Terrain 2;5;28;26;25;24;27;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;29;-4208,-1024;Inherit;False;1202;443;Textures Terrain 3;5;34;33;32;31;30;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;35;-4224,-336;Inherit;False;1202;443;Textures Terrain 4;5;40;39;38;37;36;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;102;-2944,-1744;Inherit;False;2313.769;659.8782;Albedo Texture 2;13;113;112;111;110;109;108;106;105;104;103;114;374;375;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;117;-2928,-1040;Inherit;False;2313.769;659.8782;Albedo Texture 2;13;130;129;127;126;125;124;123;122;121;119;118;372;373;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;131;-2944,-336;Inherit;False;2313.769;659.8782;Albedo Texture 2;13;144;141;140;139;138;137;136;135;134;133;132;370;371;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;171;-7440.185,-2439.427;Inherit;False;1202;443;Textures Terrain NAOH 1;4;175;174;173;172;;1,1,1,1;0;0
Node;AmplifyShaderEditor.StickyNoteNode;181;-2917.163,-2896.279;Inherit;False;567.8623;332.1456;A demande au GA;;1,1,1,1;Demander les maps dont ils ont besoin pour pouvoir préparer le packing$;0;0
Node;AmplifyShaderEditor.CommentaryNode;265;-6151.142,-1833.533;Inherit;False;1683.34;546.8347;NAOH Texture 2;8;277;274;273;268;267;276;380;381;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;266;-7436.889,-1831.406;Inherit;False;1202;443;Textures Terrain NAOH 2;4;272;271;270;269;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;279;-6163.107,-1206.923;Inherit;False;1683.34;546.8347;NAOH Texture 1;8;305;290;289;287;286;281;382;383;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;280;-7448.852,-1204.796;Inherit;False;1202;443;Textures Terrain NAOH 3;4;285;284;283;282;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;292;-6159.807,-598.9022;Inherit;False;1683.34;546.8347;NAOH Texture 2;8;306;304;299;298;296;294;384;385;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;293;-7445.556,-596.7753;Inherit;False;1202;443;Textures Terrain NAOH 2;4;303;302;301;295;;1,1,1,1;0;0
Node;AmplifyShaderEditor.LerpOp;260;-4908.784,-2384.201;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;174;-6880.184,-2375.427;Inherit;True;Property;_T_1_TextureSample1;T_1_Texture Sample;1;0;Create;True;0;0;0;False;0;False;10;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;255;-6064.195,-2391.554;Inherit;False;175;T1_NAOH_Textures;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;257;-5806.444,-2256.719;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;259;-5548.443,-2124.719;Inherit;True;Property;_TextureSample28;Texture Sample 24;7;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;256;-5545.709,-2385.979;Inherit;False;Procedural Sample;-1;;10;f5379ff72769e2b4495e5ce2f004d8d4;2,157,0,315,0;7;82;SAMPLER2D;0;False;158;SAMPLER2DARRAY;0;False;183;FLOAT;0;False;5;FLOAT2;0,0;False;80;FLOAT3;0,0,0;False;104;FLOAT2;1,1;False;74;SAMPLERSTATE;0;False;5;COLOR;0;FLOAT;32;FLOAT;33;FLOAT;34;FLOAT;35
Node;AmplifyShaderEditor.LerpOp;267;-4905.483,-1776.179;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;274;-5803.143,-1648.698;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;277;-5542.408,-1777.958;Inherit;False;Procedural Sample;-1;;11;f5379ff72769e2b4495e5ce2f004d8d4;2,157,0,315,0;7;82;SAMPLER2D;0;False;158;SAMPLER2DARRAY;0;False;183;FLOAT;0;False;5;FLOAT2;0,0;False;80;FLOAT3;0,0,0;False;104;FLOAT2;1,1;False;74;SAMPLERSTATE;0;False;5;COLOR;0;FLOAT;32;FLOAT;33;FLOAT;34;FLOAT;35
Node;AmplifyShaderEditor.TexturePropertyNode;271;-7388.889,-1767.406;Inherit;True;Property;_T2_TerrainNAOH;T2_Terrain NAOH;15;0;Create;True;0;0;0;False;0;False;None;62dd9caeca8b41f43ad6062f3ce4c6f5;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
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
Node;AmplifyShaderEditor.TexturePropertyNode;284;-7400.852,-1140.796;Inherit;True;Property;_T3_TerrainNAOH;T3_Terrain NAOH;19;0;Create;True;0;0;0;False;0;False;None;2ab94f1a48e06794fbb0e7821f782089;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.TexturePropertyNode;301;-7397.556,-532.7753;Inherit;True;Property;_T4_TerrainNAOH;T4_Terrain NAOH;23;0;Create;True;0;0;0;False;0;False;None;2ab94f1a48e06794fbb0e7821f782089;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
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
Node;AmplifyShaderEditor.TexturePropertyNode;10;-4176,-2368;Inherit;True;Property;_T1_Terrain;T1_Terrain;10;1;[Header];Create;True;1;Texture 1 Vertex Paint Black;0;0;False;0;False;None;74c0f22b9612a7843b6df2db8a7499de;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
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
Node;AmplifyShaderEditor.RegisterLocalVarNode;144;-848,-288;Inherit;True;T4_RGB;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TexturePropertyNode;24;-4160,-1696;Inherit;True;Property;_T2_Terrain;T2_Terrain;14;1;[Header];Create;True;1;Texture 2 Vertex Paint Red;0;0;False;0;False;None;f4602775b0259074fb73ea432930b326;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.TexturePropertyNode;33;-4160,-976;Inherit;True;Property;_T3_Terrain;T3_Terrain;18;1;[Header];Create;True;1;Texture 3 Vertex Paint Green;0;0;False;0;False;None;f21bdb6686d6c7b40a57852da3257e96;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.TexturePropertyNode;38;-4176,-288;Inherit;True;Property;_T4_Terrain;T4_Terrain;22;1;[Header];Create;True;1;Texture 4 Vertex Paint Blue;0;0;False;0;False;None;47c18da720477f444a965ad6fd34f638;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.FunctionNode;129;-2288,-960;Inherit;True;Procedural Sample;-1;;16;f5379ff72769e2b4495e5ce2f004d8d4;2,157,0,315,0;7;82;SAMPLER2D;0;False;158;SAMPLER2DARRAY;0;False;183;FLOAT;0;False;5;FLOAT2;0,0;False;80;FLOAT3;0,0,0;False;104;FLOAT2;1,1;False;74;SAMPLERSTATE;0;False;5;COLOR;0;FLOAT;32;FLOAT;33;FLOAT;34;FLOAT;35
Node;AmplifyShaderEditor.FunctionNode;105;-2304,-1664;Inherit;True;Procedural Sample;-1;;17;f5379ff72769e2b4495e5ce2f004d8d4;2,157,0,315,0;7;82;SAMPLER2D;0;False;158;SAMPLER2DARRAY;0;False;183;FLOAT;0;False;5;FLOAT2;0,0;False;80;FLOAT3;0,0,0;False;104;FLOAT2;1,1;False;74;SAMPLERSTATE;0;False;5;COLOR;0;FLOAT;32;FLOAT;33;FLOAT;34;FLOAT;35
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
Node;AmplifyShaderEditor.CommentaryNode;309;-7579.588,-21.17186;Inherit;False;2056.007;1181.899;Normal By Vertex Color;13;405;404;403;325;321;331;332;329;327;320;311;502;503;;1,1,1,1;0;0
Node;AmplifyShaderEditor.LerpOp;311;-6474.588,458.8281;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;320;-6090.588,794.8281;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;327;-6932.588,299.8282;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;329;-7210.588,317.8282;Inherit;False;268;T2_NAOH;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;332;-6699.623,489.3104;Inherit;False;305;T3_NAOH;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;331;-6316.623,814.3105;Inherit;False;306;T4_NAOH;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;370;-1995.869,-125.7466;Inherit;False;367;T4_ProceduralTiling;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;372;-2833.533,-720.7291;Inherit;False;365;T3_Tilling;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;373;-1991.919,-834.5376;Inherit;False;366;T3_ProceduralTiling;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;379;-5191.725,-2239.871;Inherit;False;362;T1_ProceduralTiling;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;380;-5164.562,-1637.57;Inherit;False;364;T2_ProceduralTiling;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;383;-6031.644,-1008.532;Inherit;False;365;T3_Tilling;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;382;-5191.029,-1016.738;Inherit;False;366;T3_ProceduralTiling;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;385;-5192.014,-406.0318;Inherit;False;367;T4_ProceduralTiling;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;384;-6032.629,-397.8258;Inherit;False;368;T4_Tilling;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCGrayscale;68;-1360,-2288;Inherit;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;381;-6005.177,-1629.364;Inherit;False;363;T2_Tilling;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;378;-6034.34,-2236.665;Inherit;False;361;T1_Tiling;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;376;-2001.904,-2205.265;Inherit;False;362;T1_ProceduralTiling;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;61;-2640,-2112;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;71;-848,-2368;Inherit;False;T1_RGB;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;399;-2862.186,-2096.455;Inherit;False;361;T1_Tiling;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;325;-7204.588,224.8281;Inherit;False;262;T1_NAOH;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;375;-1993.841,-1532.572;Inherit;False;364;T2_ProceduralTiling;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;160;-2496,1040;Inherit;False;46;DebugVertexPainting;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;404;-7100.706,818.3354;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;141;-2864,-256;Inherit;False;40;T4_Textures;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.LerpOp;155;-1904,832;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;371;-2837.484,-11.93823;Inherit;False;368;T4_Tilling;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;374;-2835.456,-1421.364;Inherit;False;363;T2_Tilling;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;146;-2816,400;Inherit;False;71;T1_RGB;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;419;-2448.437,564.0206;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;420;-2615.78,592.8457;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;402;-2391.693,1401.077;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;401;-2391.693,1305.077;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;400;-2394.583,1184.075;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;415;-2670.039,1025.11;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;161;-1808,1184;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;164;-2144,1376;Inherit;False;46;DebugVertexPainting;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;162;-2080,1184;Inherit;False;144;T4_RGB;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;163;-2112,1280;Inherit;False;57;DebugColor4;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;321;-5786.588,793.8281;Inherit;False;AllNormal_Combined;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;183;-80,-1920;Inherit;False;168;AllAlbedoCombined;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;348;1904,-1904;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;351;1616,-1424;Inherit;False;43;DebugNormal;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.BlendOpsNode;254;1008,-1792;Inherit;False;Overlay;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;446;1024,-1920;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;449;1296,-1920;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;451;2176,-1904;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;12;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;ExtraPrePass;0;0;ExtraPrePass;5;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;5;True;12;all;0;False;True;1;1;False;;0;False;;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;0;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;453;1538.501,-1918.614;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;12;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;ShadowCaster;0;2;ShadowCaster;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;False;False;True;False;False;False;False;0;False;;False;False;False;False;False;False;False;False;False;True;1;False;;True;3;False;;False;True;1;LightMode=ShadowCaster;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;454;1538.501,-1918.614;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;12;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;DepthOnly;0;3;DepthOnly;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;False;False;True;False;False;False;False;0;False;;False;False;False;False;False;False;False;False;False;True;1;False;;False;False;True;1;LightMode=DepthOnly;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;455;1538.501,-1918.614;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;12;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;Meta;0;4;Meta;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Meta;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;456;1538.501,-1918.614;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;12;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;Universal2D;0;5;Universal2D;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;5;True;12;all;0;False;True;1;1;False;;0;False;;1;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;False;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;1;LightMode=Universal2D;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;457;1538.501,-1918.614;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;12;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;DepthNormals;0;6;DepthNormals;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;5;True;12;all;0;False;True;1;1;False;;0;False;;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;;True;3;False;;False;True;1;LightMode=DepthNormals;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;458;1538.501,-1918.614;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;12;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;GBuffer;0;7;GBuffer;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;5;True;12;all;0;False;True;1;1;False;;0;False;;1;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;1;LightMode=UniversalGBuffer;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;452;2176,-1904;Float;False;True;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;12;S_Map_V1;94348b07e5e8bab40bd6c8a1e3df54cd;True;Forward;0;1;Forward;18;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;5;True;12;all;0;False;True;1;1;False;;0;False;;1;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;1;LightMode=UniversalForward;False;False;0;Hidden/InternalErrorShader;0;0;Standard;38;Workflow;1;0;Surface;0;0;  Refraction Model;0;0;  Blend;0;0;Two Sided;1;0;Fragment Normal Space,InvertActionOnDeselection;0;0;Transmission;0;0;  Transmission Shadow;0.5,False,;0;Translucency;0;0;  Translucency Strength;1,False,;0;  Normal Distortion;0.5,False,;0;  Scattering;2,False,;0;  Direct;0.9,False,;0;  Ambient;0.1,False,;0;  Shadow;0.5,False,;0;Cast Shadows;1;0;  Use Shadow Threshold;0;0;Receive Shadows;1;0;GPU Instancing;1;0;LOD CrossFade;1;0;Built-in Fog;1;0;_FinalColorxAlpha;0;0;Meta Pass;1;0;Override Baked GI;0;0;Extra Pre Pass;0;0;DOTS Instancing;0;0;Tessellation;0;0;  Phong;0;0;  Strength;0.5,False,;0;  Type;0;0;  Tess;16,False,;0;  Min;10,False,;0;  Max;25,False,;0;  Edge Length;16,False,;0;  Max Displacement;25,False,;0;Write Depth;0;0;  Early Z;0;0;Vertex Position,InvertActionOnDeselection;1;0;0;8;False;True;True;True;True;True;True;True;False;;False;0
Node;AmplifyShaderEditor.GetLocalVarNode;349;1584,-1520;Inherit;False;321;AllNormal_Combined;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.DynamicAppendNode;464;1664,-1264;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.BreakToComponentsNode;462;1536,-1264;Inherit;False;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.FunctionNode;463;1840,-1264;Inherit;False;Normal Reconstruct Z;-1;;18;63ba85b764ae0c84ab3d698b86364ae9;0;1;1;FLOAT2;0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;459;1856,-1760;Inherit;False;Property;_Smoothness;Smoothness;26;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.NormalVertexDataNode;465;1872,-1424;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;467;2080,-1376;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;450;1248,-1728;Inherit;False;Property;_IntensityColorMap;IntensityColorMap;1;0;Create;True;0;0;0;False;0;False;2;2;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;210;688,-1776;Inherit;False;208;AllAlbedoVertexPaint;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;448;-112,-1840;Inherit;False;443;AddVertexPaintingToMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;186;-2544,2384;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.BreakToComponentsNode;187;-2384,2384;Inherit;False;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;189;-2704,2384;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;193;-1392,2576;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.VertexColorNode;188;-2864,2384;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;409;-1136,2384;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;408;-1360,2256;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;410;-976,2512;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;421;-2224,2160;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;423;-2032,2160;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;422;-1872,2160;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;424;-1680,2144;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;200;-2256,1936;Inherit;False;71;T1_RGB;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;425;-1968,1936;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;429;-2288,2016;Inherit;False;51;DebugColor1;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;426;-2320,2096;Inherit;False;46;DebugVertexPainting;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;438;-1648,2768;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;439;-1936,2768;Inherit;False;144;T4_RGB;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;440;-1936,2848;Inherit;False;57;DebugColor4;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;441;-2000,2928;Inherit;False;46;DebugVertexPainting;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;197;-1552,2288;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;431;-1712,2304;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;430;-2000,2304;Inherit;False;114;T2_RGB;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;432;-2032,2384;Inherit;False;52;DebugColor2;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;433;-2064,2464;Inherit;False;46;DebugVertexPainting;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;435;-2000,2544;Inherit;False;130;T3_RGB;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;437;-2064,2704;Inherit;False;46;DebugVertexPainting;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;434;-1712,2544;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;436;-2032,2624;Inherit;False;54;DebugColor3;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;195;-1456,2416;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;190;-2864,2576;Inherit;False;Constant;_Float4;Float 0;0;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;208;-752,2512;Inherit;False;AllAlbedoVertexPaint;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;486;-4592,672;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;480;-4352,928;Inherit;True;Property;_TerrainMask_VertexPaint3;TerrainMask_VertexPaint;8;1;[Header];Create;True;1;Terrain Mask;0;0;False;0;False;-1;61bcabd8649009f41850e63708dd1066;61bcabd8649009f41850e63708dd1066;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;483;-3952,672;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;491;-3808,800;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;54;-7280,2240;Inherit;False;DebugColor3;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;55;-7552,2240;Inherit;False;Constant;_DebugColor3;DebugColor3;7;0;Create;True;0;0;0;False;0;False;0,1,0.002223969,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;42;-7552,1472;Inherit;False;Property;_NormalDebug;NormalDebug;4;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;47;-7552,1392;Inherit;False;Property;_VertexPaintDebug;VertexPaintDebug;5;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;44;-7552,1296;Inherit;False;Property;_GrayscaleDebug;GrayscaleDebug;3;1;[Header];Create;True;1;Debug Mode;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;51;-7280,1872;Inherit;False;DebugColor1;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;52;-7280,2064;Inherit;False;DebugColor2;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;50;-7552,1872;Inherit;False;Constant;_DebugColor1;DebugColor1;7;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;53;-7552,2064;Inherit;False;Constant;_DebugColor2;DebugColor2;7;0;Create;True;0;0;0;False;0;False;1,0,0.03653574,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;56;-7552,2448;Inherit;False;Constant;_DebugColor4;DebugColor4;7;0;Create;True;0;0;0;False;0;False;0.00126791,0,1,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;57;-7280,2448;Inherit;False;DebugColor4;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;43;-7264,1472;Inherit;False;DebugNormal;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;45;-7264,1296;Inherit;False;DebugGrayscale;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;46;-7264,1392;Inherit;False;DebugVertexPainting;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;443;-7264,1632;Inherit;False;AddVertexPaintingToMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;442;-7568,1632;Inherit;False;Property;_AddVertexPaintingToMask;AddVertexPaintingToMask;0;1;[Header];Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;445;-7264,1552;Inherit;False;UseVertexPainting;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;444;-7568,1552;Inherit;False;Property;_UseVertexPainting;UseVertexPainting;2;1;[Header];Create;True;1;UseVertexPainting;0;0;False;0;False;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;362;-6576,1376;Inherit;False;T1_ProceduralTiling;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;361;-6576,1280;Inherit;False;T1_Tiling;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;360;-6912,1376;Inherit;False;Property;_T1_ProceduralTiling1;T1_ProceduralTiling;13;0;Create;True;0;0;0;False;0;False;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;359;-6912,1280;Inherit;False;Property;_T1_Tiling1;T1_Tiling;12;0;Create;True;0;0;0;False;0;False;10;17.2;1;100;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;358;-6912,1600;Inherit;False;Property;_T2_ProceduralTiling1;T2_ProceduralTiling;17;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;357;-6912,1504;Inherit;False;Property;_T2_Tilling1;T2_Tilling;16;0;Create;True;0;0;0;False;0;False;10;10;1;100;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;363;-6576,1504;Inherit;False;T2_Tilling;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;364;-6576,1600;Inherit;False;T2_ProceduralTiling;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;367;-6576,1952;Inherit;False;T4_ProceduralTiling;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;355;-6912,1952;Inherit;False;Property;_T4_ProceduralTiling1;T4_ProceduralTiling;25;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;353;-6912,2048;Inherit;False;Property;_T4_Tilling1;T4_Tilling;24;0;Create;True;0;0;0;False;0;False;10;10;0;100;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;368;-6576,2048;Inherit;False;T4_Tilling;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;366;-6576,1824;Inherit;False;T3_ProceduralTiling;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;365;-6576,1728;Inherit;False;T3_Tilling;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;356;-6912,1824;Inherit;False;Property;_T3_ProceduralTiling1;T3_ProceduralTiling;21;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;354;-6912,1728;Inherit;False;Property;_T3_Tilling1;T3_Tilling;20;0;Create;True;0;0;0;False;0;False;10;10;1;100;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;461;1264,-1264;Inherit;False;321;AllNormal_Combined;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;500;-3376,800;Inherit;False;MaskVertexPaint;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.BreakToComponentsNode;494;-2672,1280;Inherit;False;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.GetLocalVarNode;501;-2928,1280;Inherit;False;500;MaskVertexPaint;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;503;-7488,768;Inherit;False;500;MaskVertexPaint;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.BreakToComponentsNode;502;-7280,768;Inherit;False;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.Vector2Node;487;-4864,672;Inherit;False;Constant;_Vector0;Vector 0;26;0;Create;True;0;0;0;False;0;False;2,1;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RegisterLocalVarNode;175;-7104.185,-2375.427;Inherit;False;T1_NAOH_Textures;-1;True;1;0;SAMPLER2D;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;172;-7376.185,-2167.427;Inherit;False;0;10;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexturePropertyNode;173;-7392.185,-2375.427;Inherit;True;Property;_T1_TerrainNAOH;T1_Terrain NAOH;11;0;Create;True;0;0;0;False;0;False;None;7d5aacd9a1cc3684d844764682929ab6;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SamplerNode;479;-4368,672;Inherit;True;Property;_TerrainMask_VertexPaint2;TerrainMask_VertexPaint;9;1;[Header];Create;True;1;Terrain Mask;0;0;False;0;False;-1;61bcabd8649009f41850e63708dd1066;61bcabd8649009f41850e63708dd1066;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;22;-4160,-2160;Inherit;False;0;10;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;507;-8589.416,-2448;Inherit;False;TerrainMask_VertexPaint;-1;True;1;0;SAMPLER2D;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;516;-8861.416,-2240;Inherit;False;0;508;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;518;-8285.416,-2448;Inherit;True;Property;_TerrainMask_VertexPaintSample;TerrainMask_VertexPaint Sample;27;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexturePropertyNode;508;-8845.416,-2448;Inherit;True;Property;_TerrainMask_VertexPaint;TerrainMask_VertexPaint;9;0;Create;True;0;0;0;False;0;False;61bcabd8649009f41850e63708dd1066;c58ac4b6295bebd488030e025aee8b11;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RegisterLocalVarNode;517;-7917.416,-2448;Inherit;False;TerrainMask_VertexPaintAlbedo;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;513;-4704,576;Inherit;False;507;TerrainMask_VertexPaint;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.GetLocalVarNode;519;-3984,512;Inherit;False;517;TerrainMask_VertexPaintAlbedo;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;405;-7104,704;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;498;-6576,2160;Inherit;False;SymetryVertexPaint;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;520;-6576,2240;Inherit;False;FlipSymetryVertexPaint;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;492;-3584,800;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;523;-6576,2320;Inherit;False;RotateVertexPaintMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;499;-3820,1026;Inherit;False;498;SymetryVertexPaint;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;488;-4592,944;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;535;-4752,1024;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;490;-4992,1024;Inherit;False;Constant;_Vector1;Vector 1;26;0;Create;True;0;0;0;False;0;False;-2,1;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.Vector2Node;534;-4992,1152;Inherit;False;Constant;_Vector2;Vector 1;26;0;Create;True;0;0;0;False;0;False;-2,-1;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.GetLocalVarNode;536;-5072,1280;Inherit;False;520;FlipSymetryVertexPaint;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;497;-6912,2160;Inherit;False;Property;_SymetryVertexPaint;Symetry Vertex Paint;6;2;[Header];[IntRange];Create;True;1;Mask Vertex Painting;0;0;False;0;False;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;521;-6912,2240;Inherit;False;Property;_FlipSymetryVertexPaint;Flip Symetry Vertex Paint;7;1;[IntRange];Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;522;-6912,2320;Inherit;False;Property;_RotateVertexPaintMask;Rotate Vertex Paint Mask;8;0;Create;True;1;Mask Vertex Painting;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RotatorNode;540;-8560,-2240;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TauNode;537;-8848,-2000;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;538;-8736,-2080;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;539;-8976,-2080;Inherit;False;523;RotateVertexPaintMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;541;-2569.929,1435.056;Inherit;False;Constant;_Float5;Float 5;27;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;485;-5312,816;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TauNode;527;-5344,1040;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;528;-5232,960;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;403;-7104,928;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;547;-1312,1520;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;546;-2512,1568;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;168;-1072,1520;Inherit;False;AllAlbedoCombined;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;548;-1616,1536;Inherit;False;Property;_MapContourColor;Map Contour Color;27;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
WireConnection;260;0;256;0
WireConnection;260;1;259;0
WireConnection;260;2;379;0
WireConnection;174;0;175;0
WireConnection;174;1;172;0
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
WireConnection;68;0;66;0
WireConnection;61;0;399;0
WireConnection;71;0;69;0
WireConnection;404;0;502;1
WireConnection;155;0;150;0
WireConnection;155;1;157;0
WireConnection;155;2;401;0
WireConnection;419;0;147;0
WireConnection;419;1;420;0
WireConnection;420;0;415;0
WireConnection;402;0;494;2
WireConnection;402;1;541;0
WireConnection;401;0;494;1
WireConnection;401;1;541;0
WireConnection;400;0;494;0
WireConnection;400;1;541;0
WireConnection;415;0;494;0
WireConnection;415;1;494;1
WireConnection;415;2;494;2
WireConnection;161;0;162;0
WireConnection;161;1;163;0
WireConnection;161;2;164;0
WireConnection;321;0;320;0
WireConnection;348;0;449;0
WireConnection;348;1;349;0
WireConnection;348;2;351;0
WireConnection;254;0;183;0
WireConnection;254;1;210;0
WireConnection;446;0;183;0
WireConnection;446;1;210;0
WireConnection;446;2;448;0
WireConnection;449;0;446;0
WireConnection;449;1;450;0
WireConnection;452;0;348;0
WireConnection;452;1;467;0
WireConnection;452;4;459;0
WireConnection;464;0;462;0
WireConnection;462;0;461;0
WireConnection;463;1;464;0
WireConnection;467;0;465;0
WireConnection;467;1;463;0
WireConnection;186;0;189;0
WireConnection;187;0;186;0
WireConnection;189;0;188;0
WireConnection;189;1;190;0
WireConnection;193;0;187;2
WireConnection;193;1;438;0
WireConnection;409;0;408;0
WireConnection;409;1;195;0
WireConnection;409;2;187;1
WireConnection;408;0;424;0
WireConnection;408;1;197;0
WireConnection;408;2;187;0
WireConnection;410;0;409;0
WireConnection;410;1;193;0
WireConnection;410;2;187;2
WireConnection;421;0;187;0
WireConnection;421;1;187;1
WireConnection;421;2;187;2
WireConnection;423;0;421;0
WireConnection;422;0;423;0
WireConnection;424;0;425;0
WireConnection;424;1;422;0
WireConnection;425;0;200;0
WireConnection;425;1;429;0
WireConnection;425;2;426;0
WireConnection;438;0;439;0
WireConnection;438;1;440;0
WireConnection;438;2;441;0
WireConnection;197;0;187;0
WireConnection;197;1;431;0
WireConnection;431;0;430;0
WireConnection;431;1;432;0
WireConnection;431;2;433;0
WireConnection;434;0;435;0
WireConnection;434;1;436;0
WireConnection;434;2;437;0
WireConnection;195;0;187;1
WireConnection;195;1;434;0
WireConnection;208;0;410;0
WireConnection;486;0;487;0
WireConnection;480;0;513;0
WireConnection;480;1;488;0
WireConnection;483;0;479;0
WireConnection;491;0;483;0
WireConnection;54;0;55;0
WireConnection;51;0;50;0
WireConnection;52;0;53;0
WireConnection;57;0;56;0
WireConnection;43;0;42;0
WireConnection;45;0;44;0
WireConnection;46;0;47;0
WireConnection;443;0;442;0
WireConnection;445;0;444;0
WireConnection;362;0;360;0
WireConnection;361;0;359;0
WireConnection;363;0;357;0
WireConnection;364;0;358;0
WireConnection;367;0;355;0
WireConnection;368;0;353;0
WireConnection;366;0;356;0
WireConnection;365;0;354;0
WireConnection;500;0;492;0
WireConnection;494;0;501;0
WireConnection;502;0;503;0
WireConnection;175;0;173;0
WireConnection;479;0;513;0
WireConnection;479;1;486;0
WireConnection;507;0;508;0
WireConnection;518;0;507;0
WireConnection;518;1;540;0
WireConnection;517;0;518;0
WireConnection;405;0;502;0
WireConnection;498;0;497;0
WireConnection;520;0;521;0
WireConnection;492;0;519;0
WireConnection;492;1;491;0
WireConnection;492;2;499;0
WireConnection;523;0;522;0
WireConnection;488;1;535;0
WireConnection;535;0;490;0
WireConnection;535;1;534;0
WireConnection;535;2;536;0
WireConnection;540;0;516;0
WireConnection;540;2;538;0
WireConnection;538;0;539;0
WireConnection;538;1;537;0
WireConnection;528;1;527;0
WireConnection;403;0;502;2
WireConnection;547;0;165;0
WireConnection;547;1;548;0
WireConnection;547;2;546;0
WireConnection;546;0;494;3
WireConnection;168;0;547;0
ASEEND*/
//CHKSM=31E62282A05DB4E15579097A0D7746FEB33A2A60