/** クロマキーシェーダー  ver 0.2  by ideal.exe

	Unlit Shader をベースに作成
	コメントの chroma key -> 部分が追加したコード
*/
Shader "Unlit/ChromaKeyShader"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		// chroma key ->
		_KeyColor("Key Color", COLOR) = (0,0,1,1)
		_Threshold("Threshold", Range(0, 10)) = 1
		// -> chroma key
	}
		SubShader
	{
		//Tags { "RenderType"="Opaque" }
		Tags { "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" }
		LOD 100

		// chroma key ->
		Cull Off // 両面表示
		ZWrite Off
		Blend SrcAlpha OneMinusSrcAlpha
		// -> chroma key

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog

			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			// chroma key ->
			float _Threshold;
			fixed4 _KeyColor;
			// -> chroma key

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);
				// chroma key ->
				fixed4 key = _KeyColor;
				fixed4 mask = step(_Threshold*_Threshold/50, distance(col, key)); // キーカラーとの距離をとって色域判定
				// -> chroma key
				// apply fog
				UNITY_APPLY_FOG(i.fogCoord, col);
				//return col;
				return fixed4(col.r, col.g, col.b, mask.r); // マスクのR値をアルファとして使用
	}
	ENDCG
}
	}
}
