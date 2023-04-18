Texture2D texWAVE;
Texture2D texMASK;
SamplerState s0 <string uiname="Sampler";>
{Filter=MIN_MAG_MIP_POINT;AddressU=WRAP;AddressV=WRAP;};
SamplerState s1:IMMUTABLE
{Filter=MIN_MAG_MIP_LINEAR;AddressU=WRAP;AddressV=WRAP;};
cbuffer cbControls : register( b0 )
{
    float4x4 tVP : VIEWPROJECTION;
    float4x4 tW : WORLD;
	
    //float Alpha <float uimin=0.0; float uimax=1.0;> = 1; 
    //float4 Color <bool color=true;> = { 1.0f,1.0f,1.0f,1.0f };
   // float4x4 tTex <string uiname="Texture Transform";>;
    //float4x4 tColor <string uiname="Color Transform";>;
	
};

struct VS_IN
{
    float4 PosO : POSITION;
    float4 TexCd : TEXCOORD0;
};

struct VS_OUT
{
    float4 PosWVP: SV_POSITION;
    float4 TexCd: TEXCOORD0;
};

VS_OUT VS(VS_IN In)
{
    VS_OUT Out=(VS_OUT)0;
    Out.PosWVP=mul(In.PosO,mul(tW,tVP));
    Out.TexCd=In.TexCd;
    return Out;
}

float2 R:TARGETSIZE;
float Attack <String uiname="Attack";> = 0.5;
float _Decay <String uiname="1-Decay";> = 0.01;

//bool Reset=0;
float4 PS(VS_OUT In):SV_Target
{
	float2 uv=In.TexCd.xy+.0;
    //float4 c=texWAVE.Sample(s0,uv)*Color;
	float4 mask=texMASK.Sample(s1,uv);
    float p_1 = texWAVE.Sample(s0,uv).x;
    //float p_2 = tex2D(samWave2, TexC).x;
    float p_2 = texWAVE.Sample(s0,uv).y;
    
	
    float p_1n =  texWAVE.Sample(s0,uv-float2(1,0)/R).x;
    p_1n = p_1n + texWAVE.Sample(s0,uv+float2(1,0)/R).x;
    p_1n = p_1n + texWAVE.Sample(s0,uv-float2(0,1)/R).x;
    p_1n = p_1n + texWAVE.Sample(s0,uv+float2(0,1)/R).x;
    p_1n = p_1n / 4;

    float p = (p_1 + _Decay * (p_1 - p_2)) + Attack * (p_1n - p_1);
	p=lerp(p,mask.x,mask.a);

	//if(Reset)return float4(0,mask.x,0,1);
	//return 1;
    return float4(p,p_1,.0,1);
}


technique10 Constant
{
	pass P0
	{
		SetVertexShader( CompileShader( vs_4_0, VS() ) );
		SetPixelShader( CompileShader( ps_4_0, PS() ) );
	}
}




