Shader "Custom/SHLit"
{
    Properties
    {
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "SphericalHarmonics.hlsl"

            #define PI 3.14159265358
            #define Y0(v) (1.0 / 2.0) * sqrt(1.0 / PI)
            #define Y1(v) sqrt(3.0 / (4.0 * PI)) * v.y
            #define Y2(v) sqrt(3.0 / (4.0 * PI)) * v.z
            #define Y3(v) sqrt(3.0 / (4.0 * PI)) * v.x
            #define Y4(v) 1.0 / 2.0 * sqrt(15.0 / PI) * v.x * v.y
            #define Y5(v) 1.0 / 2.0 * sqrt(15.0 / PI) * v.y * v.z
            #define Y6(v) 1.0 / 4.0 * sqrt(5.0 / PI) * (-v.x * v.x - v.y * v.y + 2 * v.z * v.z)
            #define Y7(v) 1.0 / 2.0 * sqrt(15.0 / PI) * v.z * v.x
            #define Y8(v) 1.0 / 4.0 * sqrt(15.0 / PI) * (v.x * v.x - v.y * v.y)

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL0;
                float4 vertex : SV_POSITION;
            };
            // 3rd order now
            void RotateSH(inout float4 sh[9], float3x3 rot)
            {
                float3 shin[16];
                float3 shout[16];
                shin[0] = sh[0].xyz;
                shin[1] = sh[1].xyz;
                shin[2] = sh[2].xyz;
                shin[3] = sh[3].xyz;
                shin[4] = sh[4].xyz;
                shin[5] = sh[5].xyz;
                shin[6] = sh[6].xyz;
                shin[7] = sh[7].xyz;
                shin[8] = sh[8].xyz;
                // shin[9] = sh[9].xyz;
                // shin[10] = sh[10].xyz;
                // shin[11] = sh[11].xyz;
                // shin[12] = sh[12].xyz;
                // shin[13] = sh[13].xyz;
                // shin[14] = sh[14].xyz;
                // shin[15] = sh[15].xyz;
                RotateSH(rot, 3, shin, shout);
                sh[0].xyz = shout[0];
                sh[1].xyz = shout[1];
                sh[2].xyz = shout[2];
                sh[3].xyz = shout[3];
                sh[4].xyz = shout[4];
                sh[5].xyz = shout[5];
                sh[6].xyz = shout[6];
                sh[7].xyz = shout[7];
                sh[8].xyz = shout[8];
                // sh[9].xyz = shout[9];
                // sh[10].xyz = shout[10];
                // sh[11].xyz = shout[11];
                // sh[12].xyz = shout[12];
                // sh[13].xyz = shout[13];
                // sh[14].xyz = shout[14];
                // sh[15].xyz = shout[15];
            }

            StructuredBuffer<float4> SHbuffer;
            float4x4 shRotMatrix;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {

                float3 v = i.normal.xyz;
                v = normalize(v);
                float4 sh[9];
                sh[0] = SHbuffer[0];
                sh[1] = SHbuffer[1];
                sh[2] = SHbuffer[2];
                sh[3] = SHbuffer[3];
                sh[4] = SHbuffer[4];
                sh[5] = SHbuffer[5];
                sh[6] = SHbuffer[6];
                sh[7] = SHbuffer[7];
                sh[8] = SHbuffer[8];
                RotateSH(sh, (float3x3)shRotMatrix);
                float4 result =
                    sh[0] * Y0(v) +
                    sh[1] * Y1(v) +
                    sh[2] * Y2(v) +
                    sh[3] * Y3(v) +
                    sh[4] * Y4(v) +
                    sh[5] * Y5(v) +
                    sh[6] * Y6(v) +
                    sh[7] * Y7(v) +
                    sh[8] * Y8(v);

                result.a = 1.0;
                return result;
            }
            ENDCG
        }
    }
}
